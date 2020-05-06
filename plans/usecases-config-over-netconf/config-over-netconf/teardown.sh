#!/bin/bash

SDNC_DOCKER_COMPOSE_PATH=$SDNC_DOCKER_PATH/docker-compose.yaml
PNFSIM_DOCKER_COMPOSE_PATH=$INT_DOCKER_PATH/docker-compose.yml
CDS_DOCKER_COMPOSE_PATH=$CDS_DOCKER_PATH/docker-compose.yaml

echo "==========================blueprint-processor logs =================================="
docker logs bp-rest

echo "==========================sdnc-controller logs ======================================"
docker logs sdnc_controller_container


docker-compose -f $SDNC_DOCKER_COMPOSE_PATH down
docker-compose -f $PNFSIM_DOCKER_COMPOSE_PATH down
docker-compose -f $CDS_DOCKER_COMPOSE_PATH down

rm -rf $WORKSPACE/temp
