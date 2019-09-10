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

git clone http://gerrit.onap.org/r/so/docker-config.git test_lab

export NEXUS_DOCKER_REPO_MSO=nexus3.onap.org:10001
export TAG=1.5.1

# bring the so dockers
docker-compose pull
docker-compose up -d

sleep 4m

#REPO_IP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' so`
REPO_IP='127.0.0.1'
# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v REPO_IP:${REPO_IP}"
