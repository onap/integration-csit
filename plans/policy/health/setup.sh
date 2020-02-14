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

# OS upgrades

echo "Uninstall docker-py and reinstall docker."
pip uninstall -y docker-py
pip uninstall -y docker
pip install -U docker==2.7.0

echo "user information: $(id)"
echo "docker information:"
docker -v && docker-compose -v && docker info

# Component Versions

source ${SCRIPTS}/policy/config/policy-csit.conf
export POLICY_MARIADB_VER
echo ${GERRIT_BRANCH}
echo ${POLICY_MARIADB_VER}

sudo apt-get -y install libxml2-utils
POLICY_ENGINE_VERSION_EXTRACT="$(curl -q --silent https://git.onap.org/policy/engine/plain/pom.xml?h=${GERRIT_BRANCH} | xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)"
echo ${POLICY_ENGINE_VERSION_EXTRACT}
export POLICY_ENGINE_VERSION="${POLICY_ENGINE_VERSION_EXTRACT:0:3}-SNAPSHOT-latest"
echo ${POLICY_ENGINE_VERSION}

export PRELOAD_POLICIES=false
docker-compose -f ${WORKSPACE}/scripts/policy/docker-compose-engine.yml up -d
sleep 3m

docker container ls -a

MARIADB_IP=`get-instance-ip.sh mariadb`
POLICY_PDPX_IP=`get-instance-ip.sh pdp`
POLICY_PAP_IP=`get-instance-ip.sh pap`
POLICY_BRMSGW_IP=`get-instance-ip.sh brmsgw`

echo MARIADB IP IS ${MARIADB_IP}
echo PDPX IP IS ${POLICY_PDPX_IP}
echo PAP IP IS ${POLICY_PAP_IP}
echo PAP IP IS ${POLICY_BRMSGW_IP}

# Wait for initialization
for i in {1..10}; do
   curl -sS ${MARIADB_IP}:3306 && break
   echo sleep $i
   sleep $i
done

docker container ls -a

docker logs mariadb
docker logs nexus
docker logs pdp
docker logs pap
docker logs brmsgw

export PDP_IP=${POLICY_PDPX_IP}
ROBOT_VARIABLES="-v PDP_IP:${POLICY_PDPX_IP}"
