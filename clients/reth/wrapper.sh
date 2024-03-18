#!/bin/bash

client_datadir="~/.local/share/reth"

client_args=("$@")
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
    if [ -z "$(echo "${client_args[@]}" | grep "chain")" ]; then
        ephemery_args="$ephemery_args --chain=$testnet_dir/genesis.json"
    fi
    if [ -z "$(echo "${client_args[@]}" | grep "bootnodes")" ]; then
        ephemery_args="$ephemery_args --bootnodes=$BOOTNODE_ENODE_LIST"
    fi

    echo "args: ${client_args[@]} $ephemery_args"
    /usr/local/bin/reth "${client_args[@]}" $ephemery_args
}

ephemery_wrapper "reth" "$client_datadir" "" "start_client"
