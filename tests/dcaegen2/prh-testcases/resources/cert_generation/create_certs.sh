#!/usr/bin/env bash

mkdir -p private certs newcerts
chmod 700 private
chmod 755 certs newcerts
touch index.txt
echo "unique_subject = no" > index.txt.attr
echo '01' > serial

openssl genrsa -out root.key 4096
openssl req -config openssl.conf -key root.key -new -x509 -days 36500 -sha256 -extensions v3_ca -subj /CN=RootCA/OU=OSAAF/O=ONAP/C=US -out root.crt

openssl genrsa -out intermediate.key 4096
openssl req -new -sha256 -key intermediate.key -out intermediate.csr -outform PEM -subj /CN=intermediate/OU=OSAAF/O=ONAP/C=US
openssl ca -batch -config openssl.conf -extensions v3_intermediate_ca -days 36500 -cert root.crt -keyfile root.key -out intermediate.crt -infiles intermediate.csr

#openssl genrsa -out aai.key 4096
cp ../simulator/certs/aai.key aai.key
openssl req -new -sha256 -key aai.key -out aai.csr -outform PEM -subj /CN=aai/OU=OSAAF/O=ONAP/C=US
openssl ca -batch -config openssl.conf -days 36500 -cert intermediate.crt -keyfile intermediate.key -out aai.crt -policy policy_loose -infiles aai.csr


#openssl genrsa -out dmaap-mr.key 4096
cp ../simulator/certs/dmaap-mr.key dmaap-mr.key
openssl req -new -sha256 -key dmaap-mr.key -out dmaap-mr.csr -outform PEM -subj /CN=dmaap-mr/OU=OSAAF/O=ONAP/C=US
openssl ca -batch -config openssl.conf -days 36500 -cert intermediate.crt -keyfile intermediate.key -out dmaap-mr.crt -policy policy_loose -infiles dmaap-mr.csr


openssl genrsa -out prh.key 4096
openssl req -new -sha256 -key prh.key -out prh.csr -outform PEM -subj /CN=prh/OU=OSAAF/O=ONAP/C=US
openssl ca -batch -config openssl.conf -extensions server_cert -days 36500 -cert intermediate.crt -keyfile intermediate.key -out prh.crt -policy policy_loose -infiles prh.csr


cat prh.crt intermediate.crt >> merged.crt

openssl pkcs12 -export -name prh-cert -in merged.crt -inkey prh.key -passout pass:$(cat ../simulator/certs/keystore.password) -out keystore.p12
keytool -import -alias intermediate-cert -file intermediate.crt -storepass $(cat ../simulator/certs/truststore.password) -keystore truststore.jks -noprompt
keytool -import -alias root-cert -file root.crt -storepass $(cat ../simulator/certs/truststore.password) -keystore truststore.jks -noprompt


cp aai.crt aai.key dmaap-mr.crt dmaap-mr.key root.crt keystore.p12 truststore.jks ../simulator/certs