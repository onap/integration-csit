#!/bin/bash

#get current host IP addres
HOST_IP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}')
RCC_DOCKER_IMAGE_VERSION=1.2.1
RCC_IMAGE=nexus3.onap.org:10001/onap/org.onap.dcaegen2.collectors.restconfcollector:$RCC_DOCKER_IMAGE_VERSION
echo RCC_IMAGE=${RCC_IMAGE}

# Start DCAE Restconf Collector
docker run -d -p 8080:8080/tcp -p 8443:8443/tcp -P --name rcc -e DMAAPHOST=${HOST_IP} ${RCC_IMAGE}

RCC_IP=`get-instance-ip.sh rcc`
export RCC_IP=${RCC_IP}
export HOST_IP=${HOST_IP}

export ROBOT_VARIABLES="--pythonpath ${WORKSPACE}/tests/dcaegen2-collectors-restconf/testcases/resources"

pip install jsonschema uuid
# Wait container ready
sleep 5
