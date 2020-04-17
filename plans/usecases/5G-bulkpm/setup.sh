#!/bin/bash
# Place the scripts in run order:
source ${SCRIPTS}/common_functions.sh
SFTP_PORT=22
VESC_PORT=8080
export VESC_PORT=${VESC_PORT}
export CLI_EXEC_CLI_DFC="docker exec dfc /bin/sh -c \"ls /target | grep .gz\""

# Clone DMaaP Message Router repo
mkdir -p $WORKSPACE/archives/dmaapmr
cd $WORKSPACE/archives/dmaapmr
git clone --depth 1 http://gerrit.onap.org/r/dmaap/messagerouter/messageservice -b master
sed -i 's/enableCadi: false/enableCadi: "false"/g' /$WORKSPACE/archives/dmaapmr/messageservice/src/main/resources/docker-compose/docker-compose.yml
sed -i 's/net:/default:/g' /$WORKSPACE/archives/dmaapmr/messageservice/src/main/resources/docker-compose/docker-compose.yml
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

# Get IP address of DMAAP, KAFKA, Zookeeper
KAFKA_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $KAFKA)
ZOOKEEPER_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $ZOOKEEPER)
DMAAP_MR_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $DMAAP)

sleep 2
# Shutdown DMAAP Container
docker kill $DMAAP

# Initial docker-compose up and down is for populating kafka and zookeeper IPs in /var/tmp/MsgRtrApi.properites
sed -i -e '/config.zk.servers=/ s/=.*/='$ZOOKEEPER_IP'/' /var/tmp/MsgRtrApi.properties
sed -i -e '/kafka.metadata.broker.list=/ s/=.*/='$KAFKA_IP':9092/' /var/tmp/MsgRtrApi.properties

# Start DMaaP MR containers with docker compose and configuration from docker-compose.yml
docker login -u docker -p docker nexus3.onap.org:10001
docker-compose up -d
sleep 5

# Clone DMaaP Data Router repo
mkdir -p $WORKSPACE/archives/dmaapdr
cd $WORKSPACE/archives/dmaapdr
git clone --depth 1 https://gerrit.onap.org/r/dmaap/datarouter -b master
cd $WORKSPACE/archives/dmaapdr/datarouter/datarouter-docker-compose/src/main/resources
mkdir docker-compose
cd $WORKSPACE/archives/dmaapdr/datarouter/datarouter-docker-compose/src/main/resources/docker-compose
cp $WORKSPACE/plans/usecases/5G-bulkpm/composefile/docker-compose-e2e.yml $WORKSPACE/archives/dmaapdr/datarouter/datarouter-docker-compose/src/main/resources/docker-compose/docker-compose.yml

docker login -u docker -p docker nexus3.onap.org:10001
docker-compose up -d
echo "Disregard the message ERROR: for datarouter-node  Container 1234456 is unhealthy, this is expected behaiour at this stage"
docker kill vescollector
docker kill cbs
sleep 10
CONSUL_IP=$(docker inspect '--format={{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' consul )
sed -i -e '/CONSUL_HOST:/ s/:.*/: '$CONSUL_IP'/' docker-compose.yml
HOST_IP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $7}')
DMAAP_MR_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $DMAAP)
sed -i -e '/DMAAPHOST:/ s/:.*/: '$DMAAP_MR_IP'/' docker-compose.yml
MARIADB=$(docker inspect '--format={{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mariadb )
sed -i 's/datarouter-mariadb/'$MARIADB'/g' $WORKSPACE/archives/dmaapdr/datarouter/datarouter-docker-compose/src/main/resources/prov_data/provserver.properties
docker-compose up -d
sleep 5
# Get IP address of datarrouger-prov, datarouter-node, fileconsumer-node.
DR_PROV_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' datarouter-prov)
DR_NODE_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' datarouter-node)
DR_SUBSCIBER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' fileconsumer-node)
DR_GATEWAY_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}' datarouter-prov)

echo DR_PROV_IP=${DR_PROV_IP}
echo DR_NODE_IP=${DR_NODE_IP}
echo DR_GATEWAY_IP=${DR_GATEWAY_IP}
echo DR_SUBSCIBER_IP=${DR_SUBSCIBER_IP}

docker kill datarouter-node
docker kill datarouter-prov
sed -i 's/1.1.1.1/'$DR_NODE_IP'/g' docker-compose.yml
sed -i 's/2.2.2.2/'$DR_PROV_IP'/g' docker-compose.yml
docker-compose up -d

# Wait for initialization of Docker container for datarouter-node, datarouter-prov and mariadb
for i in {1..10}; do
    if [ $(docker inspect --format '{{ .State.Running }}' datarouter-node) ] && \
        [ $(docker inspect --format '{{ .State.Running }}' datarouter-prov) ] && \
        [ $(docker inspect --format '{{ .State.Running }}' mariadb) ]
    then
        echo "DR Service Running"
        break
    else
        echo sleep $i
        sleep $i
    fi
