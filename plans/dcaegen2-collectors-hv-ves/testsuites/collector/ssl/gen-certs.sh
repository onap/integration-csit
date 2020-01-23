#!/usr/bin/env bash
# ============LICENSE_START=======================================================
# csit-dcaegen2-collectors-hv-ves
# ================================================================================
# Copyright (C) 2018 NOKIA
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============LICENSE_END=========================================================


set -eu -o pipefail -o xtrace

STORE_PASS=onaponap
CN_PREFIX=dcaegen2-hvves
DNAME_PREFIX="C=PL,ST=DL,L=Wroclaw,O=Nokia,OU=MANO,CN=${CN_PREFIX}"

store_opts="-storetype PKCS12 -storepass ${STORE_PASS} -noprompt"

function gen_key() {
  local key_name="$1"
  local ca="$2"
  local keystore="-keystore ${key_name}.p12 ${store_opts}"
  keytool -genkey -alias ${key_name} \
      ${keystore} \
      -keyalg RSA \
      -validity 730 \
      -keysize 2048 \
      -dname "${DNAME_PREFIX}-${key_name}"
  keytool -import -trustcacerts -alias ${ca} -file ${ca}.crt ${keystore}

  keytool -certreq -alias ${key_name} -keyalg RSA ${keystore} | \
      keytool -alias ${ca} -gencert -ext "san=dns:${CN_PREFIX}-${ca}" ${store_opts} -keystore ${ca}.p12 | \
      keytool -alias ${key_name} -importcert ${keystore}

  printf ${STORE_PASS} > ${key_name}.pass
}


function gen_ca() {
  local ca="$1"
  keytool -genkeypair ${store_opts} -alias ${ca} -dname "${DNAME_PREFIX}-${ca}" -keystore ${ca}.p12 -ext bc:c
  keytool -export -alias ${ca} -file ${ca}.crt ${store_opts} -keystore ${ca}.p12
}

function gen_truststore() {
  local name="$1"
  local trusted_ca="$2"
  keytool -import -trustcacerts -alias ca -file ${trusted_ca}.crt ${store_opts} -keystore ${name}.p12
  printf ${STORE_PASS} > ${name}.pass
}

function clean() {
  rm -f *.crt *.p12 *.pass
}

if [[ $# -eq 0 ]]; then
  gen_ca ca
  gen_ca untrustedca
  gen_truststore trust ca
  gen_truststore untrustedtrust untrustedca
  gen_key client ca
  gen_key server ca
  gen_key untrustedclient untrustedca
elif [[ $1 == "clean" ]]; then
  clean
else
  echo "usage: $0 [clean]"
  exit 1
fi
