#!/bin/bash
#
# ============LICENSE_START=======================================================
#   Copyright (C) 2020 Nordix Foundation.
# ================================================================================
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#  SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================

# @author Ajay Deep Singh (ajay.deep.singh@est.tech)

OWNER="odl"
DEST_DIR="/tmp"
CONTAINER_NAME="$1" # Input Container_Name
CONTAINER_ID=$(docker inspect --format="{{.Id}}" "$CONTAINER_NAME") # Extract Container_Id
CERT_DIR="${WORKSPACE}"/tests/sdnc/sdnc_netconf_tls_post_deploy/cert-data/*

# Copy [keystore.jks, truststore.jks, truststore.pass, keystore.pass] files into SDNC container.
function docker_cp() {
  local file=$1
  docker cp "$file" "$CONTAINER_ID":"$DEST_DIR"
  docker exec -u 0 "$CONTAINER_ID" chown "$OWNER":"$OWNER" "$DEST_DIR"/"${file##*/}"
}

# Run installCerts.py script to push X509 Certificates to SDNC-ODL Keystore/Truststore.
function sdnc_conf() {
  for file in $CERT_DIR; do
    if [[ -f $file ]]; then
      docker_cp "$file"
    fi
  done
  sleep 1m
  if ! docker exec -it "$CONTAINER_ID" /usr/bin/python /opt/onap/sdnc/bin/installCerts.py; then
    exit 1 # Return error code
  fi
}

# Copy [Server_key.pem, Server_cert.pem, Ca.pem] files into Netconf-Simulator container.
# Reconfigure TLS config by invoking reconfigure-tls.sh script.
function netconf-simulator_conf() {
  for file in $CERT_DIR; do
    if [[ -f $file && ${file: -4} == ".pem" ]]; then
      docker cp "$file" "$CONTAINER_ID":/config/tls
    fi
  done
  sleep 1m
  if ! docker exec -it "$CONTAINER_ID" /opt/bin/reconfigure-tls.sh; then
    exit 1 # Return error code
  fi
}

# Push Config on SDNC, Netconf-Simulator.
if [[ -n $CONTAINER_ID ]]; then
  if [[ "$CONTAINER_NAME" == "sdnc" ]]; then
    sdnc_conf
  elif [[ "$CONTAINER_NAME" == "netconf-simulator" ]]; then
    netconf-simulator_conf
  fi
fi
