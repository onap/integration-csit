#!/bin/bash
# ============LICENSE_START=======================================================
#  Copyright (C) 2018 Ericsson. All rights reserved.
#
#  Modifications copyright (c) 2019 Nordix Foundation.
#  Modifications Copyright (C) 2020 AT&T Intellectual Property.
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

# the directory of the script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo ${DIR}

# the temp directory used, within $DIR
# omit the -p parameter to create a temporal directory in the default location
WORK_DIR=`mktemp -d -p "$DIR"`
echo ${WORK_DIR}

cd ${WORK_DIR}

# check if tmp dir was created
if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
  echo "Could not create temp dir"
  exit 1
fi

sudo apt-get -y install libxml2-utils
bash ${SCRIPTS}/policy/policy-models-dmaap-sim.sh

POLICY_API_VERSION_EXTRACT="$(curl -q --silent https://git.onap.org/policy/api/plain/pom.xml?h=${GERRIT_BRANCH} | xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)"
export POLICY_API_VERSION="${POLICY_API_VERSION_EXTRACT:0:3}-SNAPSHOT-latest"
POLICY_PAP_VERSION_EXTRACT="$(curl -q --silent https://git.onap.org/policy/pap/plain/pom.xml?h=${GERRIT_BRANCH} | xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)"
export POLICY_PAP_VERSION="${POLICY_PAP_VERSION_EXTRACT:0:3}-SNAPSHOT-latest"
POLICY_APEX_PDP_VERSION_EXTRACT="$(curl -q --silent https://git.onap.org/policy/apex-pdp/plain/pom.xml?h=${GERRIT_BRANCH} | xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)"
export POLICY_APEX_PDP_VERSION="${POLICY_APEX_PDP_VERSION_EXTRACT:0:3}-SNAPSHOT-latest"
POLICY_DISTRIBUTION_VERSION_EXTRACT="$(curl -q --silent https://git.onap.org/policy/distribution/plain/pom.xml?h=${GERRIT_BRANCH} | xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)"
export POLICY_DISTRIBUTION_VERSION="${POLICY_DISTRIBUTION_VERSION_EXTRACT:0:3}-SNAPSHOT-latest"

echo ${POLICY_API_VERSION}
echo ${POLICY_PAP_VERSION}
echo ${POLICY_APEX_PDP_VERSION}
echo ${POLICY_DISTRIBUTION_VERSION}

SCRIPT_DIR=${WORKSPACE}/scripts/policy/policy-distribution

# Remaking the csar file in case if the file got corrupted
zip -F ${SCRIPT_DIR}/config/distribution/csar/sample_csar_with_apex_policy.csar --out ${SCRIPT_DIR}/config/distribution/csar/csar_temp.csar

# Adding this waiting container due to race condition between pap and mariadb
docker-compose -f ${SCRIPT_DIR}/docker-compose-distribution.yml run --rm start_dependencies

#Configure the database
docker exec --tty mariadb  chmod +x /docker-entrypoint-initdb.d/db.sh
docker exec --tty mariadb  /docker-entrypoint-initdb.d/db.sh

# now bring everything else up
docker-compose -f ${SCRIPT_DIR}/docker-compose-distribution.yml run --rm start_all

unset http_proxy https_proxy

POLICY_API_IP=`get-instance-ip.sh policy-api`
POLICY_PAP_IP=`get-instance-ip.sh policy-pap`
MARIADB_IP=`get-instance-ip.sh mariadb`
APEX_IP=`get-instance-ip.sh policy-apex-pdp`
DMAAP_IP=`get-instance-ip.sh dmaap-simulator`
POLICY_DISTRIBUTION_IP=`get-instance-ip.sh policy-distribution`

echo PAP IP IS ${POLICY_PAP_IP}
echo MARIADB IP IS ${MARIADB_IP}
echo API IP IS ${POLICY_API_IP}
echo APEX IP IS ${APEX_IP}
echo DMAAP_IP IS ${DMAAP_IP}
echo POLICY_DISTRIBUTION_IP IS ${POLICY_DISTRIBUTION_IP}

ROBOT_VARIABLES="-v APEX_IP:${APEX_IP} -v SCRIPT_DIR:${SCRIPT_DIR} -v POLICY_DISTRIBUTION_IP:${POLICY_DISTRIBUTION_IP}"
