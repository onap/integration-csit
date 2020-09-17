#!/bin/bash
#
# ===========LICENSE_START====================================================
#  Copyright (C) 2019-2020 AT&T Intellectual Property. All rights reserved.
# ============================================================================
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
# ============LICENSE_END=====================================================
#

# OS upgrades

source ${SCRIPTS}/policy/config/policy-csit.conf
export POLICY_MARIADB_VER
echo ${GERRIT_BRANCH}
echo ${POLICY_MARIADB_VER}

SCR2=${WORKSPACE}/scripts/policy/drools-apps

echo "Uninstall docker-py and reinstall docker."
pip uninstall -y docker-py
pip uninstall -y docker
pip install -U docker==2.7.0

sudo apt-get -y install libxml2-utils
${SCRIPTS}/policy/policy-models-simulators.sh

POLICY_API_VERSION_EXTRACT="$(curl -q --silent https://git.onap.org/policy/api/plain/pom.xml?h=${GERRIT_BRANCH} | xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)"
export POLICY_API_VERSION="${POLICY_API_VERSION_EXTRACT:0:3}-SNAPSHOT-latest"
POLICY_PAP_VERSION_EXTRACT="$(curl -q --silent https://git.onap.org/policy/pap/plain/pom.xml?h=${GERRIT_BRANCH} | xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)"
export POLICY_PAP_VERSION="${POLICY_PAP_VERSION_EXTRACT:0:3}-SNAPSHOT-latest"
POLICY_XACML_PDP_VERSION_EXTRACT="$(curl -q --silent https://git.onap.org/policy/xacml-pdp/plain/pom.xml?h=${GERRIT_BRANCH} | xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)"
export POLICY_XACML_PDP_VERSION="${POLICY_XACML_PDP_VERSION_EXTRACT:0:3}-SNAPSHOT-latest"
POLICY_DROOLS_APPS_VERSION_EXTRACT="$(curl -q --silent https://git.onap.org/policy/drools-applications/plain/pom.xml?h=${GERRIT_BRANCH} | xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)"
echo ${POLICY_DROOLS_APPS_VERSION_EXTRACT}
export POLICY_DROOLS_APPS_VERSION="${POLICY_DROOLS_APPS_VERSION_EXTRACT:0:3}-SNAPSHOT-latest"

echo ${POLICY_XACML_PDP_VERSION}
echo ${POLICY_DROOLS_APPS_VERSION}

echo "user information: $(id)"
echo "docker and docker-compose versions:"
docker -v && docker-compose -v

docker-compose -f ${SCR2}/docker-compose-drools-apps.yml up drools

unset http_proxy https_proxy

DROOLS_IP=`get-instance-ip.sh drools`
API_IP=`get-instance-ip.sh policy-api`
PAP_IP=`get-instance-ip.sh policy-pap`
XACML_IP=`get-instance-ip.sh policy-xacml-pdp`
SIM_IP=`get-instance-ip.sh policy.api.simpledemo.onap.org`
export SIM_IP

echo DROOLS IP IS ${DROOLS_IP}
echo API IP IS ${API_IP}
echo PAP IP IS ${PAP_IP}
echo XACML IP IS ${XACML_IP}
echo SIMULATORS IP IS ${SIM_IP}

# wait for drools to start up
${SCRIPTS}/policy/wait_for_port.sh ${DROOLS_IP} 6969

# give enough time for the controllers to come up
sleep 15

DATA=${WORKSPACE}/simulators/models/models-examples/src/main/resources/policies

ROBOT_VARIABLES=""
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v SCR2:${SCR2}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v DATA:${DATA}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v DROOLS_IP:${DROOLS_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v API_IP:${API_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v PAP_IP:${PAP_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v XACML_IP:${XACML_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v SIM_IP:${SIM_IP}"
