#!/bin/bash

client_datadir="~/.local/share/lodestar"
default_datadir="$client_datadir"

client_args=("$@")
while [[ $# -gt 0 ]]; do
    case $1 in
    --dataDir=*)
        client_datadir="${1#*=}"
        ;;
    --dataDir)
        client_datadir="${2}"
        ;;
    --rcConfig=*)
        rc_file="${1#*=}"
        ;;
    --rcConfig)
        rc_file="${2}"
        ;;
    esac
    shift
done


if [[ "$client_datadir" == "$default_datadir" ]]; then
    if [ -f "$rc_file" ]; then
        rc_file_datadir=$(grep -w 'dataDir' $rc_file)
        rc_file_datadir=${rc_file_datadir##*:}
        rc_file_datadir=${rc_file_datadir// /}
        rc_file_datadir=${rc_file_datadir//[\"\']/}

        if [ -n "$rc_file_datadir" ]; then
            client_datadir="$rc_file_datadir"
        fi
    fi
fi


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
    if [ -d $client_datadir/chain-db ]; then
        echo "[EphemeryWrapper] clearing lodestar beacon chain-db"
        rm -rf $client_datadir/chain-db/*
    fi

    if [ -d $client_datadir/validator-db ]; then
        echo "[EphemeryWrapper] clearing lodestar validator validator-db"
        rm -rf $client_datadir/validator-db
    fi
}

ephemery_wrapper "node" "$client_datadir" "reset_client" "start_client"
