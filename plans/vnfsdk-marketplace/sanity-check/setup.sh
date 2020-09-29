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
# These scripts are sourced by run-csit.sh.

REFREPO_IMAGE_TAG=1.6.0-SNAPSHOT-STAGING-latest POSTGRES_IMAGE_TAG=latest docker-compose up -d

# Wait for Market place initialization
echo Wait for VNF Repository initialization
for i in {1..30}; do
    sleep 1
done

REFREPO_IP=`get-instance-ip.sh refrepo`

# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v SCRIPTS:${SCRIPTS} -v REPO_IP:${REFREPO_IP}"
echo ${ROBOT_VARIABLES}
