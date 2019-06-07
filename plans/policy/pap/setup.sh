#!/bin/bash
# ============LICENSE_START=======================================================
#  Copyright (C) 2019 Nordix Foundation.
#  Modifications Copyright (C) 2019 AT&T Intellectual Property.
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

GERRIT_BRANCH=$(git branch | grep \* | cut -d ' ' -f2)

echo "Uninstall docker-py and reinstall docker."
pip uninstall -y docker-py
pip uninstall -y docker
pip install -U docker==2.7.0

# Provide list of policy projects whose version numbers we need.
# The script would populate the versions array according to this input array's order
array=(${GERRIT_BRANCH} "api" "pap")
source ${WORKSPACE}/scripts/policy/get-versions.sh "${array[@]}"
echo "${PROJECT_VERSIONS[@]}"
#Check if input and out array lengths are equal
if [ "${#PROJECT_VERSIONS[@]}" -ne "$(expr ${#array[@]} - 1)" ]; then 
    echo "ERROR: Input and Output array lengths are not equal"
    echo "ERROR: Potentially wrong versions of docker images are being pulled."
    export POLICY_API_VERSION=latest
    export POLICY_PAP_VERSION=latest
else
    export POLICY_API_VERSION=${PROJECT_VERSIONS[0]}
    export POLICY_PAP_VERSION=${PROJECT_VERSIONS[1]}
fi

echo $POLICY_API_VERSION
echo $POLICY_PAP_VERSION
# Adding this waiting container due to race condition between pap and mariadb
docker-compose -f ${WORKSPACE}/scripts/policy/docker-compose-pap.yml run --rm start_dependencies

#Configure the database
docker exec -it mariadb  chmod +x /docker-entrypoint-initdb.d/db.sh
docker exec -it mariadb  /docker-entrypoint-initdb.d/db.sh

# now bring everything else up
docker-compose -f ${WORKSPACE}/scripts/policy/docker-compose-pap.yml run --rm start_all

unset http_proxy https_proxy


POLICY_PAP_IP=`get-instance-ip.sh policy-pap`
POLICY_API_IP=`get-instance-ip.sh policy-api`
MARIADB_IP=`get-instance-ip.sh mariadb`

echo PAP IP IS ${POLICY_PAP_IP}
echo API IP IS ${POLICY_API_IP}
echo MARIADB IP IS ${MARIADB_IP}

#Add policy type and policy to the database via the Policy Api
AUTH="healthcheck:zb!XztG34"
CONTYPE="Content-Type: application/json"
URL=https://${POLICY_API_IP}:6969/policy/api/v1/policytypes
CONFIGDIR=${WORKSPACE}/scripts/policy/config/pap
POLTYPE=onap.policies.monitoring.cdap.tca.hi.lo.app

SRCFILE=${CONFIGDIR}/${POLTYPE}.json
curl -sS -k --user "${AUTH}" -H "${CONTYPE}" -d @${SRCFILE} $URL

URL2=${URL}/${POLTYPE}/versions/1.0.0/policies
SRCFILE=${CONFIGDIR}/vCPE.policy.monitoring.input.tosca.json
curl -sS -k --user "${AUTH}" -H "${CONTYPE}" -d @${SRCFILE} $URL2


ROBOT_VARIABLES="-v POLICY_PAP_IP:${POLICY_PAP_IP}"
