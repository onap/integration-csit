#!/bin/bash
# ============LICENSE_START=======================================================
#  Copyright (C) 2019-2020 AT&T Intellectual Property. All rights reserved.
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

# Select branch
source ${SCRIPTS}/policy/config/policy-csit.conf
export POLICY_MARIADB_VER
echo ${GERRIT_BRANCH}
echo ${POLICY_MARIADB_VER}

echo "Uninstall docker-py and reinstall docker."
pip uninstall -y docker-py
pip uninstall -y docker
pip install -U docker==2.7.0


sudo apt-get -y install libxml2-utils
POLICY_API_VERSION_EXTRACT="$(curl -q --silent https://git.onap.org/policy/api/plain/pom.xml?h=${GERRIT_BRANCH} | xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)"
export POLICY_API_VERSION="${POLICY_API_VERSION_EXTRACT:0:3}-SNAPSHOT-latest"

# download models - it contains the policy definitions
rm -rf ${WORKSPACE}/models
cd ${WORKSPACE}

git clone --depth 1 https://gerrit.onap.org/r/policy/models -b ${GERRIT_BRANCH}

# create a couple of variations of the policy definitions
sed -e 's!Measurement_vGMUX!ADifferentValue!' models/models-examples/src/main/resources/policies/vCPE.policy.monitoring.input.tosca.json >models/models-examples/src/main/resources/policies/vCPE.policy.monitoring.input.tosca.v1_2.json

sed -e 's!"version": "1.0.0"!"version": "2.0.0"!' -e 's!"policy-version": 1!"policy-version": 2!' models/models-examples/src/main/resources/policies/vCPE.policy.monitoring.input.tosca.json >models/models-examples/src/main/resources/policies/vCPE.policy.monitoring.input.tosca.v2.json

echo ${POLICY_API_VERSION}

# Adding this waiting container to avoid race condition between api and mariadb containers.
docker-compose -f ${WORKSPACE}/scripts/policy/docker-compose-api.yml run --rm start_dependencies

#Configure the database
docker exec --tty mariadb  chmod +x /docker-entrypoint-initdb.d/db.sh
docker exec --tty mariadb  /docker-entrypoint-initdb.d/db.sh

# now bring everything else up
docker-compose -f ${WORKSPACE}/scripts/policy/docker-compose-api.yml run --rm start_all

unset http_proxy https_proxy

POLICY_API_IP=`get-instance-ip.sh policy-api`
MARIADB_IP=`get-instance-ip.sh mariadb`

echo API IP IS ${POLICY_API_IP}
echo MARIADB IP IS ${MARIADB_IP}

DATA=${WORKSPACE}/models/models-examples/src/main/resources/policies

ROBOT_VARIABLES=""
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_API_IP:${POLICY_API_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v DATA:${DATA}"
