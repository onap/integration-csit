#!/bin/bash
# Place the scripts in run order:
source ${SCRIPTS}/common_functions.sh

export DB_USER=pmsh
export DB_PASSWORD=pmsh

docker login -u docker -p docker nexus3.onap.org:10001

TEST_PLANS_DIR=$WORKSPACE/plans/dcaegen2-services-pmsh/testsuite

docker-compose -f $TEST_PLANS_DIR/docker-compose.yml up -d mockserver db

# Slow machine running CSITs can affect db coming up in time for PMSH
echo "Waiting for postgres db to come up..."
for i in {1..30}; do
    docker exec -i db bash -c "PGPASSWORD=$DB_PASSWORD;psql -U $DB_USER  -c '\q'"
    db_response=$?
    if [ "$db_response" = "0" ]
    then
      break
    else
      sleep 2
    fi
done
[ "$db_response" != "0" ] && echo "Error: postgres db not accessible" && exit 1

docker-compose -f $TEST_PLANS_DIR/docker-compose.yml up -d pmsh

PMSH_IP=$(docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" pmsh)

# Slow machine running CSITs can affect PMSH coming up before CSITs are run
echo "Waiting for PMSH to come up..."
for i in {1..30}; do
    pmsh_response=$(curl -k -s -o /dev/null -w "%{http_code}" https://$PMSH_IP:8443/healthcheck)
    if [ "$pmsh_response" = "200" ]
    then
      break
    else
      sleep 2
    fi
done
[ "$pmsh_response" != "200" ] && echo "Error: PMSH container state not healthy" && exit 1

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
