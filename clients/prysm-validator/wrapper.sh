#!/bin/bash

# prysm image has limited shell support
# extend $PATH to include some additional shell binaries the wrapper uses
export PATH=$PATH:/wrapper/bin/

# override /bin/expr as it's broken in prysm image
expr() {
    /wrapper/bin/expr "$@"
}

client_datadir="~/.eth2"

client_args="$@"
while [[ $# -gt 0 ]]; do
    case $1 in
    --datadir=*)
        client_datadir="${1#*=}"
        ;;
    --datadir)
        client_datadir="${2}"
        ;;
    esac
    shift
done

source /wrapper/wrapper.lib.sh

start_client() {
    source $testnet_dir/nodevars_env.txt
    ephemery_args=""
    
    if [ -z "$(echo "${client_args[@]}" | grep "chain-config-file")" ]; then
        ephemery_args="$ephemery_args --chain-config-file=$testnet_dir/config.yaml"
    fi

    echo "args: ${client_args[@]} $ephemery_args"
    /app/cmd/validator/validator ${client_args[@]} $ephemery_args
}

ephemery_wrapper "validator" "$client_datadir" "" "start_client"
