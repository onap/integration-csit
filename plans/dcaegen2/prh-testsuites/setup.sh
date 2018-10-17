#!/bin/bash

source ${SCRIPTS}/common_functions.sh

function check_heartbeat ()
{
    local port=$1

    for i in {1..10}; do
        curl -sS -m 1 localhost:$port/heartbeat && break
        echo sleep ${i}
        sleep ${i}
    done
}

export PRH_SERVICE="prh"
export SSL_PRH_SERVICE="ssl_prh"
export DMAAP_SIMULATOR="dmaap_simulator"
export AAI_SIMULATOR="aai_simulator"

cd ${WORKSPACE}/tests/dcaegen2/prh-testcases/resources/

pip uninstall -y docker-py
pip uninstall -y docker
pip install -U docker
docker-compose up -d --build

PRH_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${PRH_SERVICE})
SSL_PRH_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${SSL_PRH_SERVICE})
DMAAP_SIMULATOR_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${DMAAP_SIMULATOR})
AAI_SIMULATOR_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${AAI_SIMULATOR})

bypass_ip_adress ${PRH_IP}
bypass_ip_adress ${SSL_PRH_IP}
bypass_ip_adress ${DMAAP_SIMULATOR_IP}
bypass_ip_adress ${AAI_SIMULATOR_IP}

echo PRH_IP=${PRH_IP}
echo SSL_PRH_IP=${SSL_PRH_IP}
echo DMAAP_SIMULATOR_IP=${DMAAP_SIMULATOR_IP}
echo AAI_SIMULATOR_IP=${AAI_SIMULATOR_IP}

# Wait for initialization of PRH services
check_heartbeat 8100
check_heartbeat 8200

# #Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v DMAAP_SIMULATOR:${DMAAP_SIMULATOR_IP}:2222 -v AAI_SIMULATOR:${AAI_SIMULATOR_IP}:3333 -v SSL_AAI_SIMULATOR:${AAI_SIMULATOR_IP}:3334 -v AAI_SIMULATOR_SETUP:${AAI_SIMULATOR_IP}:3335"

