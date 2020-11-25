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
# Modifications copyright (c) 2020 Samsung Electronics Co., Ltd.
#
# Place the scripts in run order:
set -x
export NEXUS_USERNAME=docker
export NEXUS_PASSWD=docker
export NEXUS_DOCKER_REPO=nexus3.onap.org:10001
export DMAAP_TOPIC=AUTO
export DOCKER_IMAGE_VERSION=2.1-STAGING-latest
export ADMPORTAL_DOCKER_IMAGE_VERSION=2.0-STAGING-latest
export CCSDK_DOCKER_IMAGE_VERSION=1.1-STAGING-latest

export MTU=$(/sbin/ifconfig | grep MTU | sed 's/.*MTU://' | sed 's/ .*//' | sort -n | head -1)

if [ "$MTU" == "" ]; then
	  export MTU="1450"
fi


# Clone SDNC repo to get docker-compose for SDNC
mkdir -p $WORKSPACE/archives/sdnc
cd $WORKSPACE/archives
git clone -b master --single-branch --depth=1 http://gerrit.onap.org/r/sdnc/oam.git sdnc
cd $WORKSPACE/archives/sdnc
git pull
unset http_proxy https_proxy
cd $WORKSPACE/archives/sdnc/installation/src/main/yaml

sed -i "s/DMAAP_TOPIC_ENV=.*/DMAAP_TOPIC_ENV="AUTO"/g" docker-compose.yml
docker login -u $NEXUS_USERNAME -p $NEXUS_PASSWD $NEXUS_DOCKER_REPO

docker pull $NEXUS_DOCKER_REPO/onap/sdnc-image:$DOCKER_IMAGE_VERSION
docker tag $NEXUS_DOCKER_REPO/onap/sdnc-image:$DOCKER_IMAGE_VERSION onap/sdnc-image:latest

docker pull $NEXUS_DOCKER_REPO/onap/sdnc-ansible-server-image:$DOCKER_IMAGE_VERSION
docker tag $NEXUS_DOCKER_REPO/onap/sdnc-ansible-server-image:$DOCKER_IMAGE_VERSION onap/sdnc-ansible-server-image:latest

docker pull $NEXUS_DOCKER_REPO/onap/ccsdk-dgbuilder-image:$CCSDK_DOCKER_IMAGE_VERSION
docker tag $NEXUS_DOCKER_REPO/onap/ccsdk-dgbuilder-image:$CCSDK_DOCKER_IMAGE_VERSION onap/ccsdk-dgbuilder-image:latest

docker pull $NEXUS_DOCKER_REPO/onap/admportal-sdnc-image:$ADMPORTAL_DOCKER_IMAGE_VERSION
docker tag $NEXUS_DOCKER_REPO/onap/admportal-sdnc-image:$ADMPORTAL_DOCKER_IMAGE_VERSION onap/admportal-sdnc-image:latest

docker pull $NEXUS_DOCKER_REPO/onap/sdnc-ueb-listener-image:$DOCKER_IMAGE_VERSION
docker tag $NEXUS_DOCKER_REPO/onap/sdnc-ueb-listener-image:$DOCKER_IMAGE_VERSION onap/sdnc-ueb-listener-image:latest

docker pull $NEXUS_DOCKER_REPO/onap/sdnc-dmaap-listener-image:$DOCKER_IMAGE_VERSION

docker tag $NEXUS_DOCKER_REPO/onap/sdnc-dmaap-listener-image:$DOCKER_IMAGE_VERSION onap/sdnc-dmaap-listener-image:latest


# start SDNC containers with docker compose and configuration from docker-compose.yml
docker-compose up -d

# WAIT 5 minutes maximum and check karaf.log for readiness every 10 seconds

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

num_bundles=$(docker exec -i sdnc_controller_container /opt/opendaylight/current/bin/client bundle:list | tail -1 | cut -d' ' -f1)
num_failed_bundles=$(docker exec -i sdnc_controller_container /opt/opendaylight/current/bin/client bundle:list | grep Failure | wc -l)
failed_bundles=$(docker exec -i sdnc_controller_container /opt/opendaylight/current/bin/client bundle:list | grep Failure)
echo There is/are $num_failed_bundles failed bundles out of $num_bundles installed bundles.

if [ "$num_failed_bundles" -ge 1 ]; then
  echo "The following bundle(s) are in a failed state: "
  echo "  $failed_bundles"
fi

# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v SCRIPTS:${SCRIPTS}"
