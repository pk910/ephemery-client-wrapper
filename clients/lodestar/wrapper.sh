#!/bin/bash

client_datadir="~/.local/share/lodestar"

client_args="$@"
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
    cd /usr/app
    node ./packages/cli/bin/lodestar $client_args
}

reset_client() {
    ls -A1 $client_datadir/ | grep -E -v "keys|secrets" | xargs rm -rf
}

ephemery_wrapper "node" "$client_datadir" "reset_client" "start_client"
