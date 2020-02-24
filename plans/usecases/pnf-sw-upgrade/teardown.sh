#!/bin/bash

source $SO_DOCKER_PATH/so_teardown.sh

source $SDNC_DOCKER_PATH/sdn_teardown.sh

source $CDS_DOCKER_PATH/cds_teardown.sh

PNFSIM_DOCKER_COMPOSE_PATH=$PNF_SIM_DOCKER_PATH/docker-compose.yml
docker-compose -f $PNFSIM_DOCKER_COMPOSE_PATH -p $PROJECT_NAME down
