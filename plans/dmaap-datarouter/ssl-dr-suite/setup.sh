#!/bin/bash
#
# ============LICENSE_START=======================================================
#  Copyright (C) 2019 Nordix Foundation.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================
#
source ${SCRIPTS}/common_functions.sh

# Clone DMaaP Data Router repo
mkdir -p $WORKSPACE/archives/dmaapdr
cd $WORKSPACE/archives/dmaapdr

git clone --depth 1 https://gerrit.onap.org/r/dmaap/datarouter -b master
cd datarouter
git pull
cd $WORKSPACE/archives/dmaapdr/datarouter/datarouter-docker-compose/src/main/resources

# start DMaaP DR containers with docker compose and configuration from docker-compose.yml
docker login -u docker -p docker nexus3.onap.org:10001
docker-compose up -d

# Wait for initialization of Docker container for datarouter-node, datarouter-prov and mariadb
for i in {1..10}; do
    if [ $(docker inspect --format '{{ .State.Running }}' datarouter-node) ] && \
        [ $(docker inspect --format '{{ .State.Running }}' datarouter-prov) ] && \
        [ $(docker inspect --format '{{ .State.Running }}' subscriber-node) ] && \
        [ $(docker inspect --format '{{ .State.Running }}' mariadb) ]
    then
        echo "DR Service Running"
        break
    else
        echo sleep $i
        sleep $i
    fi
done

DR_PROV_IP=`get-instance-ip.sh datarouter-prov`
DR_NODE_IP=`get-instance-ip.sh datarouter-node`
DR_SUB_IP=`get-instance-ip.sh subscriber-node`
DR_GATEWAY_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}' datarouter-prov)

echo DR_PROV_IP=${DR_PROV_IP}
echo DR_NODE_IP=${DR_NODE_IP}
echo DR_SUB_IP=${DR_SUB_IP}
echo DR_GATEWAY_IP=${DR_GATEWAY_IP}

sudo sed -i "$ a $DR_PROV_IP dmaap-dr-prov" /etc/hosts
sudo sed -i "$ a $DR_NODE_IP dmaap-dr-node" /etc/hosts

python $WORKSPACE/scripts/dmaap-datarouter/update_ca.py

docker exec -i datarouter-prov sh -c "curl -k  -X PUT https://dmaap-dr-prov:8443/internal/api/PROV_AUTH_ADDRESSES?val=dmaap-dr-prov\|$DR_GATEWAY_IP"

ROBOT_VARIABLES="-v DR_SUB_IP:${DR_SUB_IP}"