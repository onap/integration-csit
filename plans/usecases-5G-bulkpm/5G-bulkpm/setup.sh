#!/bin/bash
# Place the scripts in run order:
source ${SCRIPTS}/common_functions.sh

# Clone DMaaP Message Router repo
mkdir -p $WORKSPACE/archives/dmaapmr
cd $WORKSPACE/archives/dmaapmr
git clone --depth 1 http://gerrit.onap.org/r/dmaap/messagerouter/messageservice -b master
mkdir $WORKSPACE/archives/dmaapmr/messageservice/src/main/resources/docker-compose/tmp/
# Copy custom docker-compose file
cp $WORKSPACE/plans/usecases-5G-bulkpm/5G-bulkpm/composefile/docker-compose-mr.yml \
$WORKSPACE/archives/dmaapmr/messageservice/src/main/resources/docker-compose/tmp/docker-compose-mr.yml

# Login to onap docker
docker login -u docker -p docker nexus3.onap.org:10001
# Start DMaaP MR containers with docker compose and configuration from docker-compose-mr.yml
docker-compose -f $WORKSPACE/archives/dmaapmr/messageservice/src/main/resources/docker-compose/tmp/docker-compose-mr.yml up -d
sleep 5

# Wait for initialization of Docker contaienr for DMaaP MR, Kafka and Zookeeper
for i in 1 2 3 4 5 6 7 8 9 10; do
    if [[ $(docker inspect --format '{{ .State.Running }}' dmaap-message-router-kafka) ]] && \
        [[ $(docker inspect --format '{{ .State.Running }}' dmaap-message-router-zookeeper) ]] && \
        [[ $(docker inspect --format '{{ .State.Running }}' dmaap-message-router-server) ]]
    then
       echo "Message Router service running"
       break
    else
       echo sleep ${i}
       sleep ${i}
    fi
done

# Clone DMaaP Data Router repo
mkdir -p $WORKSPACE/archives/dmaapdr
cd $WORKSPACE/archives/dmaapdr
git clone --depth 1 https://gerrit.onap.org/r/dmaap/datarouter -b master
mkdir $WORKSPACE/archives/dmaapdr/datarouter/datarouter-docker-compose/src/main/resources/docker-compose

# Copy e2e docker compose assets to tmp dir
cp $WORKSPACE/plans/usecases-5G-bulkpm/5G-bulkpm/composefile/docker-compose-e2e.yml \
$WORKSPACE/archives/dmaapdr/datarouter/datarouter-docker-compose/src/main/resources/docker-compose/docker-compose-e2e.yml
cp -rf $WORKSPACE/plans/usecases-5G-bulkpm/5G-bulkpm/assets/cbs_sim/ \
$WORKSPACE/archives/dmaapdr/datarouter/datarouter-docker-compose/src/main/resources/docker-compose/
cp -rf $WORKSPACE/plans/usecases-5G-bulkpm/5G-bulkpm/assets/dfc/ \
$WORKSPACE/archives/dmaapdr/datarouter/datarouter-docker-compose/src/main/resources/docker-compose/
cp -rf $WORKSPACE/plans/usecases-5G-bulkpm/5G-bulkpm/assets/pm_mapper_certs/ \
$WORKSPACE/archives/dmaapdr/datarouter/datarouter-docker-compose/src/main/resources/docker-compose/

# Start cbs-sim for pmmapper stability
docker-compose -f $WORKSPACE/archives/dmaapdr/datarouter/datarouter-docker-compose/src/main/resources/docker-compose/docker-compose-e2e.yml up -d cbs-sim
echo "Starting cbs-sim"
sleep 10

# Start the rest of the e2e containers
docker-compose -f $WORKSPACE/archives/dmaapdr/datarouter/datarouter-docker-compose/src/main/resources/docker-compose/docker-compose-e2e.yml up -d

# Wait for initialization of the following containers
for i in 1 2 3 4 5 6 7 8 9 10; do
    if [[ $(docker inspect --format '{{ .State.Running }}' dmaap-datarouter-node) ]] && \
        [[ $(docker inspect --format '{{ .State.Running }}' dmaap-datarouter-prov) ]] && \
        [[ $(docker inspect --format '{{ .State.Running }}' dmaap-dr-prov-mariadb) ]] && \
        [[ $(docker inspect --format '{{ .State.Running }}' dcaegen2-pm-mapper) ]] && \
        [[ $(docker inspect --format '{{ .State.Running }}' dcaegen2-datafile-collector) ]]
    then
        echo "Data Router service running"
        break
    else
        echo sleep ${i}
        sleep ${i}
    fi
