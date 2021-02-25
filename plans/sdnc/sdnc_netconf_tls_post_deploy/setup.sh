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
#
#  SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================

# @author Ajay Deep Singh (ajay.deep.singh@est.tech)

# Source SDNC, AAF-CertService, Netconf-Pnp-Simulator config env
source "${WORKSPACE}"/plans/sdnc/sdnc_netconf_tls_post_deploy/sdnc-csit.env

chmod +x "${WORKSPACE}"/tests/sdnc/sdnc_netconf_tls_post_deploy/libraries/config.sh
chmod +x "${WORKSPACE}"/tests/sdnc/sdnc_netconf_tls_post_deploy/libraries/config_tls.sh

# Export temp directory
export TEMP_DIR_PATH=${TEMP_DIR_PATH}

# Set vars with default credentials
export MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-mySecretPassword}
export MYSQL_USER=${MYSQL_USER:-sdnc}
export MYSQL_PASSWORD=${MYSQL_PASSWORD:-test123}
export MYSQL_DATABASE=${MYSQL_DATABASE:-sdncdb}
export ODL_USER=${ODL_USER:-admin}
export ODL_PASSWORD=${ODL_PASSWORD:-Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U}
export ODL_ADMIN_USER=${ODL_ADMIN_USER:-${ODL_USER}}
export ODL_ADMIN_PASSWORD=${ODL_ADMIN_PASSWORD:-${ODL_PASSWORD}}
export DMAAP_USER=${DMAAP_USER:-admin}
export DMAAP_PASSWORD=${DMAAP_PASSWORD:-admin}
export DMAAP_AUTHKEY=${DMAAP_AUTHKEY:-""}
export AAI_TRUSTSTORE_PASSWORD=${AAI_TRUSTSTORE_PASSWORD:-changeit}
export AAI_CLIENT_NAME=${AAI_CLIENT_NAME:-sdnc@sdnc.onap.org}
export AAI_CLIENT_PASSWORD=${AAI_CLIENT_PASSWORD:-demo123456!}
export ANSIBLE_TRUSTSTORE_PASSWORD=${ANSIBLE_TRUSTSTURE_PASSWORD:-changeit}
export HONEYCOMB_USER=${HONEYCOMB_USER:-admin}
export HONEYCOMB_PASSWORD=${HONEYCOMB_PASSWORD:-admin}
export TRUSTSTORE_PASSWORD=${TRUSTSTORE_PASSWORD:-changeit}
export KEYSTORE_PASSWORD=${KEYSTORE_PASSWORD:-adminadmin}
export NENG_USER=${NENG_USER:-ccsdkapps}
export NENG_PASSWORD=${NENG_PASSWORD:-ccsdkapps}
export SO_USER=${SO_USER:-sdncaBpmn}
export SO_PASSWORD=${SO_PASSWORD:-password1$}
export CDS_USER=${CDS_USER:-ccsdkapps}
export CDS_PASSWORD=${CDS_PASSWORD:-ccsdkapps}
export ANSIBLE_USER=${ANSIBLE_USER:-sdnc}
export ANSIBLE_PASSWORD=${ANSIBLE_PASSWORD:-sdnc}
export SQL_CRYPTKEY=${SQL_CRYPTKEY:-fakECryptKey}
export ASDC_USER=${ASDC_USER:-sdnc}
export ASDC_PASSWORD=${ASDC_PASSWORD:-Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U}


# Create temp directory to bind with docker containers
mkdir -m 755 -p "${WORKSPACE}"/tests/sdnc/sdnc_netconf_tls_post_deploy/certs
mkdir -m 755 -p "${WORKSPACE}"/tests/sdnc/sdnc_netconf_tls_post_deploy/cert-data

export MTU=$(/sbin/ifconfig | grep MTU | sed 's/.*MTU://' | sed 's/ .*//' | sort -n | head -1)

if [ "$MTU" == "" ]; then
  export MTU="1450"
fi

# Export default Networking bridge created on the host machine
export LOCAL_IP=$(ip -4 addr show docker0 | grep -Po 'inet \K[\d.]+')

# Prepare enviroment
echo "Uninstall docker-py and reinstall docker."
pip uninstall -y docker-py
pip uninstall -y docker
pip install -U docker==2.7.0

# Reinstall pyOpenSSL library
echo "Reinstall pyOpenSSL library."
pip uninstall pyopenssl -y
pip install pyopenssl==17.5.0

# Install PYJKS for .jks files management
pip install pyjks

# Disable Proxy - for local run
unset http_proxy https_proxy

# Export AAF Certservice config path
export AAF_INITIAL_CERTS
export EJBCA_CERTPROFILE_PATH
export AAF_CERTSERVICE_CONFIG_PATH
export AAF_CERTSERVICE_SCRIPTS_PATH
export CERT_PROFILE=${EJBCA_CERTPROFILE_PATH}
export SCRIPTS_PATH=${AAF_CERTSERVICE_SCRIPTS_PATH}
export CONFIGURATION_PATH=${AAF_CERTSERVICE_CONFIG_PATH}

# Generate Keystores, Truststores, Certificates and Keys
make all -C ./certs/

cp "${WORKSPACE}"/plans/sdnc/sdnc_netconf_tls_post_deploy/certs/root.crt "${WORKSPACE}"/tests/sdnc/sdnc_netconf_tls_post_deploy/certs/root.crt
openssl pkcs12 -in "${WORKSPACE}"/plans/sdnc/sdnc_netconf_tls_post_deploy/certs/certServiceServer-keystore.p12 -clcerts -nokeys -password pass:secret | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' >"${WORKSPACE}"/tests/sdnc/sdnc_netconf_tls_post_deploy/certs/certServiceServer.crt
openssl pkcs12 -in "${WORKSPACE}"/plans/sdnc/sdnc_netconf_tls_post_deploy/certs/certServiceServer-keystore.p12 -nocerts -nodes -password pass:secret | sed -ne '/-BEGIN PRIVATE KEY-/,/-END PRIVATE KEY-/p' >"${WORKSPACE}"/tests/sdnc/sdnc_netconf_tls_post_deploy/certs/certServiceServer.key

