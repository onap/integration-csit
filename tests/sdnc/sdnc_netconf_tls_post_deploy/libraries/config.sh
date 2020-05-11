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

CONTAINER_NAME="$1"
LOGFILE="${WORKSPACE}"/archives/config.log
CONTAINER_ID=$(docker inspect --format="{{.Id}}" "$CONTAINER_NAME")

OWNER="odl"
DEST_DIR="/tmp"

CERT_DIR="${WORKSPACE}"/tests/sdnc/sdnc_netconf_tls_post_deploy/cert-data/*

function now_ms() {
  date +"%Y-%m-%d %H:%M:%S.%3N"
}

function log() {
  local level=$1
  shift
  local message="$*"
  printf "%s %-5s %s\n" "$(now_ms)" "$level" "$message" >>"$LOGFILE"
}

# Copy [keystore.jks, truststore.jks, truststore.pass, keystore.pass] files into SDNC container.
function docker_cp() {
  local file=$1
  docker cp "$file" "$CONTAINER_ID":"$DEST_DIR"
  docker exec -u 0 "$CONTAINER_ID" chown "$OWNER":"$OWNER" "$DEST_DIR"/"${file##*/}"
}

# Run installCerts.py script to push X509 Certificates to SDNC-ODL Keystore/Truststore.
function sdnc_conf() {
  log INFO "Configuring SDNC-ODL Keystore..."
  count=0
  exit_code=false
  for i in {1..4}; do
    for file in $CERT_DIR; do
      if [[ -f $file ]]; then
        log INFO "Uploading file :" "$file"
        docker_cp "$file"
        count=$((count + 1))
      fi
    done
    if [[ $count -eq 4 ]]; then
      log INFO "SDNC JKS files upload successful"
      exit_code=true
      break
    fi
    log DEBUG "Waiting for JKS files to be uploaded to SDNC container.."
    sleep 2m
  done
  if [[ "$exit_code" != "true" ]]; then
    log DEBUG "JKS files Not found in $CERT_DIR"
    exit 1 # Return error code
  fi
  sleep 2m
  docker exec "$CONTAINER_ID" rm -rf /tmp/certs.properties
  docker exec "$CONTAINER_ID" rm -rf /tmp/keys0.zip
  if ! docker exec "$CONTAINER_ID" /usr/bin/python /opt/onap/sdnc/bin/installCerts.py; then
    log DEBUG "Issue executing installCerts.py script"
    docker cp "$CONTAINER_ID":/opt/opendaylight/data/log/installCerts.log "${WORKSPACE}"/archives
    exit 1 # Return error code
  fi
  log INFO "Configuring SDNC-ODL Keystore successful"
}

# Copy [Server_key.pem, Server_cert.pem, Ca.pem] files into Netconf-Simulator container.
# Reconfigure TLS config by invoking reconfigure-tls.sh script.
function netconf-simulator_conf() {
  log INFO "Configuring Netconf-Pnp-Simulator..."
  count=0
  exit_code=false
  for i in {1..4}; do
    for file in $CERT_DIR; do
      if [[ -f $file && ${file: -4} == ".pem" ]]; then
        log INFO "Uploading file :" "$file"
        docker cp "$file" "$CONTAINER_ID":/config/tls
        count=$((count + 1))
      fi
    done
    if [[ $count -eq 3 ]]; then
      log INFO "PEM files upload successful"
      exit_code=true
      break
    fi
    log DEBUG "Waiting for PEM files to be uploaded to Netconf-Pnp-Simulator.."
    sleep 2m
  done
  if [[ "$exit_code" != "true" ]]; then
    log DEBUG "PEM files Not found in $CERT_DIR"
    exit 1 # Return error code
  fi
  sleep 2m
  if ! docker exec "$CONTAINER_ID" /opt/bin/reconfigure-tls.sh; then
    log DEBUG "Issue executing reconfigure-tls.sh script"
    docker logs "$CONTAINER_ID" > "${WORKSPACE}"/archives/simulator.log
    exit 1 # Return error code
  fi
  log INFO "Configuring Netconf-Pnp-Simulator successful"
}

# Push Config on SDNC, Netconf-Simulator.
if [[ -n $CONTAINER_ID ]]; then
  log INFO "Container Name: $CONTAINER_NAME, Container Id: $CONTAINER_ID"
  if [[ "$CONTAINER_NAME" == "sdnc" ]]; then
    sdnc_conf
  elif [[ "$CONTAINER_NAME" == "netconf-simulator" ]]; then
    netconf-simulator_conf
  fi
fi
