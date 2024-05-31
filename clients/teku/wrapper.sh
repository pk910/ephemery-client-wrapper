#!/bin/bash

client_datadir="~/.local/share/teku"

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
    if [ -z "$(echo "${client_args[@]}" | grep "--network")" ]; then
        ephemery_args="$ephemery_args --network=$testnet_dir/config.yaml"
    fi
    
    case "$(echo "${client_args[0]}")" in
        validator-client)
            ;;
        *)
            if [ -z "$(echo "${client_args[@]}" | grep "genesis-state")" ]; then
                ephemery_args="$ephemery_args --genesis-state=$testnet_dir/genesis.ssz"
            fi
            if [ -z "$(echo "${client_args[@]}" | grep "p2p-discovery-bootnodes")" ]; then
                ephemery_args="$ephemery_args --p2p-discovery-bootnodes=$BOOTNODE_ENR_LIST"
            fi
            ;;
    esac

    echo "args: ${client_args[@]} $ephemery_args"
    /opt/teku/bin/teku "${client_args[@]}" $ephemery_args
}

reset_client() {
    if [ -d $client_datadir/beacon ]; then
        echo "[EphemeryWrapper] clearing teku beacon data"
        # retain kvstore (persist node key & enr metadata)
        mv $client_datadir/beacon/kvstore $client_datadir/kvstore.bak
        rm -rf $client_datadir/beacon/*
        mv $client_datadir/kvstore.bak $client_datadir/beacon/kvstore
    fi
    if [ -d $client_datadir/logs ]; then
        rm -rf $client_datadir/logs
    fi
    if [ -d $client_datadir/validator/slashprotection ]; then
        echo "[EphemeryWrapper] clearing teku validator slashprotection"
        rm -rf $client_datadir/validator/slashprotection
    fi
}

ephemery_wrapper "java" "$client_datadir" "reset_client" "start_client"