done

sleep 5

docker exec -i datarouter-prov sh -c "curl -k  -X PUT https://$DR_PROV_IP:8443/internal/api/NODES?val=dmaap-dr-node\|$DR_GATEWAY_IP"
docker exec -i datarouter-prov sh -c "curl -k  -X PUT https://$DR_PROV_IP:8443/internal/api/PROV_AUTH_ADDRESSES?val=dmaap-dr-prov\|$DR_GATEWAY_IP"
docker exec datarouter-node /bin/sh -c "echo '${DR_SUBSCIBER_IP}' dmaap-dr-subscriber >> /etc/hosts"


# Get IP address of DMAAP, KAFKA, Zookeeper
DMAAP_MR_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $DMAAP)
KAFKA_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $KAFKA)
ZOOKEEPER_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $ZOOKEEPER)
VESC_IP=$(docker inspect '--format={{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' vescollector)
SFTP_IP=$(docker inspect '--format={{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sftp)

export VESC_IP=${VESC_IP}
export HOST_IP=${HOST_IP}
export DMAAP_MR_IP=${DMAAP_MR_IP}


# Data File Collector configuration :
sed -i 's/5.5.5.5/'$DR_NODE_IP'/g' docker-compose.yml
cp $WORKSPACE/plans/usecases/5G-bulkpm/assets/datafile_endpoints.json /tmp/
sed -i 's/dmaapmrhost/'${DMAAP_MR_IP}'/g' /tmp/datafile_endpoints.json
sed -i 's/dmaapdrhost/'${DR_PROV_IP}'/g' /tmp/datafile_endpoints.json
echo data_endpoints.json to be copied onto the DFC containter
cat /tmp/datafile_endpoints.json
docker-compose up -d
sleep 2
# DFC is now online
docker cp dfc:/opt/app/datafile/config/datafile_endpoints.json /tmp/datafile_endpoints.json.fromcontainer
echo data_endpoints.json from DFC containter
cat /tmp/datafile_endpoints.json.fromcontainer
docker cp /tmp/datafile_endpoints.json dfc:/opt/app/datafile/config/
docker cp $WORKSPACE/plans/usecases/5G-bulkpm/assets/application.yaml dfc:/opt/app/datafile/config/
#Increase Logging
#docker exec dfc /bin/sh -c " sed -i 's/org.onap.dcaegen2.collectors.datafile: WARN/org.onap.dcaegen2.collectors.datafile: TRACE/g' /opt/app/datafile/config/application.yaml"
docker restart dfc
sleep 2

# Wait for initialization of Docker container for datarouter-node, datarouter-prov and mariadb, Consul, CBS
for i in {1..10}; do
    if  [ $(docker inspect --format '{{ .State.Running }}' consul) ] && \
        [ $(docker inspect --format '{{ .State.Running }}' cbs) ]
    then
        echo "Data Router, Consul, Config Binding Service Services Running"
        break
    else
        echo sleep $i
        sleep $i
    fi
done
sleep 10

pip install jsonschema uuid simplejson
# Wait container ready
sleep 2

# Update the File Ready Notification with actual sftp ip address and copy pm files to sftp server.
cp $WORKSPACE/tests/usecases/5G-bulkpm/assets/json_events/FileExistNotification.json $WORKSPACE/tests/usecases/5G-bulkpm/assets/json_events/FileExistNotificationUpdated.json
sed -i 's/sftpserver/'${SFTP_IP}'/g' $WORKSPACE/tests/usecases/5G-bulkpm/assets/json_events/FileExistNotificationUpdated.json
sed -i 's/sftpport/'${SFTP_PORT}'/g' $WORKSPACE/tests/usecases/5G-bulkpm/assets/json_events/FileExistNotificationUpdated.json
docker cp $WORKSPACE/plans/usecases/5G-bulkpm/assets/xNF.pm.xml.gz sftp:/home/admin/
docker cp $WORKSPACE/tests/dcaegen2-pmmapper/pmmapper/assets/A20181002.0000-1000-0015-1000_5G.xml.gz sftp:/home/admin/

# Data Router Configuration:
# Create default feed and create file consumer subscriber on data router
curl -v -X POST -H "Content-Type:application/vnd.dmaap-dr.feed" -H "X-DMAAP-DR-ON-BEHALF-OF:dradmin" --data-ascii @$WORKSPACE/plans/usecases/5G-bulkpm/assets/createFeed.json --post301 --location-trusted -k https://${DR_PROV_IP}:8443
cp $WORKSPACE/plans/usecases/5G-bulkpm/assets/addSubscriber.json /tmp/addSubscriber.json
sed -i 's/fileconsumer/'${DR_SUBSCIBER_IP}'/g' /tmp/addSubscriber.json
curl -v -X POST -H "Content-Type:application/vnd.dmaap-dr.subscription" -H "X-DMAAP-DR-ON-BEHALF-OF:dradmin" --data-ascii @/tmp/addSubscriber.json --post301 --location-trusted -k https://${DR_PROV_IP}:8443/subscribe/1
sleep 10
curl -k https://$DR_PROV_IP:8443/internal/prov

# Consul Configuration for PM Mapper
cp $WORKSPACE/plans/dcaegen2-pmmapper/pmmapper/assets/cbs.json /tmp/cbs.json
sed -i 's/ipaddress/'${CBS_IP}'/g' /tmp/cbs.json
curl --request PUT --data @/tmp/cbs.json http://$CONSUL_IP:8500/v1/agent/service/register
curl 'http://'$CONSUL_IP':8500/v1/kv/pmmapper?dc=dc1' -X PUT -H 'Accept: application/json' -H 'Content-Type: application/json' -H 'X-Requested-With: XMLHttpRequest' --data @$WORKSPACE/plans/usecases/5G-bulkpm/assets/config.json

# PM Mapper startup and configuration
mkdir /tmp/docker-compose
cd /tmp/docker-compose
cp $WORKSPACE/plans/usecases/5G-bulkpm/composefile/docker-compose-pmmapper.yml /tmp/docker-compose/docker-compose.yml
CBS_IP=$(docker inspect '--format={{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' cbs)
sed -i 's/CBSIP/'$CBS_IP'/g' docker-compose.yml
sed -i 's/1.1.1.1/'$DR_NODE_IP'/g' docker-compose.yml
sed -i 's/4.4.4.4/'$MARIADB'/g' docker-compose.yml
docker-compose up -d

cd $WORKSPACE/archives/dmaapdr/datarouter/datarouter-docker-compose/src/main/resources/docker-compose
PMMAPPER_IP=$(docker inspect '--format={{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' pmmapper)
docker kill datarouter-node
docker kill datarouter-prov
sed -i 's/1.1.1.1/'$DR_NODE_IP'/g' docker-compose.yml
sed -i 's/2.2.2.2/'$DR_PROV_IP'/g' docker-compose.yml
sed -i 's/3.3.3.3/'$PMMAPPER_IP'/g' docker-compose.yml
docker-compose up -d

# Setting up PM Mapper certs.
docker cp $WORKSPACE/plans/dcaegen2-pmmapper/pmmapper/assets/cert.jks pmmapper:opt/app/pm-mapper/etc/
docker cp $WORKSPACE/plans/dcaegen2-pmmapper/pmmapper/assets/jks.pass pmmapper:opt/app/pm-mapper/etc/
docker cp $WORKSPACE/plans/dcaegen2-pmmapper/pmmapper/assets/trust.jks pmmapper:opt/app/pm-mapper/etc/
docker cp $WORKSPACE/plans/dcaegen2-pmmapper/pmmapper/assets/trust.pass pmmapper:opt/app/pm-mapper/etc/
docker restart pmmapper
sleep 5

# Simulation setup for Message Router
docker cp $WORKSPACE/plans/dcaegen2-pmmapper/pmmapper/assets/mrserver.js mariadb:/
docker exec mariadb /bin/bash -c "apt update"
sleep 2
docker exec mariadb /bin/bash -c "apt install nodejs -y"
sleep 10
docker exec mariadb /bin/bash -c "nodejs mrserver.js &" &

# Create PM Mapper feed and create PM Mapper subscriber on data router
#curl -v -X POST -H "Content-Type:application/vnd.dmaap-dr.feed" -H "X-DMAAP-DR-ON-BEHALF-OF:pmmapper" --data-ascii @$WORKSPACE/plans/dcaegen2-pmmapper/pmmapper/assets/createFeed.json --post301 --location-trusted -k https://${DR_PROV_IP}:8443
curl -v -X POST -H "Content-Type:application/vnd.dmaap-dr.subscription" -H "X-DMAAP-DR-ON-BEHALF-OF:pmmapper" --data-ascii @$WORKSPACE/plans/dcaegen2-pmmapper/pmmapper/assets/addSubscriber.json --post301 --location-trusted -k https://${DR_PROV_IP}:8443/subscribe/1

# Create PM Mapper tocic in Message Router
PMMAPPER_IP=$(docker inspect '--format={{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' pmmapper)
docker exec pmmapper /bin/sh -c "cat /var/log/ONAP/dcaegen2/services/pm-mapper/pm-mapper_output.log" > /tmp/pmmapper.log
cat /tmp/pmmapper.log
docker exec -it datarouter-prov sh -c "curl http://dmaap-dr-node:8080/internal/fetchProv"
sleep 10
curl -k https://$DR_PROV_IP:8443/internal/prov

#Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v DR_PROV_IP:${DR_PROV_IP} -v DR_NODE_IP:${DR_NODE_IP} -v DMAAP_MR_IP:${DMAAP_MR_IP} -v VESC_IP:${VESC_IP} -v VESC_PORT:${VESC_PORT} -v DR_SUBSCIBER_IP:${DR_SUBSCIBER_IP} -v SFTP_IP:${SFTP_IP}"