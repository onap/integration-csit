#!/bin/bash
#
# ============LICENSE_START=======================================================
#  Copyright (C) 2021 Nordix Foundation.
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

function dmaap_dr_launch() {

    subscribers_required=$1
    mkdir -p ${WORKSPACE}/archives/dmaap/dr/last_run_logs
    cd ${WORKSPACE}/scripts/dmaap-datarouter/docker-compose

    # start DMaaP DR containers with docker compose and configuration from docker-compose.yml
    docker login -u docker -p docker nexus3.onap.org:10001
    if [[ ${subscribers_required} == true ]]; then
		docker-compose up -d
    else
        docker-compose up -d datarouter-prov datarouter-node mariadb
	fi

    # Wait for initialization of Docker container for datarouter-node, datarouter-prov and mariadb
    for i in 1 2 3 4 5 6 7 8 9 10; do
        if [[ $(docker inspect --format '{{ .State.Running }}' datarouter-node) ]] && \
            [[ $(docker inspect --format '{{ .State.Running }}' datarouter-prov) ]] && \
            [[ $(docker inspect --format '{{ .State.Running }}' mariadb) ]]
        then
            echo "DR Service Running"
            break
        else
            echo sleep ${i}
            sleep ${i}
        fi
    done

    # Wait for healthy container datarouter-prov
    for i in 1 2 3 4 5 6 7 8 9 10; do
        if [[ "$(docker inspect --format '{{ .State.Health.Status }}' datarouter-prov)" = 'healthy' ]]
        then
            echo datarouter-prov.State.Health.Status is $(docker inspect --format '{{ .State.Health.Status }}' datarouter-prov)
            echo "DR Service Running, datarouter-prov container is healthy"
            break
        else
            echo datarouter-prov.State.Health.Status is $(docker inspect --format '{{ .State.Health.Status }}' datarouter-prov)
            echo sleep ${i}
            sleep ${i}
            if [[ ${i} = 10 ]]
            then
                echo datarouter-prov container is not in healthy state - the test is not made, teardown...
                docker-compose rm -sf
                exit 1
            fi
        fi
    done

    DR_PROV_IP=`get-instance-ip.sh datarouter-prov`
    DR_NODE_IP=`get-instance-ip.sh datarouter-node`
    DR_GATEWAY_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}' datarouter-prov)
    echo DR_PROV_IP=${DR_PROV_IP}
    echo DR_NODE_IP=${DR_NODE_IP}
    echo DR_GATEWAY_IP=${DR_GATEWAY_IP}
    if [[ ${subscribers_required} == true ]]
	then
		DR_SUB_IP=`get-instance-ip.sh subscriber-node`
        DR_SUB2_IP=`get-instance-ip.sh subscriber-node2`
        echo DR_SUB_IP=${DR_SUB_IP}
        echo DR_SUB2_IP=${DR_SUB2_IP}
	fi


    sudo sed -i "$ a $DR_PROV_IP dmaap-dr-prov" /etc/hosts
    sudo sed -i "$ a $DR_NODE_IP dmaap-dr-node" /etc/hosts

    docker exec -i datarouter-prov sh -c "curl -k -X PUT https://$DR_PROV_IP:8443/internal/api/PROV_AUTH_ADDRESSES?val=dmaap-dr-prov\|$DR_GATEWAY_IP"

    #Pass any variables required by Robot test suites in ROBOT_VARIABLES
    ROBOT_VARIABLES="-v DR_PROV_IP:${DR_PROV_IP} -v DR_NODE_IP:${DR_NODE_IP} -v DR_SUB_IP:${DR_SUB_IP} -v DR_SUB2_IP:${DR_SUB2_IP}"
}