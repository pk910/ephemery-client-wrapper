#!/bin/bash

client_datadir="~/.ethereum"

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
    if [ -z "$(echo "${client_args[@]}" | grep "networkid")" ]; then
        ephemery_args="$ephemery_args --networkid=$CHAIN_ID"
    fi
    if [ -z "$(echo "${client_args[@]}" | grep "bootnodes")" ]; then
        ephemery_args="$ephemery_args --bootnodes=$BOOTNODE_ENODE_LIST"
    fi

    echo "args: ${client_args[@]} $ephemery_args"
    geth "${client_args[@]}" $ephemery_args
}

reset_client() {
    if [ -d $client_datadir/geth ]; then
        echo "[EphemeryWrapper] clearing geth data"

        # retain node key
        mv $client_datadir/geth/nodekey $client_datadir/nodekey.bak
        rm -rf $client_datadir/geth/*
        mv $client_datadir/nodekey.bak $client_datadir/geth/nodekey
    fi

    geth init --datadir=$client_datadir $testnet_dir/genesis.json
}

ephemery_wrapper "geth" "$client_datadir" "reset_client" "start_client"
