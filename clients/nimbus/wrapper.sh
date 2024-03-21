#!/bin/bash

client_datadir="/home/user/build/data"

client_args=("$@")
while [[ $# -gt 0 ]]; do
    case $1 in
    --data-dir=*)
        client_datadir="${1#*=}"
        ;;
    --data-dir)
        client_datadir="${2}"
        ;;
    esac
    shift
done

source /wrapper/wrapper.lib.sh

start_client() {
    source $testnet_dir/nodevars_env.txt

    ephemery_args=""
    if [ -z "$(echo "${client_args[@]}" | grep "network")" ]; then
        ephemery_args="$ephemery_args --network=$testnet_dir"
    fi
    if [ -z "$(echo "${client_args[@]}" | grep "bootstrap-node")" ]; then
        for bootnode in ${BOOTNODE_ENR_LIST//,/ }; do
            if [ ! -z "$bootnode" ]; then
                ephemery_args="$ephemery_args --bootstrap-node=$bootnode"
            fi
        done
    fi

    echo "args: ${client_args[@]} $ephemery_args"
    cd /home/user
    /home/user/nimbus_beacon_node.bin "${client_args[@]}" $ephemery_args
}

ephemery_wrapper "nimbus_beacon_node.bin" "$client_datadir" "" "start_client"
