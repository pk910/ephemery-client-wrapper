#!/bin/bash

client_datadir="$HOME/.local/share/erigon"

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

has_arg() {
    for arg in "${client_args[@]}"; do
        if [ "$arg" == "$1" ] || [[ "$arg" == "$1="* ]]; then
            return 0
        fi
    done
    return 1
}

start_client() {
    source $testnet_dir/nodevars_env.txt

    ephemery_args=""
    if [ -z "$(echo "${client_args[@]}" | grep "networkid")" ]; then
        ephemery_args="$ephemery_args --networkid=$CHAIN_ID"
    fi
    if [ -z "$(echo "${client_args[@]}" | grep "chain")" ]; then
        ephemery_args="$ephemery_args --chain=dev"
    fi
    if [ -z "$(echo "${client_args[@]}" | grep "bootnodes")" ]; then
        ephemery_args="$ephemery_args --bootnodes=$BOOTNODE_ENODE_LIST"
    fi
    # --chain=dev is required to run on the custom ephemery genesis, but erigon then also starts its
    # embedded dev consensus layer, listens on a random port and disables peer discovery entirely.
    # discovery cannot be re-enabled, so the bootnodes are dialed as static peers instead.
    if ! has_arg "--externalcl"; then
        ephemery_args="$ephemery_args --externalcl"
    fi
    if ! has_arg "--port"; then
        ephemery_args="$ephemery_args --port=30303"
    fi
    if ! has_arg "--staticpeers"; then
        ephemery_args="$ephemery_args --staticpeers=$BOOTNODE_ENODE_LIST"
    fi

    echo "args: ${client_args[@]} $ephemery_args"
    erigon "${client_args[@]}" $ephemery_args
}

reset_client() {
    rm -rf $client_datadir/*
    erigon init --datadir=$client_datadir $testnet_dir/genesis.json
}

ephemery_wrapper "erigon" "$client_datadir" "reset_client" "start_client"
