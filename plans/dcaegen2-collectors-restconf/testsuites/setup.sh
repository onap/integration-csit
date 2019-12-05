#!/bin/bash

#get current host IP addres
HOST_IP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}')
CONTAINER_NAME=rcc
RCC_IMAGE=nexus3.onap.org:10001/onap/org.onap.dcaegen2.collectors.restconfcollector:latest
echo RCC_IMAGE=${RCC_IMAGE}

#get JAVA version
echo java -version
java -version

# Start DCAE Restconf Collector
docker run -d -p 8080:8080/tcp -p 8443:8443/tcp -P --name ${CONTAINER_NAME} -e DMAAPHOST=${HOST_IP} ${RCC_IMAGE}

RCC_IP=`get-instance-ip.sh ${CONTAINER_NAME}`
export RCC_IP=${RCC_IP}
export HOST_IP=${HOST_IP}

export ROBOT_VARIABLES="--pythonpath ${WORKSPACE}/tests/dcaegen2-collectors-restconf/testcases/resources"

pip install jsonschema uuid
# Wait container ready
sleep 5

#get the docker log
echo DOCKER LOG ${CONTAINER_NAME}
docker logs ${CONTAINER_NAME}