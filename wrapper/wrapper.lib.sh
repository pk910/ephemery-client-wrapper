#!/bin/sh

ephemery_repo="ephemery-testnet/ephemery-genesis"
ephemery_fallback_url="https://ephemery.dev/latest/retention.vars"
testnet_dir=/ephemery_config

ephemery_wrapper() {
  proc_name="$1"
  data_dir="$2"
  reset_fn="$3"
  start_fn="$4"

  trap "sigint_trap $proc_name" SIGINT
  trap "sigterm_trap $proc_name" SIGTERM

  while true
  do
    # stop client if running
    stop_client $proc_name

    # download latest genesis
    ensure_latest_config
    if [ ! -f $testnet_dir/retention.vars ]; then
      echo "[EphemeryWrapper] ephemery genesis is invalid - retrying in 60sec..."
      sleep 60
      continue
    fi

    source $testnet_dir/retention.vars
    testnet_timeout=$(expr $GENESIS_TIMESTAMP + $GENESIS_RESET_INTERVAL)
    if [ $testnet_timeout -le $(date +%s) ]; then
      echo "[EphemeryWrapper] ephemery genesis is expired - retrying in 60sec..."
      sleep 60
      continue
    fi

    # reset datadir if needed
    ensure_clean_datadir "$data_dir" "$reset_fn"

    # spin up client in background
    $start_fn &

    # wait for next iteration
    while true
    do
      sleep_time=120
      current_time=$(date +%s)
      if [ $testnet_timeout -gt $current_time ]; then
        sleep_timeout=$(expr $testnet_timeout - $current_time)
        if [ $sleep_timeout -lt $sleep_time ]; then
          sleep_time=$sleep_timeout
        fi
      else
        break
      fi
      
      for i in {1..$sleep_time}
      do
        sleep 1
      done

      proc_pid=$(pidof $proc_name)
      if [ -z "$proc_pid" ]; then
        echo "[EphemeryWrapper] client stopped unexpectedly"
        exit 1
      fi
    done

  done
}

sigint_trap() {
  echo "[EphemeryWrapper] received SIGINT signal"
  stop_client $1
  exit
}

sigterm_trap() {
  echo "[EphemeryWrapper] received SIGTERM signal"
  stop_client $1
  exit
}

stop_client() {
  proc_name="$1"
  proc_pid=$(pidof $proc_name)
  if ! [ -z "$proc_pid" ]; then
    if [ -z "$2" ]; then
      echo "[EphemeryWrapper] sending SIGINT to client process..."
      kill -s SIGINT $proc_pid
    fi

    retry=0
    while true
    do
      sleep 5
      proc_pid=$(pidof $proc_name)
      if [ -z "$proc_pid" ]; then
        break
      fi

      retry=$(expr $retry + 1)
      if [ $retry -eq 24 ]; then
        # still running after 2 min, send SIGINT again
        echo "[EphemeryWrapper] sending 2nd SIGINT to client process..."
        kill -s SIGINT $proc_pid
      elif [ $retry -eq 48 ]; then
        # still running after 4 min, send SIGKILL
        # we really have to stop the client here, or we'll miss the genesis at t+5min
        echo "[EphemeryWrapper] sending SIGKILL to client process..."
        kill -s SIGKILL $proc_pid
      fi
    done
    echo "[EphemeryWrapper] client process stopped"
  fi
}


get_ephemery_release() {
  # resolve the latest genesis release without the github api, which is rate limited per ip
  # 1. follow the redirect of the github "latest release" web endpoint
  release=$(curl -k --silent --connect-timeout 10 --max-time 30 -o /dev/null -w "%{redirect_url}" \
    "https://github.com/$ephemery_repo/releases/latest" |
    sed -E 's|^.*/tag/||')

  if [ -z "$release" ]; then
    # 2. fall back to the ITERATION_RELEASE entry of the ephemery.dev config mirror
    echo "[EphemeryWrapper] could not resolve latest release from github, trying $ephemery_fallback_url" >&2
    release=$(curl -k --silent --connect-timeout 10 --max-time 30 "$ephemery_fallback_url" |
      grep "ITERATION_RELEASE" |
      sed -E 's/.*"([^"]+)".*/\1/' |
      head -n 1)
  fi

  echo "$release"
}

