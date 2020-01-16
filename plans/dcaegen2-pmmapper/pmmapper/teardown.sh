#!/bin/bash
echo "Starting teardown script"
TEST_PLANS_DIR=$WORKSPACE/plans/dcaegen2-pmmapper/pmmapper
mkdir -p $WORKSPACE/archives
docker exec pmmapper /bin/sh -c "cat /var/log/ONAP/dcaegen2/services/pm-mapper/pm-mapper_output.log"
docker-compose -f $TEST_PLANS_DIR/docker-compose.yml logs > $WORKSPACE/archives/pmmapper-docker-compose.log
docker-compose -f $TEST_PLANS_DIR/docker-compose.yml down -v
