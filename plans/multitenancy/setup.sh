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
docker pull registry-dev.nso.lab-services.ca/nso-image/multi-tenancy-test-suite:latest
docker run --name multi-tenancy -d registry-dev.nso.lab-services.ca/nso-image/multi-tenancy-test-suite:latest

MOCK_IP=`get-instance-ip.sh multi-tenancy`

# Wait for initialization
for i in {1..10}; do
    curl -sS ${MOCK_IP}:1080 && break
    echo sleep $i
    sleep $i
done

${WORKSPACE}/scripts/multitenancy/mock-hello.sh ${MOCK_IP}

# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v MOCK_IP:${MOCK_IP}"