ensure_latest_config() {
  if ! [ -d $testnet_dir ]; then
    mkdir -p $testnet_dir
  fi

  stored_iteration=""
  if [ -f $testnet_dir/retention.vars ]; then
    current_time=$(date +%s)
    source $testnet_dir/retention.vars
    testnet_timeout=$(expr $GENESIS_TIMESTAMP + $GENESIS_RESET_INTERVAL - 300)
    stored_iteration="$ITERATION_RELEASE"
    if [ $testnet_timeout -gt $current_time ]; then
      echo "[EphemeryWrapper] found stored ephemery genesis (iteration $stored_iteration) - skipping download"
      return
    fi
  fi

  ephemery_release=$(get_ephemery_release)

  if [ -z "$ephemery_release" ]; then
    # never drop a working config just because the release lookup failed
    echo "[EphemeryWrapper] could not get latest genesis release version - keeping current config."
    return
  fi
  if [ ! -z "$stored_iteration" ] && [ "$stored_iteration" = "$ephemery_release" ]; then
    echo "[EphemeryWrapper] cannot load new genesis release, iteration $stored_iteration is still the latest available genesis."
    return
  fi

  genesis_url="https://github.com/$ephemery_repo/releases/download/$ephemery_release/testnet-all.tar.gz"
  echo "[EphemeryWrapper] downloading genesis release: $ephemery_release  $genesis_url"

  # unpack to a staging dir first, only replace the current config once it's complete
  download_dir="$testnet_dir/.download"
  rm -rf $download_dir
  mkdir -p $download_dir

  if ! curl -k --silent -L --fail --connect-timeout 10 --max-time 600 \
    -o $download_dir/testnet-all.tar.gz "$genesis_url"; then
    echo "[EphemeryWrapper] failed to download genesis release $ephemery_release - keeping current config."
    rm -rf $download_dir
    return
  fi
  if ! tar xzf $download_dir/testnet-all.tar.gz -C $download_dir; then
    echo "[EphemeryWrapper] failed to unpack genesis release $ephemery_release - keeping current config."
    rm -rf $download_dir
    return
  fi
  rm -f $download_dir/testnet-all.tar.gz
  if [ ! -f $download_dir/retention.vars ]; then
    echo "[EphemeryWrapper] genesis release $ephemery_release is incomplete (retention.vars missing) - keeping current config."
    rm -rf $download_dir
    return
  fi

  # the `*` glob does not match the dot-prefixed staging dir
  rm -rf $testnet_dir/*
  mv $download_dir/* $testnet_dir/
  rm -rf $download_dir
}

ensure_clean_datadir() {
  data_dir="$1"
  reset_fn="$2"

  source $testnet_dir/retention.vars

  if ! [ -d $data_dir ]; then
    mkdir -p $data_dir
  fi

  if [ -f "$data_dir/ephemery.vars" ]; then
    source $data_dir/ephemery.vars
    if [ ! -z "$EPD_ITERATION"  ] && [ $EPD_ITERATION -eq $ITERATION_NUMBER ]; then
      return
    fi
  fi

  echo "[EphemeryWrapper] resetting datadir: $data_dir"
  if ! [ -z "$reset_fn" ]; then
    $reset_fn
  else
    rm -rf $data_dir/*
  fi
  echo "EPD_ITERATION=\"$ITERATION_NUMBER\"" > $data_dir/ephemery.vars

  if [ -d  "/wrapper/reset.d" ]; then
    for f in /wrapper/reset.d/*.sh; do
      source "$f" 
    done
  fi
}

