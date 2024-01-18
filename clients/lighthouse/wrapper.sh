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
    ls -A1 $client_datadir/ | grep -E -v "keys|secrets" | xargs rm -rf
    if [ -f $client_datadir/keys/slashing_protection.sqlite ]; then
        rm $client_datadir/keys/slashing_protection.sqlite
    fi
}

ephemery_wrapper "lighthouse.bin" "$client_datadir" "" "start_client"
