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
    if [ -z "$(echo "${client_args[@]}" | grep "bootnodes")" ]; then
        ephemery_args="$ephemery_args --bootnodes=$BOOTNODE_ENODE_LIST"
    fi

    echo "args: ${client_args[@]} $ephemery_args"
    node /usr/app/packages/client/dist/esm/bin/cli.js  --dataDir=$client_datadir --gethGenesis=$testnet_dir/genesis.json --rpcEngine --rpcEngineAddr 0.0.0.0 --jwtSecret=/execution-auth.jwt "${client_args[@]}" $ephemery_args
}

reset_client() {
    if [ -d $client_datadir ]; then
        echo "[EphemeryWrapper] clearing ethjs data"
    fi

    node /usr/app/packages/client/dist/esm/bin/cli.js --dataDir=$client_datadir --gethGenesis=$testnet_dir/genesis.json --rpcEngine --rpcEngineAddr 0.0.0.0 --jwtSecret=/execution-auth.jwt
}

ephemery_wrapper "$client_datadir" "reset_client" "start_client"
