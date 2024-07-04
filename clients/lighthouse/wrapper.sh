#!/bin/bash

client_datadir="~/.lighthouse"
client_keydir=""

client_args=("$@")
while [[ $# -gt 0 ]]; do
    case $1 in
    --datadir=*)
        client_datadir="${1#*=}"
        ;;
    --datadir)
        client_datadir="${2}"
        ;;
    --validators-dir=*)
        client_keydir="${1#*=}"
        ;;
    --validators-dir)
        client_keydir="${2}"
        ;;
    esac
    shift
done

source /wrapper/wrapper.lib.sh

start_client() {
    source $testnet_dir/nodevars_env.txt

    ephemery_args=""
    if [ -z "$(echo "${client_args[@]}" | grep "testnet-dir")" ]; then
        ephemery_args="$ephemery_args --testnet-dir=$testnet_dir"
    fi
    
    case "$(echo "$client_args[0]")" in
        b|bn|beacon|beacon_node)
            if [ -z "$(echo "${client_args[@]}" | grep "boot-nodes")" ]; then
                ephemery_args="$ephemery_args --boot-nodes=$BOOTNODE_ENR_LIST"
            fi
            ;;
    esac

    echo "args: ${client_args[@]} $ephemery_args"
    lighthouse.bin "${client_args[@]}" $ephemery_args
}

reset_client() {
    if [ -d $client_datadir/beacon ]; then
        echo "[EphemeryWrapper] clearing lighthouse beacon data"
        # retain network metadata (persist node key & enr metadata)
        mv $client_datadir/beacon/network $client_datadir/network.bak
        rm -rf $client_datadir/beacon/*
        mv $client_datadir/network.bak $client_datadir/beacon/network
    fi

    keydir="$client_keydir"
    if [ -z "$keydir" ]; then
        keydir="$client_datadir/keys"
    fi

    if [ -f $keydir/slashing_protection.sqlite ]; then
        echo "[EphemeryWrapper] clearing lighthouse validator slashing protection"
        rm $keydir/slashing_protection.sqlite
    fi
}

ephemery_wrapper "lighthouse.bin" "$client_datadir" "reset_client" "start_client"
