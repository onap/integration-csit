#!/bin/bash
#
# Copyright 2016-2017 Huawei Technologies Co., Ltd.
# Copyright 2020 Nokia.
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
# These scripts are sourced by run-csit.sh.

VNFSDK_REFREPO_DOCKER_VERSION=latest

#Start market place
docker run -d -i -t --name refrepo -p 8702:8702 nexus3.onap.org:10001/onap/vnfsdk/refrepo:$VNFSDK_REFREPO_DOCKER_VERSION
DOCKER_IP=`get-docker-network-ip.sh`

# Wait for Market place initialization
echo Wait for VNF Repository initialization
# Active waiting with healthcheck and max retry count
MAX_RETRY=30
TRY=1
while (( $(curl -s -o /dev/null -w ''%{http_code}'' ${DOCKER_IP}:8702/onapapi/vnfsdk-marketplace/v1/PackageResource/healthcheck) != 200 )) && (($TRY < $MAX_RETRY)); do
  sleep 4
  TRY=$[$TRY+1]
done

REFREPO_IP=`get-instance-ip.sh refrepo`

# Get refrepo logs for easier debug in case of failure
docker logs refrepo

# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v SCRIPTS:${SCRIPTS} -v REFREPO_IP:${REFREPO_IP}"
echo ${ROBOT_VARIABLES}
