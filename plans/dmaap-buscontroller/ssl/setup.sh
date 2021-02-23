#!/bin/bash
# 
# ============LICENSE_START=======================================================
# org.onap.dmaap
# ================================================================================
# Copyright (C) 2018 AT&T Intellectual Property. All rights reserved.
# Modification copyright (C) 2021 Samsung Electronics Co., Ltd.
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


# Place the scripts in run order:

source ${WORKSPACE}/scripts/dmaap-buscontroller/dmaapbc-launch.sh 
dmaapbc_launch
DMAAPBC_IP=${IP}

echo "DMAAPBC_IP=$DMAAPBC_IP"

# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v DMAAPBC_IP:${DMAAPBC_IP}"

set -x
${WORKSPACE}/scripts/dmaap-buscontroller/dmaapbc-init.sh ${DMAAPBC_IP} 0 0 https
set +x
