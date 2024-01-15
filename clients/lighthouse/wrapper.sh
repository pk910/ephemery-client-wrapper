#!/bin/bash

client_datadir="~/.lighthouse"

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
    lighthouse.bin $client_args
}

reset_client() {
    rm -rf $client_datadir/*
}

ephemery_wrapper "lighthouse.bin" "$client_datadir" "reset_client" "start_client"
