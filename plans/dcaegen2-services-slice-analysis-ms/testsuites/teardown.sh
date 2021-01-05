#!/bin/bash
echo "Starting teardown script"
TEST_PLANS_DIR=$WORKSPACE/plans/dcaegen2-services-slice-analysis-ms/testsuites
mkdir -p $WORKSPACE/archives

docker container stop configdb_sim
docker container rm configdb_sim
docker-compose -f $TEST_PLANS_DIR/docker-compose.yaml logs > $WORKSPACE/archives/sonhandler-docker-compose.log
docker-compose -f $TEST_PLANS_DIR/docker-compose.yaml down -v
