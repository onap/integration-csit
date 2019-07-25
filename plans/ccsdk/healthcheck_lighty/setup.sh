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
source ${WORKSPACE}/scripts/ccsdk/script1.sh

export MTU=$(/sbin/ifconfig | grep MTU | sed 's/.*MTU://' | sed 's/ .*//' | sort -n | head -1)
export NEXUS_DOCKER_REPO="nexus3.onap.org:10001"
export NEXUS_USERNAME=docker
export NEXUS_PASSWD=docker
export DMAAP_TOPIC=AUTO
export CCSDK_DOCKER_IMAGE_VERSION=0.5-STAGING-latest

if [ "$MTU" == "" ]; then
	  export MTU="1450"
fi

# Get docker-compose.yml
mkdir -p $WORKSPACE/archives/ccsdk/src/main/yaml
cd $WORKSPACE/archives/ccsdk/src/main/yaml

# TODO: uncomment after lighty change merged in ccsdk/distribution
curl --silent -o docker-compose.yml 'https://gerrit.onap.org/r/gitweb?p=ccsdk/distribution.git;a=blob_plain;f=lighty/lighty-ubuntu-docker/src/main/docker/docker-compose.yml;hb=refs/heads/master'
unset http_proxy https_proxy

sed -i "s/DMAAP_TOPIC_ENV=.*/DMAAP_TOPIC_ENV="AUTO"/g" docker-compose.yml
docker login -u $NEXUS_USERNAME -p $NEXUS_PASSWD $NEXUS_DOCKER_REPO

## start CCSDK containers with docker compose and configuration from docker-compose.yml
curl --silent -L https://github.com/docker/compose/releases/download/1.9.0/docker-compose-`uname -s`-`uname -m` > docker-compose
chmod +x docker-compose
./docker-compose pull --ignore-pull-failures
./docker-compose up -d

# WAIT 5 minutes maximum and test every 5 seconds if CCSDK is up using HealthCheck API
TIME_OUT=500
INTERVAL=30
TIME=0
while [ "$TIME" -lt "$TIME_OUT" ]; do
  response=$(curl --write-out '%{http_code}' --silent --output /dev/null -H "Authorization: Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==" -X POST -H "X-FromAppId: csit-ccsdk" -H "X-TransactionId: csit-ccsdk" -H "Accept: application/json" -H "Content-Type: application/json" -d '{"input":{"dummy":"dummy"}}' http://localhost:8383/restconf/operations/SLI-API:healthcheck ); echo $response

  if [ "$response" == "200" ]; then
    echo CCSDK started in $TIME seconds
    break;
  fi

  echo Sleep: $INTERVAL seconds before testing if CCSDK is up. Total wait time up now is: $TIME seconds. Timeout is: $TIME_OUT seconds
  sleep $INTERVAL
  TIME=$(($TIME+$INTERVAL))
done

if [ "$TIME" -ge "$TIME_OUT" ]; then
   echo TIME OUT: Docker containers not started in $TIME_OUT seconds... Could cause problems for testing activities...
fi

#echo "Waiting 100s to start services"
#sleep 100

# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v SCRIPTS:${SCRIPTS}"