echo "Generated KeyStores, Server Certificate and Key"

# Start EJBCA, AAF-CertService Containers with docker-compose and configuration from docker-compose.yml
docker-compose -f "${SCRIPTS}"/sdnc/certservice/docker-compose.yml up -d

# Check if AAF-Certservice Service is healthy and ready
AAFCERT_IP='none'
for i in {1..9}; do
  AAFCERT_IP=$(get-instance-ip.sh aaf-cert-service)
  RESP_CODE=$(curl -s https://localhost:8443/actuator/health --cacert ./certs/root.crt --cert-type p12 --cert ./certs/certServiceServer-keystore.p12 --pass secret |
    python2 -c 'import json,sys;obj=json.load(sys.stdin);print obj["status"]')
  if [[ "${RESP_CODE}" == "UP" ]]; then
    echo "AAF Cert Service is Ready."
    export AAFCERT_IP=${AAFCERT_IP}
    docker exec aafcert-ejbca /opt/primekey/scripts/ejbca-configuration.sh
    break
  fi
  echo "Waiting for AAF Cert Service to Start Up..."
  sleep 2m
done

if [[ "${AAFCERT_IP}" == "none" || "${AAFCERT_IP}" == '' ||  "${RESP_CODE}" != "UP" ]]; then
  echo "AAF CertService not started Could cause problems for testing activities...!"
fi

############################## SDNC Setup ##############################

# Export Mariadb, SDNC tmp, cert directory path
export SDNC_CERT_PATH=${SDNC_CERT_PATH}

docker pull "${NEXUS_DOCKER_REPO}"/onap/sdnc-image:"${SDNC_IMAGE_TAG}"
docker tag "${NEXUS_DOCKER_REPO}"/onap/sdnc-image:"${SDNC_IMAGE_TAG}" onap/sdnc-image:latest

# Start Mariadb, SDNC Containers with docker-compose and configuration from docker-compose.yml
docker-compose -f "${SCRIPTS}"/sdnc/sdnc/docker-compose.yml up -d

# Check if SDNC Service is healthy and ready
for i in {1..10}; do
  SDNC_IP=$(get-instance-ip.sh sdnc)
  RESP_CODE=$(curl --write-out '%{http_code}' --silent --output /dev/null -H "Authorization: Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==" -X POST -H "X-FromAppId: csit-sdnc" -H "X-TransactionId: csit-sdnc" -H "Accept: application/json" -H "Content-Type: application/json" http://localhost:8282/restconf/operations/SLI-API:healthcheck)
  if [[ "${RESP_CODE}" == '200' ]]; then
    echo "SDNC Service is Ready."
    break
  fi
  echo "Waiting for SDNC Service to Start Up..."
  sleep 2m
done

if [[ "${SDNC_IP}" == 'none' || "${SDNC_IP}" == '' || "${RESP_CODE}" != '200' ]]; then
  echo "SDNC Service not started Could cause problems for testing activities...!"
fi

# Check if SDNC-ODL Karaf Session started
TIME_OUT=300
INTERVAL=10
TIME=0
while [ "$TIME" -lt "$TIME_OUT" ]; do

docker exec sdnc_controller_container cat /opt/opendaylight/data/log/karaf.log | grep 'warp coils'

  if [ $? == 0 ] ; then
    echo SDNC karaf started in $TIME seconds
    break;
  fi

  echo Sleep: $INTERVAL seconds before testing if SDNC is up. Total wait time up now is: $TIME seconds. Timeout is: $TIME_OUT seconds
  sleep $INTERVAL
  TIME=$(($TIME+$INTERVAL))
done

if [ "$TIME" -ge "$TIME_OUT" ]; then
   echo TIME OUT: karaf session not started in $TIME_OUT seconds, setup failed
   exit 1;
fi

echo "Sleeping 5 minutes"
sleep 5m

###################### Netconf-PNP-Simulator Setup ######################

# Export netconf-pnp simulator conf path
export NETCONF_CONFIG_PATH=${NETCONF_CONFIG_PATH}

# Start Netconf-Pnp-Simulator Container with docker-compose and configuration from docker-compose.yml
docker-compose -f "${SCRIPTS}"/sdnc/netconf-pnp-simulator/docker-compose.yml up -d

# Update default Networking bridge IP in mount.json file
sed -i "s/pnfaddr/${LOCAL_IP}/g" "${REQUEST_DATA_PATH}"/mount.xml

#########################################################################

echo "Sleeping additional for 3 minutes to give application time to finish"
sleep 3m

# Export SDNC, AAF-Certservice-Cient, Netconf-Pnp-Simulator Continer Names
export REQUEST_DATA_PATH="${REQUEST_DATA_PATH}"
export SDNC_CONTAINER_NAME="${SDNC_CONTAINER_NAME}"
export CLIENT_CONTAINER_NAME="${CLIENT_CONTAINER_NAME}"
export NETCONF_PNP_SIM_CONTAINER_NAME="${NETCONF_PNP_SIM_CONTAINER_NAME}"

REPO_IP='127.0.0.1'
ROBOT_VARIABLES+=" -v REPO_IP:${REPO_IP} "
ROBOT_VARIABLES+=" -v SCRIPTS:${SCRIPTS} "

echo "Finished executing setup for SDNC-Netconf-TLS-Post-Deploy"
