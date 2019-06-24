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
source ${WORKSPACE}/scripts/sdnc/script1.sh
export DOCKER_SDNC_TAG=1.5.2
export NEXUS_USERNAME=docker
export NEXUS_PASSWD=docker
export NEXUS_DOCKER_REPO=nexus3.onap.org:10001
export DMAAP_TOPIC=AUTO
export DOCKER_IMAGE_VERSION=1.5.2
export CCSDK_DOCKER_IMAGE_VERSION=0.4-STAGING-latest
export CCSDK_DOCKER_BP_IMAGE_VERSION=0.4.5

export MTU=$(/sbin/ifconfig | grep MTU | sed 's/.*MTU://' | sed 's/ .*//' | sort -n | head -1)

if [ "$MTU" == "" ]; then
	  export MTU="1450"
fi

# Clone SDNC repo to get docker-compose for SDNC
mkdir -p $WORKSPACE/archives/integration
cd $WORKSPACE/archives
git clone -b master --single-branch --depth=1 http://gerrit.onap.org/r/integration.git integration
cd $WORKSPACE/archives/integration
git pull
#cd $WORKSPACE/archives/integration/test/mocks/pnfsimulator
#sed -i 's/nexus3.onap.org:10003\/onap\/pnf-simulator:4.0.0-SNAPSHOT/nexus3.onap.org:10001\/onap\/pnf-simulator:latest/' docker-compose.yml
HOST_IP_ADDR=localhost
# Clone SDNC repo to get docker-compose for SDNC
mkdir -p $WORKSPACE/archives/sdnc
cd $WORKSPACE/archives
git clone -b master --single-branch --depth=1 http://gerrit.onap.org/r/sdnc/oam.git sdnc
cd $WORKSPACE/archives/sdnc
git pull
unset http_proxy https_proxy

sed -i "s/DMAAP_TOPIC_ENV=.*/DMAAP_TOPIC_ENV="AUTO"/g" docker-compose.yml
docker login -u $NEXUS_USERNAME -p $NEXUS_PASSWD $NEXUS_DOCKER_REPO

docker pull $NEXUS_DOCKER_REPO/onap/sdnc-image:$DOCKER_SDNC_TAG
docker tag $NEXUS_DOCKER_REPO/onap/sdnc-image:$DOCKER_SDNC_TAG onap/sdnc-image:latest

docker pull $NEXUS_DOCKER_REPO/onap/sdnc-ansible-server-image:$DOCKER_IMAGE_VERSION
docker tag $NEXUS_DOCKER_REPO/onap/sdnc-ansible-server-image:$DOCKER_IMAGE_VERSION onap/sdnc-ansible-server-image:latest

docker pull $NEXUS_DOCKER_REPO/onap/ccsdk-dgbuilder-image:$CCSDK_DOCKER_IMAGE_VERSION
docker tag $NEXUS_DOCKER_REPO/onap/ccsdk-dgbuilder-image:$CCSDK_DOCKER_IMAGE_VERSION onap/ccsdk-dgbuilder-image:latest

docker pull $NEXUS_DOCKER_REPO/onap/admportal-sdnc-image:$DOCKER_IMAGE_VERSION
docker tag $NEXUS_DOCKER_REPO/onap/admportal-sdnc-image:$DOCKER_IMAGE_VERSION onap/admportal-sdnc-image:latest

docker pull $NEXUS_DOCKER_REPO/onap/sdnc-ueb-listener-image:$DOCKER_IMAGE_VERSION
docker tag $NEXUS_DOCKER_REPO/onap/sdnc-ueb-listener-image:$DOCKER_IMAGE_VERSION onap/sdnc-ueb-listener-image:latest

docker pull $NEXUS_DOCKER_REPO/onap/sdnc-dmaap-listener-image:$DOCKER_IMAGE_VERSION
docker tag $NEXUS_DOCKER_REPO/onap/sdnc-dmaap-listener-image:$DOCKER_IMAGE_VERSION onap/sdnc-dmaap-listener-image:latest

docker pull $NEXUS_DOCKER_REPO/onap/ccsdk-blueprintsprocessor:$CCSDK_DOCKER_BP_IMAGE_VERSION
docker tag $NEXUS_DOCKER_REPO/onap/ccsdk-blueprintsprocessor:$CCSDK_DOCKER_BP_IMAGE_VERSION onap/ccsdk-blueprintsprocessor:latest


CERT_SUBPATH=plans/sdnc/sdnc_netconf_tls_post_deploy/certs
export SDNC_CERT_PATH=${WORKSPACE}/${CERT_SUBPATH}

cd $WORKSPACE/archives/sdnc/installation/src/main/yaml
sed -i 's/sdnc_controller_container/sdnc_controller_container\n    volumes: \n      - $SDNC_CERT_PATH:\/opt\/opendaylight\/current\/certs/' docker-compose.yml
# start SDNC containers with docker compose and configuration from docker-compose.yml
docker-compose up -d

cd $WORKSPACE/archives/integration/test/mocks/pnfsimulator
./simulator.sh start&

