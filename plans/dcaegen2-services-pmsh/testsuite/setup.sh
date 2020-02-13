#!/bin/bash
# Place the scripts in run order:
source ${SCRIPTS}/common_functions.sh

docker login -u docker -p docker nexus3.onap.org:10001

TEST_PLANS_DIR=$WORKSPACE/plans/dcaegen2-services-pmsh/testsuite

docker-compose -f $TEST_PLANS_DIR/docker-compose.yml up -d

echo "Waiting for PMSH to come up healthy..."
for i in {1..30}; do
    pmsh_state=$(docker inspect --format='{{json .State.Health.Status}}' pmsh)
    if [ $pmsh_state = '"healthy"' ]
    then
      break
    else
      sleep 2
    fi
done
[ "$pmsh_state" != '"healthy"' ] && echo "Error: PMSH container state not healthy" && exit 1

# Wait for initialization of Docker containers
containers_ok=false
for i in {1..5}; do
    if [ $(docker inspect --format '{{ .State.Running }}' mockserver) ] && \
        [ $(docker inspect --format '{{ .State.Running }}' db) ] && \
        [ $(docker inspect --format '{{ .State.Running }}' pmsh) ]
    then
        echo "All required docker containers are up."
        containers_ok=true
        break
    else
        sleep $i
    fi
done
[ "$containers_ok" = "false" ] && echo "Error: required container not running." && exit 1

PMSH_IP=$(docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" pmsh)

#Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v PMSH_IP:${PMSH_IP}"
