#!/bin/bash
# Place the scripts in run order:
source ${SCRIPTS}/common_functions.sh

CSIT=TRUE
if [ ${CSIT} = "TRUE" ] ; then
####################################################
#Executes the below setup in an Docker Environment #
####################################################

echo "CSIT Test get executed in here"
SFTP_PORT=22
VESC_PORT=8080
export VESC_PORT=${VESC_PORT}
export CLI_EXEC_CLI_DFC="docker exec dfc /bin/sh -c \"ls /target | grep .gz\""

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
cp $WORKSPACE/plans/dcaegen2-pmmapper/pmmapper/assets/docker-databus-controller.conf /tmp/
sed -i 's/DMAAPMR/'$DMAAP_MR_IP'/g' /tmp/docker-databus-controller.conf

docker login -u docker -p docker nexus3.onap.org:10001
docker-compose up -d
echo "Disregard the message ERROR: for datarouter-node  Container 1234456 is unhealthy, this is expected behaiour at this stage"
docker kill datarouter-prov
docker kill datarouter-node
docker kill vescollector
docker kill cbs
CONSUL_IP=$(docker inspect '--format={{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' consul )
sed -i -e '/CONSUL_HOST:/ s/:.*/: '$CONSUL_IP'/' docker-compose.yml
HOST_IP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}')
sed -i -e '/DMAAPHOST:/ s/:.*/: '$HOST_IP'/' docker-compose.yml
MARIADB=$(docker inspect '--format={{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mariadb )
sed -i 's/datarouter-mariadb/'$MARIADB'/g' $WORKSPACE/archives/dmaapdr/datarouter/datarouter-docker-compose/src/main/resources/prov_data/provserver.properties
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
# Get IP address of datarrouger-prov, datarouter-node, fileconsumer-node.
DR_PROV_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' datarouter-prov)
DR_NODE_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' datarouter-node)
DR_SUBSCIBER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' fileconsumer-node)
DR_GATEWAY_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}' datarouter-prov)

echo DR_PROV_IP=${DR_PROV_IP}
echo DR_NODE_IP=${DR_NODE_IP}
echo DR_GATEWAY_IP=${DR_GATEWAY_IP}
echo DR_SUBSCIBER_IP=${DR_SUBSCIBER_IP}

docker exec -i datarouter-prov sh -c "curl -k  -X PUT https://$DR_PROV_IP:8443/internal/api/NODES?val=dmaap-dr-node\|$DR_GATEWAY_IP"
docker exec -i datarouter-prov sh -c "curl -k  -X PUT https://$DR_PROV_IP:8443/internal/api/PROV_AUTH_ADDRESSES?val=dmaap-dr-prov\|$DR_GATEWAY_IP"
docker exec datarouter-prov /bin/sh -c "echo '${DR_NODE_IP}' dmaap-dr-node >> /etc/hosts"
docker exec datarouter-node /bin/sh -c "echo '${DR_PROV_IP}' dmaap-dr-prov >> /etc/hosts"
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

docker kill buscontroller
sed -i 's/DMAAPDR/'$DR_PROV_IP'/g' docker-compose.yml
sed -i 's/DMAAPMR/'$DMAAP_MR_IP'/g' docker-compose.yml
docker-compose up -d
sed -i 's/DMAAPDR/'$DR_PROV_IP'/g' /tmp/docker-databus-controller.conf

# Data File Collector configuration :
sed -i 's/DR_NODE_IP/'$DR_NODE_IP'/g' docker-compose.yml
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
#Increase Logging
docker exec dfc /bin/sh -c " sed -i 's/org.onap.dcaegen2.collectors.datafile: ERROR/org.onap.dcaegen2.collectors.datafile: TRACE/g' /opt/app/datafile/config/application.yaml"
docker restart dfc
sleep 2

# Wait for initialization of Docker container for datarouter-node, datarouter-prov and mariadb, Consul, CBS, Buscontroller
for i in {1..10}; do
    if  [ $(docker inspect --format '{{ .State.Running }}' consul) ] && \
        [ $(docker inspect --format '{{ .State.Running }}' cbs) ] && \
        [ $(docker inspect --format '{{ .State.Running }}' buscontroller) ]
    then
        echo "Data Router, Consul, Config Binding Service, Buscontroller Services Running"
        break
    else
        echo sleep $i
        sleep $i
    fi
