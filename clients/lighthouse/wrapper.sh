#!/bin/bash

client_datadir="~/.lighthouse"

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
    ls -A1 $client_datadir/ | grep -E -v "keys|secrets" | xargs rm -rf
    if [ -f $client_datadir/keys/slashing_protection.sqlite ]; then
        rm $client_datadir/keys/slashing_protection.sqlite
    fi
}

ephemery_wrapper "lighthouse.bin" "$client_datadir" "reset_client" "start_client"
