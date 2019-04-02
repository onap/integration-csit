#!/bin/bash
# Place the scripts in run order:
source ${SCRIPTS}/common_functions.sh

# Clone DMaaP Message Router repo
mkdir -p $WORKSPACE/archives/dmaapmr
cd $WORKSPACE/archives/dmaapmr
git clone --depth 1 http://gerrit.onap.org/r/dmaap/messagerouter/messageservice -b master
sed -i 's/enableCadi: false/enableCadi: "false"/g' /$WORKSPACE/archives/dmaapmr/messageservice/src/main/resources/docker-compose/docker-compose.yml
cd $WORKSPACE/archives/dmaapmr/messageservice/src/main/resources/docker-compose
cp $WORKSPACE/archives/dmaapmr/messageservice/bundleconfig-local/etc/appprops/MsgRtrApi.properties /var/tmp/

# start DMaaP MR containers with docker compose and configuration from docker-compose.yml
docker login -u docker -p docker nexus3.onap.org:10001
docker-compose up -d

ZOOKEEPER=$(docker ps -a -q --filter="name=zookeeper_1")
KAFKA=$(docker ps -a -q --filter="name=kafka_1")
DMAAP=$(docker ps -a -q --filter="name=dmaap_1")

# Wait for initialization of Docker contaienr for DMaaP MR, Kafka and Zookeeper
for i in {1..10}; do
if [ $(docker inspect --format '{{ .State.Running }}' $KAFKA) ] && \
[ $(docker inspect --format '{{ .State.Running }}' $ZOOKEEPER) ] && \
[ $(docker inspect --format '{{ .State.Running }}' $DMAAP) ]
then
   echo "DMaaP Service Running"
   break
else
   echo sleep $i
   sleep $i
fi
done

# Get IP address of KAFKA, Zookeeper
KAFKA_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $KAFKA)
ZOOKEEPER_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $ZOOKEEPER)

# Shutdown DMAAP Container
docker kill $DMAAP

# Initial docker-compose up and down is for populating kafka and zookeeper IPs in /var/tmp/MsgRtrApi.properites
sed -i -e '/config.zk.servers=/ s/=.*/='$ZOOKEEPER_IP'/' /var/tmp/MsgRtrApi.properties
sed -i -e '/kafka.metadata.broker.list=/ s/=.*/='$KAFKA_IP':9092/' /var/tmp/MsgRtrApi.properties

# Start DMaaP MR containers with docker compose and configuration from docker-compose.yml
docker login -u docker -p docker nexus3.onap.org:10001
docker-compose up -d
sleep 5

# Get IP address of DMAAP Message Router.
DMAAP_MR_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $DMAAP)

