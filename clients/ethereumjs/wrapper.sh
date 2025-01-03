#!/bin/bash

client_datadir="~/.ethereum"

client_args=("$@")
while [[ $# -gt 0 ]]; do
    case $1 in
    --dataDir=*)
        client_datadir="${1#*=}"
        ;;
    --dataDir)
        client_datadir="${2}"
        ;;
    esac
    shift
done

source /wrapper/wrapper.lib.sh

start_client() {
    source $testnet_dir/nodevars_env.txt

    ephemery_args=""
    if [ -z "$(echo "${client_args[@]}" | grep "bootnodes")" ]; then
        ephemery_args="$ephemery_args --bootnodes=$BOOTNODE_ENODE_LIST"
    fi
    if [ -z "$(echo "${client_args[@]}" | grep "gethGenesis")" ]; then
        ephemery_args="$ephemery_args --gethGenesis=$testnet_dir/genesis.json"
    fi
    if [ -z "$(echo "${client_args[@]}" | grep "jwtSecret")" ]; then
        ephemery_args="$ephemery_args --jwtSecret=/execution-auth.jwt"
    fi

    echo "args: ${client_args[@]} $ephemery_args"
    node /usr/app/packages/client/dist/esm/bin/cli.js  "${client_args[@]}" $ephemery_args
}

reset_client() {
    if [ -d $client_datadir ]; then
        echo "[EphemeryWrapper] clearing ethjs data"
    fi

    rm -rf $client_datadir
}

ephemery_wrapper node "$client_datadir" "reset_client" "start_client"
