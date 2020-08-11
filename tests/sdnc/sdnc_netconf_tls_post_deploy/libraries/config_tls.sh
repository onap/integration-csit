#!/bin/bash

# ============LICENSE_START=======================================================
#  Copyright (C) 2020 Nordix Foundation.
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
#
# SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================

set -o errexit
set -o pipefail
set -o nounset
[ "${SHELL_XTRACE:-false}" = "true" ] && set -o xtrace

CONFIG=${CONFIG:-"${WORKSPACE}"/tests/sdnc/sdnc_netconf_tls_post_deploy/cert-data}
CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}' sdnc)
ODL_URL=${ODL_URL:-http://"${CONTAINER_IP}":8282}
PROC_NAME=${0##*/}
PROC_NAME=${PROC_NAME%.sh}

function now_ms() {
    # Requires coreutils package
    date +"%Y-%m-%d %H:%M:%S.%3N"
}

function log() {
    local level=$1
    shift
    local message="$*"
    printf "%s %-5s [%s] %s\n" "$(now_ms)" $level $PROC_NAME "$message"
}

# Extracts the body of a PEM file by removing the dashed header and footer
pem_body() {
    grep -Fv -- ----- $1
}

CA_CERT_ID=xNF_CA_certificate_0_0
CA_CERT=$(pem_body $CONFIG/truststore.pem)

SERVER_PRIV_KEY_ID=ODL_private_key_0
SERVER_KEY=$(pem_body $CONFIG/key.pem)
SERVER_CERT=$(pem_body $CONFIG/keystore.pem)

RESTCONF_URL=$ODL_URL/restconf
NETCONF_KEYSTORE_PATH=$RESTCONF_URL/config/netconf-keystore:keystore

xcurl() {
    curl -s -o /dev/null -H "Authorization: Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==" -w %{http_code} "$@"
}

log INFO Delete Keystore
sc=$(xcurl -X DELETE $NETCONF_KEYSTORE_PATH)

if [ "$sc" != "200" -a "$sc" != "404" ]; then
    log ERROR "Keystore deletion failed with SC=$sc"
    exit 1
fi

log INFO Load CA certificate
sc=$(xcurl -X POST $NETCONF_KEYSTORE_PATH --header "Content-Type: application/json" --data "
{
  \"trusted-certificate\": [
    {
      \"name\": \"$CA_CERT_ID\",
      \"certificate\": \"$CA_CERT\"
    }
  ]
}
")

if [ "$sc" != "200" -a "$sc" != "204" ]; then
    log ERROR Trusted-certificate update failed with SC=$sc
    exit 1
fi

log INFO Load server private key and certificate
sc=$(xcurl -X POST $NETCONF_KEYSTORE_PATH --header "Content-Type: application/json" --data "
{
  \"private-key\": {
    \"name\": \"$SERVER_PRIV_KEY_ID\",
    \"certificate-chain\": [
      \"$SERVER_CERT\"
    ],
    \"data\": \"$SERVER_KEY\"
  }
}
")

if [ "$sc" != "200" -a "$sc" != "204" ]; then
    log ERROR Private-key update failed with SC=$sc
    exit 1
fi