# WAIT 10 minutes maximum and test every 5 seconds if SDNC is up using HealthCheck API
TIME_OUT=1000
INTERVAL=30
TIME=0
while [ "$TIME" -lt "$TIME_OUT" ]; do
  response=$(curl --write-out '%{http_code}' --silent --output /dev/null -H "Authorization: Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==" -X POST -H "X-FromAppId: csit-sdnc" -H "X-TransactionId: csit-sdnc" -H "Accept: application/json" -H "Content-Type: application/json" http://localhost:8282/restconf/operations/SLI-API:healthcheck ); echo $response

  if [ "$response" == "200" ]; then
    echo SDNC started in $TIME seconds
    break;
  fi

  echo Sleep: $INTERVAL seconds before testing if SDNC is up. Total wait time up now is: $TIME seconds. Timeout is: $TIME_OUT seconds
  sleep $INTERVAL
  TIME=$(($TIME+$INTERVAL))
done

export PNF_IP=$(ip -4 addr show docker0 | grep -Po 'inet \K[\d.]+')
sed -i "s/pnfaddr/$PNF_IP/g" $WORKSPACE/tests/sdnc/sdnc_netconf_tls_post_deploy/data/mount.xml

if [ "$TIME" -ge "$TIME_OUT" ]; then
   echo TIME OUT: Docker containers not started in $TIME_OUT seconds... Could cause problems for testing activities...
fi

#sleep 800

TIME_OUT=1500
INTERVAL=60
TIME=0
while [ "$TIME" -lt "$TIME_OUT" ]; do
docker exec sdnc_controller_container rm -f /opt/opendaylight/current/etc/host.key
response=$(docker exec sdnc_controller_container /opt/opendaylight/current/bin/client system:start-level)
docker exec sdnc_controller_container rm -f /opt/opendaylight/current/etc/host.key

  if [ "$response" == "Level 100" ] ; then
    echo SDNC karaf started in $TIME seconds
    break;
  fi

  echo Sleep: $INTERVAL seconds before testing if SDNC is up. Total wait time up now is: $TIME seconds. Timeout is: $TIME_OUT seconds
  sleep $INTERVAL
  TIME=$(($TIME+$INTERVAL))
done

if [ "$TIME" -ge "$TIME_OUT" ]; then
   echo TIME OUT: karaf session not started in $TIME_OUT seconds... Could cause problems for testing activities...
fi

response=$(docker exec sdnc_controller_container /opt/opendaylight/current/bin/client system:start-level)

  if [ "$response" == "Level 100" ] ; then
    num_failed_bundles=$(docker exec sdnc_controller_container /opt/opendaylight/current/bin/client bundle:list | grep Failure | wc -l)
    failed_bundles=$(docker exec sdnc_controller_container /opt/opendaylight/current/bin/client bundle:list | grep Failure)
    echo There is/are $num_failed_bundles failed bundles out of $num_bundles installed bundles.
  fi

if [ "$num_failed_bundles" -ge 1 ]; then
  echo "The following bundle(s) are in a failed state: "
  echo "  $failed_bundles"
fi

########################################## blueprintsprocessor setup ##########################################################

mkdir -p $WORKSPACE/archives/cds
cd $WORKSPACE/archives

git clone -b master --single-branch --depth=1 http://gerrit.onap.org/r/ccsdk/cds.git cds
cd $WORKSPACE/archives/cds
git pull
unset http_proxy https_proxy
cd $WORKSPACE/archives/cds/ms/blueprintsprocessor/distribution/src/main/dc/

############# update ip of sdnc in docker-compose###########
SDNC_CONTAINER=$(docker ps -a -q --filter="name=sdnc_controller_container")
SDNC_CONTAINER_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $SDNC_CONTAINER)
echo "\\n    extra_hosts:\\n    - 'sdnc:$SDNC_CONTAINER_IP'" >> docker-compose.yaml
#############################################################

docker-compose up

################# Check state of BP ####################
BP_CONTAINER=$(docker ps -a -q --filter="name=bp-rest")
CCSDK_MARIADB=$(docker ps -a -q --filter="name=ccsdk-mariadb")
for i in {1..10}; do
if [ $(docker inspect --format '{{ .State.Running }}' $BP_CONTAINER) ] && \
[ $(docker inspect --format '{{ .State.Running }}' $CCSDK_MARIADB) ]
then
   echo "Blueprint proc Service Running"
   break
else
   echo sleep $i
   sleep $i
fi
done

########## update pnf simulator ip in config deploy request ########

NETOPEER_CONTAINER=$(docker ps -a -q --filter="name=netopeer")
NETOPEER_CONTAINER_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $SDNC_CONTAINER)

sed -i "s/pnfaddr/$NETOPEER_CONTAINER_IP/g" $WORKSPACE/tests/sdnc/sdnc_netconf_tls_post_deploy/data/config-deploy.json
sed -i "s/pnfaddr/$NETOPEER_CONTAINER_IP/g" $WORKSPACE/tests/sdnc/sdnc_netconf_tls_post_deploy/data/config-assign.json

####################################################################
# Sleep additional 3 minutes (180 secs) to give application time to finish
sleep 180


# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v SCRIPTS:${SCRIPTS}"
