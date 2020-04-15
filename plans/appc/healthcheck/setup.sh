#!/bin/bash
#
# Copyright 2016-2017 Huawei Technologies Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Modifications copyright (c) 2017 AT&T Intellectual Property
#
# Place the scripts in run order:
SCRIPTS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${WORKSPACE}/scripts/appc/script1.sh

export APPC_DOCKER_IMAGE_VERSION=1.7.2-SNAPSHOT-latest
export DGBUILDER_DOCKER_IMAGE_VERSION=0.6.0
export ANSIBLE_DOCKER_IMAGE_VERSION=0.4.4
export BRANCH=master
export SOLUTION_NAME=onap

export NEXUS_USERNAME=docker
export NEXUS_PASSWD=docker
export NEXUS_DOCKER_REPO=nexus3.onap.org:10001
export DMAAP_TOPIC=AUTO

export MTU=$(/sbin/ifconfig | grep MTU | sed 's/.*MTU://' | sed 's/ .*//' | sort -n | head -1)

if [ "$MTU" == "" ]; then
	  export MTU="1450"
fi


# Clone APPC repo to get docker-compose for APPC
mkdir -p $WORKSPACE/archives/appc
cd $WORKSPACE/archives
git clone -b $BRANCH --single-branch http://gerrit.onap.org/r/appc/deployment.git appc
cd $WORKSPACE/archives/appc
git pull
cd $WORKSPACE/archives/appc/docker-compose
sed -i "s/DMAAP_TOPIC_ENV=.*/DMAAP_TOPIC_ENV="$DMAAP_TOPIC"/g" docker-compose.yml
docker login -u $NEXUS_USERNAME -p $NEXUS_PASSWD $NEXUS_DOCKER_REPO

docker pull $NEXUS_DOCKER_REPO/${SOLUTION_NAME}/appc-image:$APPC_DOCKER_IMAGE_VERSION
docker tag $NEXUS_DOCKER_REPO/${SOLUTION_NAME}/appc-image:$APPC_DOCKER_IMAGE_VERSION ${SOLUTION_NAME}/appc-image:latest

docker pull $NEXUS_DOCKER_REPO/${SOLUTION_NAME}/ccsdk-dgbuilder-image:$DGBUILDER_DOCKER_IMAGE_VERSION
docker tag $NEXUS_DOCKER_REPO/${SOLUTION_NAME}/ccsdk-dgbuilder-image:$DGBUILDER_DOCKER_IMAGE_VERSION ${SOLUTION_NAME}/ccsdk-dgbuilder-image:latest

docker pull $NEXUS_DOCKER_REPO/${SOLUTION_NAME}/ccsdk-ansible-server-image:$ANSIBLE_DOCKER_IMAGE_VERSION
docker tag $NEXUS_DOCKER_REPO/${SOLUTION_NAME}/ccsdk-ansible-server-image:$ANSIBLE_DOCKER_IMAGE_VERSION ${SOLUTION_NAME}/ccsdk-ansible-server-image:latest

docker pull $NEXUS_DOCKER_REPO/${SOLUTION_NAME}/appc-cdt-image:$APPC_DOCKER_IMAGE_VERSION
docker tag $NEXUS_DOCKER_REPO/${SOLUTION_NAME}/appc-cdt-image:$APPC_DOCKER_IMAGE_VERSION ${SOLUTION_NAME}/appc-cdt-image:latest

# start APPC containers with docker compose and configuration from docker-compose.yml
docker-compose up -d
# WAIT 5 minutes maximum and test every 5 seconds if APPC is up using HealthCheck API
TIME_OUT=1000
INTERVAL=30
TIME=0
while [ "$TIME" -lt "$TIME_OUT" ]; do
  response=$(curl --write-out '%{http_code}' --silent --output /dev/null -H "Authorization: Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==" -X POST -H "X-FromAppId: csit-appc" -H "X-TransactionId: csit-appc" -H "Accept: application/json" -H "Content-Type: application/json" http://localhost:8282/restconf/operations/SLI-API:healthcheck ); echo $response

  if [ "$response" == "200" ]; then
    echo APPC started in $TIME seconds
    break;
  fi

  echo Sleep: $INTERVAL seconds before testing if APPC is up. Total wait time up now is: $TIME seconds. Timeout is: $TIME_OUT seconds
  sleep $INTERVAL
  TIME=$(($TIME+$INTERVAL))
done

if [ "$TIME" -ge "$TIME_OUT" ]; then
   echo TIME OUT: APPC Docker containers not started in $TIME_OUT seconds... Could cause problems for testing activities...
fi

TIME_OUT=1000
INTERVAL=60
TIME=0
while [ "$TIME" -lt "$TIME_OUT" ]; do
  response=$(docker exec --tty appc_controller_container /opt/opendaylight/current/bin/client system:start-level)

  if grep -q 'Level 100' <<< ${response}; then
    echo APPC karaf started in $TIME seconds
    break;
  fi

  echo Sleep: $INTERVAL seconds before testing if APPC is up. Total wait time up now is: $TIME seconds. Timeout is: $TIME_OUT seconds
  sleep $INTERVAL
  TIME=$(($TIME+$INTERVAL))
done

if [ "$TIME" -ge "$TIME_OUT" ]; then
   echo TIME OUT: karaf session not started in $TIME_OUT seconds... Could cause problems for testing activities...
fi


TIME_OUT=1000
INTERVAL=60
TIME=0
while [ "$TIME" -lt "$TIME_OUT" ]; do
  response=$(docker exec --tty appc_controller_container /opt/opendaylight/current/bin/client bundle:list | grep appc-design-services-provider)

  if grep -q 'appc-design-services-provider' <<< ${response}; then
    echo APPC features started in $TIME seconds
    break;
  fi

  echo Sleep: $INTERVAL seconds before testing if APPC is up. Total wait time up now is: $TIME seconds. Timeout is: $TIME_OUT seconds
  sleep $INTERVAL
  TIME=$(($TIME+$INTERVAL))
done

if [ "$TIME" -ge "$TIME_OUT" ]; then
   echo TIME OUT: karaf session not started in $TIME_OUT seconds... Could cause problems for testing activities...
fi


# Sleep additional 5 minutes (300 secs) to give application time to finish
sleep 300

# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v SCRIPTS:${SCRIPTS}"
