#!/bin/bash
#
# ============LICENSE_START=======================================================
#   Copyright (C) 2019 Nordix Foundation.
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

# @author Rahul Tyagi (rahul.tyagi@est.tech)

SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${WORKSPACE}"/plans/usecases-config-over-netconf/config-over-netconf/test.properties

export MTU=$(/sbin/ifconfig | grep MTU | sed 's/.*MTU://' | sed 's/ .*//' | sort -n | head -1)

if [ "$MTU" == "" ]; then
  export MTU="1450"
fi

export CONFIG_OVER_NETCONF=${CONFIG_OVER_NETCONF}

# Prepare enviroment
echo "Uninstall docker-py and reinstall docker."
pip uninstall -y docker-py
pip uninstall -y docker
pip install -U docker==2.7.0

# Disable Proxy - for local run
unset http_proxy https_proxy

# Export default Networking bridge created on the host machine
export LOCAL_IP=$(ip -4 addr show docker0 | grep -Po 'inet \K[\d.]+')

###################### Netconf-PNP-Simulator Setup ######################

# Export Netconf-Pnp Simulator conf path
export NETCONF_CONFIG_PATH

# Start N etconf-Pnp-Simulator Container with docker-compose and configuration from docker-compose.yml
docker-compose -f "${CONFIG_OVER_NETCONF}"/netconf-pnp-simulator/docker-compose.yml up -d

# Update default Networking bridge IP in mount.json file
sed -i "s/pnfaddr/${LOCAL_IP}/g" "${REQUEST_DATA_PATH}"/mount.xml

############################## SDNC Setup ##############################

export SDNC_CERT_PATH="${CERT_SUBPATH}"

#docker pull "${NEXUS_DOCKER_REPO}"/onap/sdnc-image:"${SDNC_IMAGE_TAG}"
#docker tag "${NEXUS_DOCKER_REPO}"/onap/sdnc-image:"${SDNC_IMAGE_TAG}" onap/sdnc-image:latest

docker pull "${NEXUS_DOCKER_REPO}"/onap/sdnc-ansible-server-image:"${ANSIBLE_IMAGE_TAG}"
docker tag "${NEXUS_DOCKER_REPO}"/onap/sdnc-ansible-server-image:"${ANSIBLE_IMAGE_TAG}" onap/sdnc-ansible-server-image:latest

docker-compose -f "${CONFIG_OVER_NETCONF}"/sdn/docker-compose.yaml up -d

# Check if SDNC Service is healthy and ready
for i in {1..10}; do
  SDNC_IP=$(get-instance-ip.sh sdnc_controller_container)
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
for i in {1..15}; do
  EXEC_RESP=$(docker exec -it sdnc_controller_container /opt/opendaylight/current/bin/client system:start-level)
  if grep -q 'Level 100' <<<"${EXEC_RESP}"; then
    echo "SDNC-ODL Karaf Session Started."
    break
  fi
  echo "Waiting for SDNC-ODL Karaf Session to Start Up..."
  sleep 2m
done

if ! grep -q 'Level 100' <<<"${EXEC_RESP}"; then
  echo "SDNC-ODL Karaf Session not Started, Could cause problems for testing activities...!"
fi

############################## CDS Setup ##############################

docker pull "${NEXUS_DOCKER_REPO}"/onap/ccsdk-blueprintsprocessor:"${BP_IMAGE_TAG}"
docker tag "${NEXUS_DOCKER_REPO}"/onap/ccsdk-blueprintsprocessor:"${BP_IMAGE_TAG}" onap/ccsdk-blueprintsprocessor:latest

docker-compose -f "${CONFIG_OVER_NETCONF}"/cds/docker-compose.yaml up -d

echo "Sleeping 1 minute"
sleep 1m

BP_CONTAINER=$(docker ps -a -q --filter="name=bp-rest")
CCSDK_MARIADB=$(docker ps -a -q --filter="name=ccsdk-mariadb")

for i in {1..10}; do
  if [ $(docker inspect --format='{{ .State.Running }}' "${BP_CONTAINER}") ] &&
    [ $(docker inspect --format='{{ .State.Running }}' "${CCSDK_MARIADB}") ]; then
    echo "Blueprint Proc Service Running"
    break
  else
    echo sleep "${i}"
    sleep "${i}"
  fi
done

############################ Update Setup ############################

RES_KEY=$(uuidgen -r)
sed -i "s/pnfaddr/$LOCAL_IP/g" "${REQUEST_DATA_PATH}"/config-deploy.json
sed -i "s/pnfaddr/$LOCAL_IP/g" "${REQUEST_DATA_PATH}"/config-assign.json

sed -i "s/reskey/$RES_KEY/g" "${REQUEST_DATA_PATH}"/config-deploy.json
sed -i "s/reskey/$RES_KEY/g" "${REQUEST_DATA_PATH}"/config-assign.json

# Pass any variables required by Robot test suites in ROBOT_VARIABLES
REPO_IP='127.0.0.1'
ROBOT_VARIABLES+=" -v REPO_IP:${REPO_IP} "
ROBOT_VARIABLES+=" -v SCRIPTS:${SCRIPTS} "