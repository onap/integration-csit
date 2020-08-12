#!/bin/bash
echo "Starting teardown script"
TEST_PLANS_DIR=$WORKSPACE/plans/dcaegen2-sonhandler/sonhandler
mkdir -p $WORKSPACE/archives

docker container stop configdb_oof_sim
docker container rm configdb_oof_sim
docker-compose -f $TEST_PLANS_DIR/docker-compose.yaml logs > $WORKSPACE/archives/sonhandler-docker-compose.log
docker-compose -f $TEST_PLANS_DIR/docker-compose.yaml down -v
