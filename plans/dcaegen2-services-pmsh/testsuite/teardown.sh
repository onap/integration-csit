#!/bin/bash
echo "Starting teardown script"
TEST_PLANS_DIR=$WORKSPACE/plans/dcaegen2-services-pmsh/testsuite
mkdir -p $WORKSPACE/archives
docker exec pmsh /bin/sh -c "cat /var/log/ONAP/dcaegen2/services/pmsh/*"
docker cp pmsh:/var/log/ONAP/dcaegen2/services/pmsh/application.log $WORKSPACE/archives/
docker-compose -f $TEST_PLANS_DIR/docker-compose.yml logs --no-color > $WORKSPACE/archives/pmsh-docker-compose.log
docker-compose -f $TEST_PLANS_DIR/docker-compose.yml down -v
