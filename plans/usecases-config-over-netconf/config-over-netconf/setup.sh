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


SCRIPTS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export PARENT=usecases-config-over-netconf
export SUB_PARENT=config-over-netconf
source ${WORKSPACE}/plans/$PARENT/$SUB_PARENT/test.properties

export MTU=$(/sbin/ifconfig | grep MTU | sed 's/.*MTU://' | sed 's/ .*//' | sort -n | head -1)

if [ "$MTU" == "" ]; then
	  export MTU="1450"
fi

# clone integration branch for pnf-simulator
mkdir -m 755 -p $WORKSPACE/temp/integration
cd $WORKSPACE/temp
git clone -b dublin --single-branch --depth=1 http://gerrit.onap.org/r/integration.git integration

HOST_IP_ADDR=localhost

# setup sdnc

cd $SDNC_DOCKER_PATH
unset http_proxy https_proxy

docker pull $NETOPEER_DOCKER_REPO:$NETOPEER_IMAGE_TAG
docker tag  $NETOPEER_DOCKER_REPO:$NETOPEER_IMAGE_TAG $NETOPEER_DOCKER_REPO:latest
#sed -i "s/DMAAP_TOPIC_ENV=.*/DMAAP_TOPIC_ENV="AUTO"/g" diocker-compose.yml
docker login -u $NEXUS_USERNAME -p $NEXUS_PASSWD $NEXUS_DOCKER_REPO

docker pull $NEXUS_DOCKER_REPO/onap/sdnc-image:$SDNC_IMAGE_TAG
docker tag $NEXUS_DOCKER_REPO/onap/sdnc-image:$SDNC_IMAGE_TAG onap/sdnc-image:latest

docker pull $NEXUS_DOCKER_REPO/onap/sdnc-ansible-server-image:$ANSIBLE_IMAGE_TAG
docker tag $NEXUS_DOCKER_REPO/onap/sdnc-ansible-server-image:$ANSIBLE_IMAGE_TAG onap/sdnc-ansible-server-image:latest

docker pull $NEXUS_DOCKER_REPO/onap/ccsdk-blueprintsprocessor:$BP_IMAGE_TAG
docker tag $NEXUS_DOCKER_REPO/onap/ccsdk-blueprintsprocessor:$BP_IMAGE_TAG onap/ccsdk-blueprintsprocessor:latest

export SDNC_CERT_PATH=${CERT_SUBPATH}
#sed -i 's/sdnc_controller_container/sdnc_controller_container\n    volumes: \n      - $SDNC_CERT_PATH:\/opt\/opendaylight\/current\/certs/' docker-compose.yaml
# start SDNC containers with docker compose and configuration from docker-compose.yml
docker-compose up -d

# start pnf simulator

cd $INT_DOCKER_PATH

./simulator.sh start&

# WAIT 10 minutes maximum and test every 5 seconds if SDNC is up using HealthCheck API
TIME_OUT=1000
INTERVAL=30
TIME=0
while [ "$TIME" -lt "$TIME_OUT" ]; do
  response=$(curl --write-out '%{http_code}' --silent --output /dev/null -H "Authorization: Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==" -X POST -H "X-FromAppId: csit-sdnc" -H "X-TransactionId: csit-sdnc" -H "Accept: application/json" -H "Content-Type: application/json" http://localhost:8282/restconf/operations/SLI-API:healthcheck );
  echo $response

  if [ "$response" == "200" ]; then
    echo SDNC started in $TIME seconds
    break;
  fi

  echo Sleep: $INTERVAL seconds before testing if SDNC is up. Total wait time up now is: $TIME seconds. Timeout is: $TIME_OUT seconds
  sleep $INTERVAL
  TIME=$(($TIME+$INTERVAL))
done

export LOCAL_IP=$(ip -4 addr show docker0 | grep -Po 'inet \K[\d.]+')
sed -i "s/pnfaddr/$LOCAL_IP/g" $REQUEST_DATA_PATH/mount.xml


if [ "$TIME" -ge "$TIME_OUT" ]; then
   echo TIME OUT: karaf session not started in $TIME_OUT seconds... Could cause problems for testing activities...
fi

########################################## blueprintsprocessor setup ##########################################################
source $CDS_DOCKER_PATH/cds_setup.sh

########## update pnf simulator ip in config deploy request ########

NETOPEER_CONTAINER=$(docker ps -a -q --filter="name=netopeer")
NETOPEER_CONTAINER_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $SDNC_CONTAINER)
RES_KEY=$(uuidgen -r)
sed -i "s/pnfaddr/$LOCAL_IP/g" $REQUEST_DATA_PATH/config-deploy.json
sed -i "s/pnfaddr/$LOCAL_IP/g" $REQUEST_DATA_PATH/config-assign.json

sed -i "s/reskey/$RES_KEY/g" $REQUEST_DATA_PATH/config-deploy.json
sed -i "s/reskey/$RES_KEY/g" $REQUEST_DATA_PATH/config-assign.json

#########################check if server is up gracefully ######################################

# Sleep additional 3 minutes (180 secs) to give application time to finish

sleep 150

# Pass any variables required by Robot test suites in ROBOT_VARIABLES

ROBOT_VARIABLES="-v SCRIPTS:${SCRIPTS}"
