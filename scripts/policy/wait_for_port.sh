#!/bin/bash

tmout=120
cmd=

while getopts c:t: opt; do
    case "$opt" in
    c) cmd="$OPTARG" ;;
    t) tmout="$OPTARG" ;;
    esac
done
let nargs=$OPTIND-1
shift $nargs

let even_args=$#%2
if [[ $# -lt 2 || $even_args -ne 0 ]]; then
    echo "args: [-t timeout] [-c command] hostname1 port1 hostname2 port2 ..." >&2
    exit 1
fi

while [[ $# -ge 2 ]]; do
    export host=$1
    export port=$2
    shift
    shift

    echo "Waiting for $host port $port..."
    timeout $tmout bash -c 'until nc -vz "$host" "$port"; do echo -n ".";
        sleep 1; done'
    rc=$?

    if [[ $rc != 0 ]]; then
        echo "$host port $port cannot be reached"
        exit $rc
    fi
done

$cmd

exit 0
