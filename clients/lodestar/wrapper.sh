#!/bin/bash

client_datadir="~/.local/share/lodestar"

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
    if [ -z "$(echo "${client_args[@]}" | grep "paramsFile")" ]; then
        ephemery_args="$ephemery_args --paramsFile=$testnet_dir/config.yaml"
    fi
    
    case "$(echo "${client_args[0]}")" in
        beacon)
            if [ -z "$(echo "${client_args[@]}" | grep "genesisStateFile")" ]; then
                ephemery_args="$ephemery_args --genesisStateFile=$testnet_dir/genesis.ssz"
            fi
            if [ -z "$(echo "${client_args[@]}" | grep "bootnodes")" ]; then
                ephemery_args="$ephemery_args --bootnodes=$BOOTNODE_ENR_LIST"
            fi
            ;;
    esac

    echo "args: ${client_args[@]} $ephemery_args"
    cd /usr/app
    node ./packages/cli/bin/lodestar "${client_args[@]}" $ephemery_args
}

reset_client() {
    ls -A1 $client_datadir/ | grep -E -v "keys|secrets" | xargs rm -rf
}

ephemery_wrapper "node" "$client_datadir" "reset_client" "start_client"
