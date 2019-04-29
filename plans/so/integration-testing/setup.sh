#!/bin/bash
#
# Copyright 2016-2017 Huawei Technologies Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Place the scripts in run order:
# Start all process required for executing test case

pushd ${WORKSPACE}/plans/so/integration-testing/
export NEXUS_DOCKER_REPO_MSO=nexus3.onap.org:10001
export TAG=1.3.7

# bring the so dockers
docker-compose pull
docker-compose up -d

MOCK_IP=`get-instance-ip.sh integrationtesting_mockserver_1`
echo ${MOCK_IP}

docker inspect integrationtesting_mockserver_1

# Wait for initialization
for i in {1..10}; do
    curl -sS ${MOCK_IP}:1080 && break
    echo sleep $i
    sleep $i
    done

${WORKSPACE}/scripts/so/mock-hello.sh ${MOCK_IP}

sleep 4m
popd

#REPO_IP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' so`
REPO_IP='127.0.0.1'
# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v MOCK_IP:${MOCK_IP} -v MOCK_PORT:1080 -v REPO_IP:${REPO_IP}"
