#!/bin/sh

ephemery_repo="ephemery-testnet/ephemery-genesis"
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

  ephemery_release=$(curl -k --silent "https://api.github.com/repos/$ephemery_repo/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/' |
    head -n 1)
  
  if [ -z "$ephemery_release" ]; then
    echo "[EphemeryWrapper] could not get latest genesis release version."
  fi
  if [ ! -z "$stored_iteration" ] && [ "$stored_iteration" == "$ephemery_release" ]; then
    echo "[EphemeryWrapper] cannot load new genesis release, iteration $stored_iteration is still the latest available genesis."
    return
  fi

  echo "[EphemeryWrapper] downloading genesis release: $ephemery_release  https://github.com/$ephemery_repo/releases/download/$ephemery_release/testnet-all.tar.gz"

  rm -rf $testnet_dir/*
  curl -k --silent -L https://github.com/$ephemery_repo/releases/download/$ephemery_release/testnet-all.tar.gz | tar xz -C $testnet_dir
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

