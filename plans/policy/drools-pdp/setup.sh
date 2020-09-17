#!/bin/bash
# ============LICENSE_START=======================================================
# Copyright 2017-2020 AT&T Intellectual Property. All rights reserved.
# ================================================================================
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
# SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================

# OS upgrades

echo "Uninstall docker-py and reinstall docker."
pip uninstall -y docker-py
pip uninstall -y docker
pip install -U docker==2.7.0

# Component Versions

source ${SCRIPTS}/policy/config/policy-csit.conf

sudo apt-get -y install libxml2-utils

source ${SCRIPTS}/policy/detmVers.sh

docker-compose -f ${SCRIPTS}/policy/docker-compose-all.yml up -d drools

POLICY_DROOLS_IP=`get-instance-ip.sh drools`
MARIADB_IP=`get-instance-ip.sh mariadb`

echo DROOLS IP IS ${POLICY_DROOLS_IP}
echo MARIADB IP IS ${MARIADB_IP}

# wait for the app to start up - looking for telemtry service on port 9696
${SCRIPTS}/policy/wait_for_port.sh ${POLICY_DROOLS_IP} 9696

# give enough time for the controllers to come up
sleep 15

ROBOT_VARIABLES="-v POLICY_DROOLS_IP:${POLICY_DROOLS_IP}"
