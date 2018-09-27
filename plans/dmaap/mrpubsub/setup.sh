#!/bin/bash
#
# ============LICENSE_START=======================================================
# ONAP DMAAP MR 
# ================================================================================
# Copyright (C) 2017 AT&T Intellectual Property. All rights
#                             reserved.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============LICENSE_END============================================
# ===================================================================
# ECOMP is a trademark and service mark of AT&T Intellectual Property.
#
# Place the scripts in run order:
source ${SCRIPTS}/common_functions.sh

# Clone DMaaP Message Router repo
mkdir -p $WORKSPACE/archives/dmaapmr
cd $WORKSPACE/archives/dmaapmr
#unset http_proxy https_proxy
git clone --depth 1 http://gerrit.onap.org/r/dmaap/messagerouter/messageservice -b master
git pull
cd $WORKSPACE/archives/dmaapmr/messageservice/src/main/resources/docker-compose
cp $WORKSPACE/archives/dmaapmr/messageservice/bundleconfig-local/etc/appprops/MsgRtrApi.properties /var/tmp/


# start DMaaP MR containers with docker compose and configuration from docker-compose.yml
docker login -u docker -p docker nexus3.onap.org:10001
docker-compose up -d

# Wait for initialization of Docker contaienr for DMaaP MR, Kafka and Zookeeper
for i in {1..50}; do
	if [ $(docker inspect --format '{{ .State.Running }}' dockercompose_dmaap_1) ] && \
		[ $(docker inspect --format '{{ .State.Running }}' dockercompose_zookeeper_1) ] && \
		[ $(docker inspect --format '{{ .State.Running }}' dockercompose_dmaap_1) ] 
	then
		echo "DMaaP Service Running"	
		break    		
	else 
		echo sleep $i		
		sleep $i
	fi
done


DMAAP_MR_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dockercompose_dmaap_1)
KAFKA_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dockercompose_kafka_1)
ZOOKEEPER_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dockercompose_zookeeper_1)

echo DMAAP_MR_IP=${DMAAP_MR_IP}
echo KAFKA_IP=${KAFKA_IP}
echo ZOOKEEPER_IP=${ZOOKEEPER_IP}

# Initial docker-compose up and down is for populating kafka and zookeeper IPs in /var/tmp/MsgRtrApi.properites
docker-compose down 

# Update kafkfa and zookeeper properties in MsgRtrApi.propeties which will be copied to DMaaP Container
sed -i -e 's/<zookeeper_host>/'$ZOOKEEPER_IP'/' /var/tmp/MsgRtrApi.properties
sed -i -e 's/<kafka_host>:<kafka_port>/'$KAFKA_IP':9092/' /var/tmp/MsgRtrApi.properties

docker-compose build
docker login -u docker -p docker nexus3.onap.org:10001
docker-compose up -d 

# Wait for initialization of Docker containers
for i in {1..50}; do
        if [ $(docker inspect --format '{{ .State.Running }}' dockercompose_dmaap_1) ] && \
                [ $(docker inspect --format '{{ .State.Running }}' dockercompose_zookeeper_1) ] && \
                [ $(docker inspect --format '{{ .State.Running }}' dockercompose_dmaap_1) ]
        then
                echo "DMaaP Service Running"
                break
        else
                echo sleep $i
                sleep $i
        fi
done

# Wait for initialization of docker services
for i in {1..50}; do
    curl -sS -m 1 ${DMAAP_MR_IP}:3904/events/TestTopic && break 
    echo sleep $i
    sleep $i
done

#Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v DMAAP_MR_IP:${DMAAP_MR_IP}" 
