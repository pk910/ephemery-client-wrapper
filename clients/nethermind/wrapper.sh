#!/bin/bash

client_datadir="~/.ethereum"

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
    source $testnet_dir/retention.vars
    /nethermind/nethermind $client_args
}

ephemery_wrapper "nethermind" "$client_datadir" "" "start_client"
