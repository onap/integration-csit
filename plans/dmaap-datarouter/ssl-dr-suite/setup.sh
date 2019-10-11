#!/bin/bash

source ${SCRIPTS}/common_functions.sh

# Clone DMaaP Data Router repo
mkdir -p $WORKSPACE/archives/dmaapdr
cd $WORKSPACE/archives/dmaapdr

git clone --depth 1 https://gerrit.onap.org/r/dmaap/datarouter -b master
cd datarouter
git pull
cd $WORKSPACE/archives/dmaapdr/datarouter/datarouter-docker-compose/src/main/resources
cp $WORKSPACE/plans/dmaap-datarouter/ssl-dr-suite/docker-compose/docker-compose.yml .
cp $WORKSPACE/plans/dmaap-datarouter/ssl-dr-suite/docker-compose/provserver.properties ./prov_data/provserver.properties
cp $WORKSPACE/plans/dmaap-datarouter/ssl-dr-suite/docker-compose/node.properties ./node_data/node.properties

# start DMaaP DR containers with docker compose and configuration from docker-compose.yml
docker login -u docker -p docker nexus3.onap.org:10001
docker-compose up -d

# Wait for initialization of Docker container for datarouter-node, datarouter-prov and mariadb
for i in {1..10}; do
    if [ $(docker inspect --format '{{ .State.Running }}' subscriber-node2) ] && \
        [ $(docker inspect --format '{{ .State.Running }}' subscriber-node) ] && \
        [ $(docker inspect --format '{{ .State.Running }}' datarouter-node) ] && \
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

# Wait for healthy container datarouter-prov
for i in {1..10}; do
    if [ "$(docker inspect --format '{{ .State.Health.Status }}' datarouter-prov)" = 'healthy' ]
    then
        echo datarouter-prov.State.Health.Status is $(docker inspect --format '{{ .State.Health.Status }}' datarouter-prov)
        echo "DR Service Running, datarouter-prov container is healthy"
        break
    else
        echo datarouter-prov.State.Health.Status is $(docker inspect --format '{{ .State.Health.Status }}' datarouter-prov)
        echo sleep $i
        sleep $i
        if [ $i = 10 ]
        then
            echo datarouter-prov container is not in healthy state - the test is not made, teardown...
            cd $WORKSPACE/archives/dmaapdr/datarouter/datarouter-docker-compose/src/main/resources
            docker-compose rm -sf
            exit 1
        fi
    fi
done

DR_PROV_IP=`get-instance-ip.sh datarouter-prov`
DR_NODE_IP=`get-instance-ip.sh datarouter-node`
DR_SUB_IP=`get-instance-ip.sh subscriber-node`
DR_SUB2_IP=`get-instance-ip.sh subscriber-node2`
DR_GATEWAY_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}' datarouter-prov)

echo DR_PROV_IP=${DR_PROV_IP}
echo DR_NODE_IP=${DR_NODE_IP}
echo DR_SUB_IP=${DR_SUB_IP}
echo DR_SUB2_IP=${DR_SUB2_IP}
echo DR_GATEWAY_IP=${DR_GATEWAY_IP}

sudo sed -i "$ a $DR_PROV_IP dmaap-dr-prov" /etc/hosts
sudo sed -i "$ a $DR_NODE_IP dmaap-dr-node" /etc/hosts

python $WORKSPACE/scripts/dmaap-datarouter/update_ca.py

docker exec -i datarouter-prov sh -c "curl -k -X PUT https://$DR_PROV_IP:8443/internal/api/PROV_AUTH_ADDRESSES?val=dmaap-dr-prov\|$DR_GATEWAY_IP"

#Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v DR_PROV_IP:${DR_PROV_IP} -v DR_NODE_IP:${DR_NODE_IP} -v DR_SUB_IP:${DR_SUB_IP} -v DR_SUB2_IP:${DR_SUB2_IP}"