done

# Get IP address of docker-host, dmaap-dr-prov, dmaap-dr-gateway, dmaap-mr and ves collector.
#HOST_IP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $7}')
DR_PROV_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dmaap-datarouter-prov)
DR_GATEWAY_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}' dmaap-datarouter-prov)
DMAAP_MR_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dmaap-message-router-server)
VESC_IP=$(docker inspect '--format={{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dcaegen2-vescollector)

#Add SFTP server pubilc key to known hosts of datafile collector
HOST_NAMES=$(docker inspect -f '{{ range .NetworkSettings.Networks}}{{join .Aliases ","}}{{end}}' sftp)
KEY_ENTRY=$(echo $HOST_NAMES "$(docker exec sftp cat /etc/ssh/ssh_host_rsa_key.pub)" | sed -e 's/\w*@\w*$//')
docker exec -i -u root dcaegen2-datafile-collector sh -c "echo $KEY_ENTRY >> /opt/app/datafile/known_hosts"

# Add gateway IP to DR Prov
docker exec -i datarouter-prov sh -c "curl -k  -X PUT https://$DR_PROV_IP:8443/internal/api/NODES?val=dmaap-dr-node\|$DR_GATEWAY_IP"
docker exec -i datarouter-prov sh -c "curl -k  -X PUT https://$DR_PROV_IP:8443/internal/api/PROV_AUTH_ADDRESSES?val=dmaap-dr-prov\|$DR_GATEWAY_IP"

#Increase DFC Logging
#docker exec dfc /bin/sh -c " sed -i 's/org.onap.dcaegen2.collectors.datafile: WARN/org.onap.dcaegen2.collectors.datafile: TRACE/g' /opt/app/datafile/config/application.yaml"

# Copy sample PM file to sftp server
docker cp $WORKSPACE/plans/usecases-5G-bulkpm/5G-bulkpm/assets/A20181002.0000-1000-0015-1000_5G.xml.gz sftp:/home/admin/

# Data Router Configuration:
# Create default feed on DMaaP data router
curl -v -X POST -H "Content-Type:application/vnd.dmaap-dr.feed" -H "X-DMAAP-DR-ON-BEHALF-OF:dradmin" \
--data-ascii @$WORKSPACE/plans/usecases-5G-bulkpm/5G-bulkpm/assets/dmaap_dr/createFeed.json --post301 \
--location-trusted -k https://${DR_PROV_IP}:8443
sleep 2
# Create file consumer subscriber on DMaaP data router
curl -X POST -H "Content-Type:application/vnd.dmaap-dr.subscription" -H "X-DMAAP-DR-ON-BEHALF-OF:dradmin" \
--data-ascii @$WORKSPACE/plans/usecases-5G-bulkpm/5G-bulkpm/assets/dmaap_dr/addDefaultSubscriber.json --post301 \
--location-trusted -k https://${DR_PROV_IP}:8443/subscribe/1
sleep 2
# Add PM Mapper subscriber on data router feed
curl -v -X POST -H "Content-Type:application/vnd.dmaap-dr.subscription" -H "X-DMAAP-DR-ON-BEHALF-OF:pmmapper" \
--data-ascii @$WORKSPACE/plans/usecases-5G-bulkpm/5G-bulkpm/assets/dmaap_dr/addPmMapperSubscriber.json \
--post301 --location-trusted -k https://${DR_PROV_IP}:8443/subscribe/1

# Check DMaaP DR provisioning
curl -k https://${DR_PROV_IP}:8443/internal/prov

# Add necessary python libs
pip install jsonschema uuid simplejson

# Export necessary vars
export VESC_IP=${VESC_IP}
export VESC_PORT=8080
export DMAAP_MR_IP=${DMAAP_MR_IP}

#Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v DR_PROV_IP:${DR_PROV_IP} -v DMAAP_MR_IP:${DMAAP_MR_IP} -v VESC_IP:${VESC_IP} -v VESC_PORT:${VESC_PORT}"
