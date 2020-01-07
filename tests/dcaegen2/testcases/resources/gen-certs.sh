#!/bin/bash

WS=$1
dir=$WS/tests/dcaegen2/testcases/assets/certs

openssl genrsa -out "$dir/temporary.key" 2048

openssl req -new -key "$dir/temporary.key" -subj "/C=PL/ST=DL/O=Nokia/CN=dcaegen2" -out "$dir/temporary.csr"

openssl x509 -req -in "$dir/temporary.csr" -CA "$dir/rootCA.crt" -CAkey "$dir/rootCA.key" -passin pass:collector -CAcreateserial -out "$dir/temporary.crt" -days 1 -sha256
