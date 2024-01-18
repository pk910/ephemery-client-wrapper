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
    source $testnet_dir/retention.vars
    erigon $client_args --networkid=$CHAIN_ID
}

reset_client() {
    rm -rf $client_datadir/*
    erigon init --datadir=$client_datadir $testnet_dir/genesis.json
}

ephemery_wrapper "erigon" "$client_datadir" "reset_client" "start_client"
