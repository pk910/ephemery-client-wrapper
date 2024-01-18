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
    /nethermind/nethermind $client_args --Init.ChainSpecPath=$testnet_dir/chainspec.json --Discovery.Bootnodes=$BOOTNODE_ENODE_LIST
}

ephemery_wrapper "nethermind" "$client_datadir" "" "start_client"
