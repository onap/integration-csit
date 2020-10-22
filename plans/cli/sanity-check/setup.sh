#!/bin/bash
#
# Copyright 2020 Huawei Technologies Co., Ltd.
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

source ${SCRIPTS}/common_functions.sh

# Start cli
docker run -d --name cli -e OPEN_CLI_MODE=daemon nexus3.onap.org:10001/onap/cli:6.0-STAGING-latest

# Wait for cli initialization
echo Wait for CLI initialization
for i in {1..40}; do
    sleep 1
done

CLI_IP=`get-instance-ip.sh cli`

# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v CLI_IP:${CLI_IP}"
