#!/bin/bash
# 
# ============LICENSE_START=======================================================
# org.onap.dmaap
# ================================================================================
# Copyright (C) 2018 AT&T Intellectual Property. All rights reserved.
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
# ============LICENSE_END=========================================================
# 
#
source ${SCRIPTS}/common_functions.sh

COMPOSE_PREFIX=${COMPOSE_PROJECT_NAME:-dockercompose}
export COMPOSE_PROJECT_NAME=$COMPOSE_PREFIX
echo "COMPOSE_PROJECT_NAME=$COMPOSE_PROJECT_NAME"
echo "COMPOSE_PREFIX=$COMPOSE_PREFIX"

source ${WORKSPACE}/scripts/dmaap-datarouter/datarouter-launch.sh
# Launch DR. If true is passed, 2 subscriber containers are also deployed, else false.
dmaap_dr_launch false
DRPS_IP=${DR_PROV_IP}

source ${WORKSPACE}/scripts/dmaap-buscontroller/dmaapbc-launch.sh
dmaapbc_launch ${DRPS_IP}
DMAAPBC_IP=${DMAAP_BC_IP}

echo "DRPS_IP=$DRPS_IP DMAAPBC_IP=$DMAAPBC_IP"

# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v DRPS_IP:${DRPS_IP} -v DMAAPBC_IP:${DMAAPBC_IP}"
set -x
${WORKSPACE}/scripts/dmaap-buscontroller/dmaapbc-init.sh ${DMAAPBC_IP}
set +x

