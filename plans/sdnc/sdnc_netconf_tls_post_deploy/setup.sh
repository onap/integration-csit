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

###################### Netconf Simulator Setup ######################

# Get integration/simulators
if [ -d ${SCRIPTS}/sdnc/pnf-simulator ]
then
    rm -rf ${SCRIPTS}/sdnc/pnf-simulator
fi
mkdir ${SCRIPTS}/sdnc/pnf-simulator
git clone "https://gerrit.onap.org/r/integration/simulators/pnf-simulator" ${SCRIPTS}/sdnc/pnf-simulator

# Fix docker-compose to add nexus repo for onap dockers 
mv ${SCRIPTS}/sdnc/pnf-simulator/netconfsimulator/docker-compose.yml ${SCRIPTS}/sdnc/pnf-simulator/netconfsimulator/docker-compose.yml.orig
cat ${SCRIPTS}/sdnc/pnf-simulator/netconfsimulator/docker-compose.yml.orig | sed -e "s/image: onap/image: nexus3.onap.org:10001\/onap/" > ${SCRIPTS}/sdnc/pnf-simulator/netconfsimulator/docker-compose.yml

# Remove carriage returns (if any) from netopeer start script
mv ${SCRIPTS}/sdnc/pnf-simulator/netconfsimulator/netconf/initialize_netopeer.sh ${SCRIPTS}/sdnc/pnf-simulator/netconfsimulator/netconf/initialize_netopeer.sh.orig
cat ${SCRIPTS}/sdnc/pnf-simulator/netconfsimulator/netconf/initialize_netopeer.sh.orig | sed -e "s/\r$//g" > ${SCRIPTS}/sdnc/pnf-simulator/netconfsimulator/netconf/initialize_netopeer.sh
chmod 755 ${SCRIPTS}/sdnc/pnf-simulator/netconfsimulator/netconf/initialize_netopeer.sh


# Start Netconf Simulator Container with docker-compose and configuration from docker-compose.yml
docker-compose -f "${SCRIPTS}"/sdnc/pnf-simulator/netconfsimulator/docker-compose.yml up -d

# Add test user in netopeer container
sleep 60
docker exec netconfsimulator_netopeer_1 useradd --system test


############################## SDNC Setup ##############################

# Copy client certs from netconf simulator to SDNC certs directory
mkdir /tmp/keys0
cp ${SCRIPTS}/sdnc/pnf-simulator/netconfsimulator/tls/client.crt /tmp/keys0
cp ${SCRIPTS}/sdnc/pnf-simulator/netconfsimulator/tls/client.key /tmp/keys0
cp ${SCRIPTS}/sdnc/pnf-simulator/netconfsimulator/tls/ca.crt /tmp/keys0/trustedCertificates.crt
cwd=$(pwd)
cd /tmp
zip -r $SDNC_CERT_PATH/keys0.zip keys0
rm -rf /tmp/keys0

# Export Mariadb, SDNC tmp, cert directory path
export SDNC_CERT_PATH=${SDNC_CERT_PATH}

docker pull "${NEXUS_DOCKER_REPO}"/onap/sdnc-image:"${SDNC_IMAGE_TAG}"
docker tag "${NEXUS_DOCKER_REPO}"/onap/sdnc-image:"${SDNC_IMAGE_TAG}" onap/sdnc-image:latest

# Fix permissions on certs directory to guarantee directory is read/
# writable and that files are readable
chmod ugo+rwx ${SCRIPTS}/sdnc/sdnc/certs
chmod ugo+r ${SCRIPTS}/sdnc/sdnc/certs/*

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

  docker exec sdnc cat /opt/opendaylight/data/log/karaf.log | grep 'warp coils'

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
