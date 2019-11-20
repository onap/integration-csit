#!/bin/bash

WS=$1
dir=$WS/tests/dcaegen2/testcases/assets/certs

rm "$dir/temporary.crt" "$dir/temporary.csr" "$dir/temporary.key" "$dir/rootCA.srl"