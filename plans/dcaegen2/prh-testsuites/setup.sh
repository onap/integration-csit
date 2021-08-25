#!/bin/bash

source ${SCRIPTS}/common_functions.sh

export PRH_SERVICE="prh"
export DMAAP_SIMULATOR="dmaap_simulator"
export AAI_SIMULATOR="aai_simulator"

cd ${WORKSPACE}/tests/dcaegen2/prh-testcases/resources/

#Prepare PRH config volume
mkdir prh_configs/prh_config_volume
cp prh_configs/prh-config.yaml prh_configs/prh_config_volume/application_config.yaml

pip uninstall -y docker-py
pip uninstall -y docker
pip install -U docker

set -e

docker login -u docker -p docker https://nexus3.onap.org:10001
docker-compose up -d --build

# Extract docker images IPs
PRH_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${PRH_SERVICE})
DMAAP_SIMULATOR_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${DMAAP_SIMULATOR})
AAI_SIMULATOR_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${AAI_SIMULATOR})

bypass_ip_adress ${PRH_IP}
bypass_ip_adress ${DMAAP_SIMULATOR_IP}
bypass_ip_adress ${AAI_SIMULATOR_IP}

echo PRH_IP=${PRH_IP}
echo DMAAP_SIMULATOR_IP=${DMAAP_SIMULATOR_IP}
echo AAI_SIMULATOR_IP=${AAI_SIMULATOR_IP}

# Wait for initialization of PRH services
wait_for_service_init localhost:8100/heartbeat

# #Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v DMAAP_SIMULATOR_SETUP:${DMAAP_SIMULATOR_IP}:2224 -v AAI_SIMULATOR_SETUP:${AAI_SIMULATOR_IP}:3335 -v PRH_SETUP:${PRH_IP}:8100"