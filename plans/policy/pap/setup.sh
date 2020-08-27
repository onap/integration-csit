#!/bin/bash
# ============LICENSE_START=======================================================
#  Copyright (C) 2019 Nordix Foundation.
#  Modifications Copyright (C) 2019-2020 AT&T Intellectual Property.
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
POLICY_PAP_VERSION_EXTRACT="$(curl -q --silent https://git.onap.org/policy/pap/plain/pom.xml?h=${GERRIT_BRANCH} | xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)"
export POLICY_PAP_VERSION="${POLICY_PAP_VERSION_EXTRACT:0:3}-SNAPSHOT-latest"
echo ${POLICY_API_VERSION}
echo ${POLICY_PAP_VERSION}
# Adding this waiting container due to race condition between pap and mariadb
docker-compose -f ${WORKSPACE}/scripts/policy/docker-compose-pap.yml run --rm start_dependencies

#Configure the database
docker exec --tty mariadb  chmod +x /docker-entrypoint-initdb.d/db.sh
docker exec --tty mariadb  /docker-entrypoint-initdb.d/db.sh

# now bring everything else up
docker-compose -f ${WORKSPACE}/scripts/policy/docker-compose-pap.yml run --rm start_all

unset http_proxy https_proxy


POLICY_PAP_IP=`get-instance-ip.sh policy-pap`
POLICY_API_IP=`get-instance-ip.sh policy-api`
MARIADB_IP=`get-instance-ip.sh mariadb`

echo PAP IP IS ${POLICY_PAP_IP}
echo API IP IS ${POLICY_API_IP}
echo MARIADB IP IS ${MARIADB_IP}

ROBOT_VARIABLES=""
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_PAP_IP:${POLICY_PAP_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_API_IP:${POLICY_API_IP}"