# Clone DMaaP Data Router repo and Initialization of Data Router, Consul, Config Binding Service
mkdir -p $WORKSPACE/archives/dmaapdr
cd $WORKSPACE/archives/dmaapdr
git clone --depth 1 https://gerrit.onap.org/r/dmaap/datarouter -b master
cd $WORKSPACE/archives/dmaapdr/datarouter/datarouter-docker-compose/src/main/resources
mkdir docker-compose
cd $WORKSPACE/archives/dmaapdr/datarouter/datarouter-docker-compose/src/main/resources/docker-compose
cp $WORKSPACE/plans/dcaegen2-pmmapper/pmmapper/composefile/docker-compose-e2e.yml $WORKSPACE/archives/dmaapdr/datarouter/datarouter-docker-compose/src/main/resources/docker-compose/docker-compose.yml
docker login -u docker -p docker nexus3.onap.org:10001
docker-compose up -d
echo "Disregard the message ERROR: for datarouter-node  Container 1234456 is unhealthy, this is expected behaiour at this stage"
docker kill datarouter-prov
docker kill datarouter-node
docker kill cbs
CONSUL_IP=$(docker inspect '--format={{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' consul )
sed -i -e '/CONSUL_HOST:/ s/:.*/: '$CONSUL_IP'/' docker-compose.yml
MARIADB=$(docker inspect '--format={{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mariadb )
sed -i 's/datarouter-mariadb/'$MARIADB'/g' $WORKSPACE/archives/dmaapdr/datarouter/datarouter-docker-compose/src/main/resources/prov_data/provserver.properties
docker-compose up -d
DR_PROV_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' datarouter-prov)
DR_NODE_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' datarouter-node)

# Consul Configuration for PM Mapper
cp $WORKSPACE/plans/dcaegen2-pmmapper/pmmapper/assets/cbs.json /tmp/cbs.json
sed -i 's/ipaddress/'${CBS_IP}'/g' /tmp/cbs.json
curl --request PUT --data @/tmp/cbs.json http://$CONSUL_IP:8500/v1/agent/service/register
curl 'http://'$CONSUL_IP':8500/v1/kv/pmmapper?dc=dc1' -X PUT -H 'Accept: application/json' -H 'Content-Type: application/json' -H 'X-Requested-With: XMLHttpRequest' --data @$WORKSPACE/plans/dcaegen2-pmmapper/pmmapper/assets/config.json

# PM Mapper startup and configuration
mkdir /tmp/docker-compose
cd /tmp/docker-compose
cp $WORKSPACE/plans/dcaegen2-pmmapper/pmmapper/composefile/docker-compose-pmmapper.yml /tmp/docker-compose/docker-compose.yml
CBS_IP=$(docker inspect '--format={{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' cbs)
sed -i 's/CBSIP/'$CBS_IP'/g' docker-compose.yml
sed -i 's/DRNODEIP/'$DR_NODE_IP'/g' docker-compose.yml
sed -i 's/DMAAPMRIP/'$DMAAP_MR_IP'/g' docker-compose.yml
docker-compose up -d

cd $WORKSPACE/archives/dmaapdr/datarouter/datarouter-docker-compose/src/main/resources/docker-compose
PMMAPPER_IP=$(docker inspect '--format={{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' pmmapper)
docker kill datarouter-node
docker kill datarouter-prov
sed -i 's/DRNODEIP/'$DR_NODE_IP'/g' docker-compose.yml
sed -i 's/DRPROVIP/'$DR_PROV_IP'/g' docker-compose.yml
sed -i 's/PMMAPPERIP/'$PMMAPPER_IP'/g' docker-compose.yml
docker-compose up -d

# Wait for initialization of Docker container for datarouter-node, datarouter-prov and mariadb, Consul, CBS
for i in {1..10}; do
    if [ $(docker inspect --format '{{ .State.Running }}' datarouter-node) ] && \
        [ $(docker inspect --format '{{ .State.Running }}' datarouter-prov) ] && \
        [ $(docker inspect --format '{{ .State.Running }}' mariadb) ] && \
        [ $(docker inspect --format '{{ .State.Running }}' consul) ] && \
        [ $(docker inspect --format '{{ .State.Running }}' cbs) ]
    then
        echo "Data Router, Consul, Config Binding Service Running"
        break
    else
        echo sleep $i
        sleep $i
    fi
done
sleep 15
# Data Router Configuration.
DR_NODE_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' datarouter-node)
DR_GATEWAY_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}' datarouter-prov)
docker exec -i datarouter-prov sh -c "curl -k  -X PUT https://$DR_PROV_IP:8443/internal/api/NODES?val=dmaap-dr-node\|$DR_GATEWAY_IP"
docker exec -i datarouter-prov sh -c "curl -k  -X PUT https://$DR_PROV_IP:8443/internal/api/PROV_AUTH_ADDRESSES?val=dmaap-dr-prov\|$DR_GATEWAY_IP"

# Create PM Mapper feed and create PM Mapper subscriber on data router
curl -v -X POST -H "Content-Type:application/vnd.dmaap-dr.feed" -H "X-DMAAP-DR-ON-BEHALF-OF:pmmapper" --data-ascii @$WORKSPACE/plans/dcaegen2-pmmapper/pmmapper/assets/createFeed.json --post301 --location-trusted -k https://${DR_PROV_IP}:8443
curl -v -X POST -H "Content-Type:application/vnd.dmaap-dr.subscription" -H "X-DMAAP-DR-ON-BEHALF-OF:pmmapper" --data-ascii @$WORKSPACE/plans/dcaegen2-pmmapper/pmmapper/assets/addSubscriber.json --post301 --location-trusted -k https://${DR_PROV_IP}:8443/subscribe/1

# Create PM Mapper tocic in Message Router
curl -v -X POST http://${DMAAP_MR_IP}:3904/topics/create -d @$WORKSPACE/plans/dcaegen2-pmmapper/pmmapper/assets/createTopic.json -H "Content-Type: application/json"


PMMAPPER_IP=$(docker inspect '--format={{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' pmmapper)
sleep 10
docker exec pmmapper /bin/sh -c "cat /var/log/ONAP/dcaegen2/services/pm-mapper/pm-mapper_output.log" > /tmp/pmmapper.log
cat /tmp/pmmapper.log
docker exec -it datarouter-prov sh -c "curl http://dmaap-dr-node:8080/internal/fetchProv"
curl -k https://$DR_PROV_IP:8443/internal/prov
curl http://${DMAAP_MR_IP}:3904/events/PM_MAPPER/CG1/C1?timeout=1000
curl http://${DMAAP_MR_IP}:3904/events/PM_MAPPER/CG1/C1?timeout=1000

#Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v CONSUL_IP:${CONSUL_IP} -v DR_PROV_IP:${DR_PROV_IP} -v DMAAP_MR_IP:${DMAAP_MR_IP} -v CBS_IP:${CBS_IP} -v PMMAPPER_IP:${PMMAPPER_IP} -v DR_NODE_IP:${DR_NODE_IP}"