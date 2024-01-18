#!/bin/bash

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
    /app/cmd/validator/validator $client_args
}

ephemery_wrapper "validator" "$client_datadir" "" "start_client"
