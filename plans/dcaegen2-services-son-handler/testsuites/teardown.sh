#!/bin/bash
echo "Starting teardown script"
TEST_PLANS_DIR=$WORKSPACE/plans/dcaegen2-services-son-handler/testsuites
TEST_SCRIPTS_CPS_DIR=$WORKSPACE/scripts/dcaegen2-services-son-handler/sonhandler/cps-sonhandler/cps
mkdir -p $WORKSPACE/archives

docker container stop configdb_oof_sim
docker container rm configdb_oof_sim
docker-compose -f $TEST_PLANS_DIR/docker-compose.yaml logs > $WORKSPACE/archives/sonhandler-docker-compose.log
docker-compose -f $TEST_PLANS_DIR/docker-compose.yaml down -v
docker-compose -f $TEST_SCRIPTS_CPS_DIR/docker-compose.yaml down -v
