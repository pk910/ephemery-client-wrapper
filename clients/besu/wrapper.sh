#!/bin/bash

client_datadir="~/.ethereum"

client_args=("$@")
while [[ $# -gt 0 ]]; do
    case $1 in
    --data-path=*)
        client_datadir="${1#*=}"
        ;;
    --data-path)
        client_datadir="${2}"
        ;;
    esac
    shift
done

source /wrapper/wrapper.lib.sh

start_client() {
    source $testnet_dir/nodevars_env.txt

    ephemery_args=""
    if [ -z "$(echo "${client_args[@]}" | grep "genesis-file")" ]; then
        ephemery_args="$ephemery_args --genesis-file=$testnet_dir/besu.json"
    fi
    if [ -z "$(echo "${client_args[@]}" | grep "bootnodes")" ]; then
        ephemery_args="$ephemery_args --bootnodes=$BOOTNODE_ENODE_LIST"
    fi

    echo "args: ${client_args[@]} $ephemery_args"
    besu "${client_args[@]}" $ephemery_args
}

ephemery_wrapper "java" "$client_datadir" "" "start_client"
