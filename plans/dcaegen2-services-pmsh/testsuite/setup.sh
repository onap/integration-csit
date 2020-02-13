#!/bin/bash
# Place the scripts in run order:
source ${SCRIPTS}/common_functions.sh

docker login -u docker -p docker nexus3.onap.org:10001

TEST_PLANS_DIR=$WORKSPACE/plans/dcaegen2-services-pmsh/testsuite

export MOCKSERVER_IP=172.18.0.2
export DB_IP=172.18.0.3
export PMSH_IP=172.18.0.4

for asset in initializerJson.json mockserver.properties; do
  cp $TEST_PLANS_DIR/assets/${asset} /var/tmp/
done

docker-compose -f $TEST_PLANS_DIR/docker-compose.yml up -d

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

#Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v PMSH_IP:${PMSH_IP}"
