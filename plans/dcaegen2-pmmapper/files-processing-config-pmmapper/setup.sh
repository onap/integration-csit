#!/bin/bash
# Place the scripts in run order:
source ${SCRIPTS}/common_functions.sh

docker login -u docker -p docker nexus3.onap.org:10001

TEST_PLANS_DIR=$WORKSPACE/plans/dcaegen2-pmmapper/files-processing-config-pmmapper

export GATEWAY_IP=172.18.0.1
export DR_NODE_IP=172.18.0.2
export DR_PROV_IP=172.18.0.3
export CONSUL_IP=172.18.0.4
export CBS_IP=172.18.0.5
export MARIADB_IP=172.18.0.6
export NODE_IP=172.18.0.7
export PMMAPPER_IP=172.18.0.8

for asset in provserver.properties addSubscriber.txt addFeed3.txt node.properties cbs.json mrserver.js cert.jks jks.pass trust.jks trust.pass; do
  cp $TEST_PLANS_DIR/assets/${asset} /var/tmp/
done

sed -i 's/datarouter-mariadb/'$MARIADB_IP'/g' /var/tmp/provserver.properties
#sed -i 's/<kafka-ip>/'$KAFKA_IP'/g' /var/tmp/addSubscriber.txt
#sed -i 's/<kafka-ip>/'$KAFKA_IP'/g' /var/tmp/addFeed3.txt
#sed -i 's/ipaddress/'$CBS_IP'/g' /var/tmp/cbs.json
sed -i 's/ipaddress//g' /var/tmp/cbs.json

# ------------------------------------
#Prepare enviroment for client
#install docker sdk
echo "Uninstall docker-py and reinstall docker."
pip uninstall -y docker-py
pip uninstall -y docker
pip install -U docker==2.7.0

docker-compose -f $TEST_PLANS_DIR/docker-compose.yml up -d mariadb consul cbs node

echo "Waiting for MariaDB to come up healthy..."
for i in {1..30}; do
    mariadb_state=$(docker inspect --format='{{json .State.Health.Status}}' mariadb)
    if [ $mariadb_state = '"healthy"' ]
    then
      break
    else
      sleep 2
    fi
done
[ "$mariadb_state" != '"healthy"' ] && echo "Error: MariaDB container state not healthy" && exit 1

docker-compose -f $TEST_PLANS_DIR/docker-compose.yml up -d datarouter-node datarouter-prov

unset http_proxy
unset https_proxy
curl --request PUT --data @/var/tmp/cbs.json http://$CONSUL_IP:8500/v1/agent/service/register
curl 'http://'$CONSUL_IP':8500/v1/kv/pmmapper?dc=dc1' -X PUT \
      -H 'Accept: application/json' \
      -H 'Content-Type: application/json' \
      -H 'X-Requested-With: XMLHttpRequest' \
      --data @$TEST_PLANS_DIR/assets/config.json

docker-compose -f $TEST_PLANS_DIR/docker-compose.yml up -d pmmapper
sleep 2

# Wait for initialization of Docker container for datarouter-node, datarouter-prov and mariadb, Consul, CBS
containers_ok=false
for i in {1..5}; do
    if [ $(docker inspect --format '{{ .State.Running }}' datarouter-node) ] && \
        [ $(docker inspect --format '{{ .State.Running }}' datarouter-prov) ] && \
        [ $(docker inspect --format '{{ .State.Running }}' mariadb) ] && \
        [ $(docker inspect --format '{{ .State.Running }}' mr-simulator) ] && \
        [ $(docker inspect --format '{{ .State.Running }}' consul) ] && \
        [ $(docker inspect --format '{{ .State.Running }}' cbs) ] && \
        [ $(docker inspect --format '{{ .State.Running }}' pmmapper) ]
    then
        echo "All required docker containers are up."
        containers_ok=true
        break
    else
        sleep $i
    fi
done
[ "$containers_ok" = "false" ] && echo "Error: required container not running." && exit 1

# Data Router Configuration.
docker exec -i datarouter-prov sh -c \
    "curl -k  -X PUT https://$DR_PROV_IP:8443/internal/api/NODES?val=dmaap-dr-node\|$GATEWAY_IP"
docker exec -i datarouter-prov sh -c \
    "curl -k  -X PUT https://$DR_PROV_IP:8443/internal/api/PROV_AUTH_ADDRESSES?val=dmaap-dr-prov\|$GATEWAY_IP"

# Create PM Mapper feed and create PM Mapper subscriber on data router // TO WYSLAC Z PYTONA JAK PMMAPPER WSTANIE
curl -v -X POST -H "Content-Type:application/vnd.dmaap-dr.feed" -H "X-DMAAP-DR-ON-BEHALF-OF:pmmapper" \
      --data-ascii @$TEST_PLANS_DIR/assets/createFeed.json \
      --post301 --location-trusted -k https://${DR_PROV_IP}:8443
curl -v -X POST -H "Content-Type:application/vnd.dmaap-dr.subscription" -H "X-DMAAP-DR-ON-BEHALF-OF:pmmapper" \
      --data-ascii @$TEST_PLANS_DIR/assets/addSubscriber.json \
      --post301 --location-trusted -k https://${DR_PROV_IP}:8443/subscribe/1

docker cp pmmapper:/var/log/ONAP/dcaegen2/services/pm-mapper/pm-mapper_output.log /tmp/pmmapper.log
sleep 10
docker exec -it datarouter-prov sh -c "curl http://dmaap-dr-node:8080/internal/fetchProv"
curl -k https://$DR_PROV_IP:8443/internal/prov

#Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v CONSUL_IP:${CONSUL_IP} -v DR_PROV_IP:${DR_PROV_IP} -v DMAAP_MR_IP:${DMAAP_MR_IP} -v CBS_IP:${CBS_IP} -v PMMAPPER_IP:${PMMAPPER_IP} -v DR_NODE_IP:${DR_NODE_IP}"
