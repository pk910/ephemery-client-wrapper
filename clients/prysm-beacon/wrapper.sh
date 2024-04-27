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

    if [ -z "$(echo "${client_args[@]}" | grep "genesis-state")" ]; then
        ephemery_args="$ephemery_args --genesis-state=$testnet_dir/genesis.ssz"
    fi

    if [ -z "$(echo "${client_args[@]}" | grep "bootstrap-node")" ]; then
        for bootnode in ${BOOTNODE_ENR_LIST//,/ }; do
            if [ ! -z "$bootnode" ]; then
                ephemery_args="$ephemery_args --bootstrap-node=$bootnode"
            fi
        done
    fi

    echo "args: ${client_args[@]} $ephemery_args"
    /app/cmd/beacon-chain/beacon-chain ${client_args[@]} $ephemery_args
}

ephemery_wrapper "beacon-chain" "$client_datadir" "" "start_client"