done
sleep 10

#Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v DR_PROV_IP:${DR_PROV_IP} -v DR_NODE_IP:${DR_NODE_IP} -v DMAAP_MR_IP:${DMAAP_MR_IP} -v VESC_IP:${VESC_IP} -v VESC_PORT:${VESC_PORT} -v DR_SUBSCIBER_IP:${DR_SUBSCIBER_IP} -v SFTP_IP:${SFTP_IP}"

pip install jsonschema uuid simplejson
# Wait container ready
sleep 2

# Update the File Ready Notification with actual sftp ip address and copy pm files to sftp server.
cp $WORKSPACE/tests/usecases/5G-bulkpm/assets/json_events/FileExistNotification.json $WORKSPACE/tests/usecases/5G-bulkpm/assets/json_events/FileExistNotificationUpdated.json
sed -i 's/sftpserver/'${SFTP_IP}'/g' $WORKSPACE/tests/usecases/5G-bulkpm/assets/json_events/FileExistNotificationUpdated.json
sed -i 's/sftpport/'${SFTP_PORT}'/g' $WORKSPACE/tests/usecases/5G-bulkpm/assets/json_events/FileExistNotificationUpdated.json
docker cp $WORKSPACE/plans/usecases/5G-bulkpm/assets/xNF.pm.xml.gz sftp:/home/admin/

# Data Router Configuration:
# Create default feed and create file consumer subscriber on data router
curl -v -X POST -H "Content-Type:application/vnd.dmaap-dr.feed" -H "X-DMAAP-DR-ON-BEHALF-OF:dradmin" --data-ascii @$WORKSPACE/plans/usecases/5G-bulkpm/assets/createFeed.json --post301 --location-trusted -k https://${DR_PROV_IP}:8443
cp $WORKSPACE/plans/usecases/5G-bulkpm/assets/addSubscriber.json /tmp/addSubscriber.json
sed -i 's/fileconsumer/'${DR_SUBSCIBER_IP}'/g' /tmp/addSubscriber.json
curl -v -X POST -H "Content-Type:application/vnd.dmaap-dr.subscription" -H "X-DMAAP-DR-ON-BEHALF-OF:dradmin" --data-ascii @/tmp/addSubscriber.json --post301 --location-trusted -k https://${DR_PROV_IP}:8443/subscribe/1
sleep 10
curl -k https://$DR_PROV_IP:8443/internal/prov

else
############################################################
############################################################
# Executes the below setup in an ONAP Environment          #
# Make sure the steps in the README are completed first !! #
############################################################
############################################################
SFTP_PORT=2222

cp $WORKSPACE/plans/usecases/5G-bulkpm/teardown.sh $WORKSPACE/plans/usecases/5G-bulkpm/teardown.sh.orig
cp $WORKSPACE/plans/usecases/5G-bulkpm/onap.teardown.sh $WORKSPACE/plans/usecases/5G-bulkpm/teardown.sh

#Get DataFileCollector POD name in this ONAP Deployment
DFC_POD=$(kubectl -n onap get pods | grep datafile-collector | awk '{print $1}')
export DFC_POD=${DFC_POD}
export CLI_EXEC_CLI_DFC="kubectl exec -n onap ${DFC_POD} -it ls /target | grep .gz"

# Get IP address of datarrouter-prov
DR_PROV_IP=$(kubectl -n onap -o wide get pods | grep dmaap-dr-prov | awk '{print $6}')
echo DR_PROV_IP=${DR_PROV_IP}
DR_NODE_IP=$(kubectl -n onap -o=wide get pods | grep dmaap-dr-node | awk '{print $6}')
echo DR_NODE_IP=${DR_NODE_IP}

