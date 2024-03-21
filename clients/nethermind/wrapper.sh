#!/bin/bash

client_datadir="~/.ethereum"

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
    if [ -z "$(echo "${client_args[@]}" | grep "Init.ChainSpecPath")" ]; then
        ephemery_args="$ephemery_args --Init.ChainSpecPath=$testnet_dir/chainspec.json"
    fi
    if [ -z "$(echo "${client_args[@]}" | grep "Init.GenesisHash")" ]; then
        ephemery_args="$ephemery_args --Init.GenesisHash=$GENESIS_BLOCK"
    fi
    if [ -z "$(echo "${client_args[@]}" | grep "config")" ]; then
        ephemery_args="$ephemery_args --config=none.cfg"
    fi
    if [ -z "$(echo "${client_args[@]}" | grep "Discovery.Bootnodes")" ]; then
        ephemery_args="$ephemery_args --Discovery.Bootnodes=$BOOTNODE_ENODE_LIST"
    fi

    echo "args: ${client_args[@]} $ephemery_args"
    /nethermind/nethermind ${client_args[@]} $ephemery_args
}

ephemery_wrapper "nethermind" "$client_datadir" "" "start_client"
