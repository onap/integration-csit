#!/bin/bash
echo "Starting teardown script"
TEST_PLANS_DIR=$WORKSPACE/plans/dcaegen2-services-slice-analysis-ms/testsuites
TEST_SCRIPTS_DIR=$WORKSPACE/scripts/dcaegen2-services-slice-analysis-ms/slice-analysis-ms/cps-aai
mkdir -p $WORKSPACE/archives

docker container stop configdb_des_sim
docker container rm configdb_des_sim
docker-compose -f $TEST_PLANS_DIR/docker-compose.yaml logs > $WORKSPACE/archives/slice-analysis-docker-compose.log
docker-compose -f $TEST_SCRIPTS_DIR/docker-compose.yaml down -v
docker-compose -f $TEST_PLANS_DIR/docker-compose.yaml down -v

