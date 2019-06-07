#!/bin/bash
# ============LICENSE_START=======================================================
#  Copyright (C) 2019 AT&T Intellectual Property. All rights reserved.
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
GERRIT_BRANCH="dublin"

echo "Uninstall docker-py and reinstall docker."
pip uninstall -y docker-py
pip uninstall -y docker
pip install -U docker==2.7.0


# Provide list of policy projects whose version numbers we need.
array=(${GERRIT_BRANCH} "api")
source ${WORKSPACE}/scripts/policy/get-versions.sh "${array[@]}"
echo "${PROJECT_VERSIONS[@]}"
#Check if input and out array lengths are equal
if [ "${#PROJECT_VERSIONS[@]}" -ne "$(expr ${#array[@]} - 1)" ]; then 
    echo "Input and output array lengths are not equal"
    echo "ERROR: Potentially wrong versions of docker images are being pulled."
    API_VERSION=latest
else
    API_VERSION=${PROJECT_VERSIONS[0]}
fi

echo $API_VERSION
# Adding this waiting container to avoid race condition between api and mariadb containers.
# Passing POLICY_API_VERSION for API container.
POLICY_API_VERSION=$API_VERSION docker-compose -f ${WORKSPACE}/scripts/policy/docker-compose-api.yml run --rm start_dependencies

#Configure the database
docker exec -it mariadb  chmod +x /docker-entrypoint-initdb.d/db.sh
docker exec -it mariadb  /docker-entrypoint-initdb.d/db.sh

# now bring everything else up
POLICY_API_VERSION=$API_VERSION docker-compose -f ${WORKSPACE}/scripts/policy/docker-compose-api.yml run --rm start_all

unset http_proxy https_proxy

POLICY_API_IP=`get-instance-ip.sh policy-api`
MARIADB_IP=`get-instance-ip.sh mariadb`

echo API IP IS ${POLICY_API_IP}
echo MARIADB IP IS ${MARIADB_IP}

ROBOT_VARIABLES="-v POLICY_API_IP:${POLICY_API_IP}"
