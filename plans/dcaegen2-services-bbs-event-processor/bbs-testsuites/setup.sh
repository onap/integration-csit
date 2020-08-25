#!/bin/bash

source ${SCRIPTS}/common_functions.sh

export BBS_SERVICE="bbs"
# export SSL_BBS_SERVICE="ssl_bbs"
export DMAAP_SIMULATOR="dmaap_simulator"
export AAI_SIMULATOR="aai_simulator"

cd ${WORKSPACE}/tests/dcaegen2-services-bbs-event-processor/bbs-testcases/resources/

pip uninstall -y docker-py
pip uninstall -y docker
pip install -U docker>=2.7.0
docker-compose up -d --build

BBS_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${BBS_SERVICE})
# SSL_BBS_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${SSL_BBS_SERVICE})
DMAAP_SIMULATOR_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${DMAAP_SIMULATOR})
AAI_SIMULATOR_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${AAI_SIMULATOR})

bypass_ip_adress ${BBS_IP}
# bypass_ip_adress ${SSL_BBS_IP}
bypass_ip_adress ${DMAAP_SIMULATOR_IP}
bypass_ip_adress ${AAI_SIMULATOR_IP}

echo BBS_IP=${BBS_IP}
# echo SSL_BBS_IP=${SSL_BBS_IP}
echo DMAAP_SIMULATOR_IP=${DMAAP_SIMULATOR_IP}
echo AAI_SIMULATOR_IP=${AAI_SIMULATOR_IP}

# Wait for initialization of BBS services
# Same ports in the testcases docker compose
wait_for_service_init localhost:32100/heartbeat
#wait_for_service_init localhost:8200/heartbeat

# #Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v DMAAP_SIMULATOR_SETUP:${DMAAP_SIMULATOR_IP}:2224 -v AAI_SIMULATOR_SETUP:${AAI_SIMULATOR_IP}:3335"