# Get IP address of exposed Ves and its port
DMAAP_MR_IP=$(kubectl -n onap -o=wide get pods | grep dev-dmaap-message-router | grep -Ev "kafka|zookeeper" | awk '{print $6}')
VESC_IP=$(kubectl get svc -n onap | grep vesc | awk '{print $4}')
VESC_PORT=$(kubectl get svc -n onap | grep vesc | awk '{print $5}' | cut -d ":" -f2 | cut -d "/" -f1)
echo VESC_IP=${VESC_IP}
echo VESC_PORT=${VESC_PORT}

export VESC_IP=${VESC_IP}
export VESC_PORT=${VESC_PORT}
export HOST_IP=${HOST_IP}
export DMAAP_MR_IP=${DMAAP_MR_IP}

#Get DataFileCollector POD name in this ONAP Deployment
DFC_POD=$(kubectl -n onap get pods | grep datafile-collector | awk '{print $1}')
export DFC_POD=${DFC_POD}

pip install jsonschema uuid simplejson

# Clone DMaaP Data Router repo
mkdir -p $WORKSPACE/archives/dmaapdr
cd $WORKSPACE/archives/dmaapdr
git clone --depth 1 https://gerrit.onap.org/r/dmaap/datarouter -b master
cd $WORKSPACE/archives/dmaapdr/datarouter/datarouter-docker-compose/src/main/resources
mkdir docker-compose
cd $WORKSPACE/archives/dmaapdr/datarouter/datarouter-docker-compose/src/main/resources/docker-compose
cp $WORKSPACE/plans/usecases/5G-bulkpm/composefile/onap.docker-compose-e2e $WORKSPACE/archives/dmaapdr/datarouter/datarouter-docker-compose/src/main/resources/docker-compose/docker-compose.yml

#Statup the SFTP and FileConsumer containers.
docker login -u docker -p docker nexus3.onap.org:10001
docker-compose up -d

# Wait container ready
sleep 2
HOST_IP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}')
# SFTP Configuration:
# Update the File Ready Notification with actual sftp ip address and copy pm files to sftp server.
cp $WORKSPACE/tests/usecases/5G-bulkpm/assets/json_events/FileExistNotification.json $WORKSPACE/tests/usecases/5G-bulkpm/assets/json_events/FileExistNotificationUpdated.json
sed -i 's/sftpserver/'${HOST_IP}'/g' $WORKSPACE/tests/usecases/5G-bulkpm/assets/json_events/FileExistNotificationUpdated.json
sed -i 's/sftpport/'${SFTP_PORT}'/g' $WORKSPACE/tests/usecases/5G-bulkpm/assets/json_events/FileExistNotificationUpdated.json
docker cp $WORKSPACE/plans/usecases/5G-bulkpm/assets/xNF.pm.xml.gz sftp:/home/admin/

# Create default feed and create file consumer subscriber on data router
curl -v -X POST -H "Content-Type:application/vnd.att-dr.feed" -H "X-ATT-DR-ON-BEHALF-OF:dradmin" --data-ascii @$WORKSPACE/plans/usecases/5G-bulkpm/assets/createFeed.json --post301 --location-trusted -k https://${DR_PROV_IP}:8443
cp $WORKSPACE/plans/usecases/5G-bulkpm/assets/addSubscriber.json /tmp/addSubscriber.json
sed -i 's/fileconsumer/'${HOST_IP}'/g' /tmp/addSubscriber.json
curl -v -X POST -H "Content-Type:application/vnd.att-dr.subscription" -H "X-ATT-DR-ON-BEHALF-OF:dradmin" --data-ascii @/tmp/addSubscriber.json --post301 --location-trusted -k https://${DR_PROV_IP}:8443/subscribe/1
sleep 10
curl -k https://$DR_PROV_IP:8443/internal/prov

#Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v DR_PROV_IP:${DR_PROV_IP} -v DR_NODE_IP:${DR_NODE_IP} -v DMAAP_MR_IP:${DMAAP_MR_IP} -v VESC_IP:${VESC_IP} -v VESC_PORT:${VESC_PORT} -v DR_SUBSCIBER_IP:${DR_SUBSCIBER_IP} -v DFC_POD:${DFC_POD} -v HOST_IP:${HOST_IP} "

fi;