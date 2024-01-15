#!/bin/bash

client_datadir="~/.ethereum"

client_args="$@"
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
    besu $client_args --genesis-file=$testnet_dir/besu.json
}

ephemery_wrapper "besu" "$client_datadir" "" "start_client"
