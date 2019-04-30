#!/bin/bash

if [[ $# -ne 2 ]]; then
	echo "Usage: wait-for-port hostname port" >&2
	exit 1
fi

host=$1
port=$2

echo "Waiting for $host port $port open"
timeout 120 bash -c 'until nc -vz "$host" "$port"; do echo -n "."; sleep 1; done'
rc=$?

if [[ $rc != 0 ]]; then
        echo "$host port $port cannot be reached"
        exit $rc
fi

echo "$host port $port is open"
exit 0
