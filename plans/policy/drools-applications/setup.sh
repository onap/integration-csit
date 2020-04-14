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

# Adding this waiting container due to race condition between drools and mariadb
docker-compose -f ${SCR2}/docker-compose-drools-apps.yml run --rm start_dependencies

# now bring everything else up
docker-compose -f ${SCR2}/docker-compose-drools-apps.yml run --rm start_all

unset http_proxy https_proxy

DROOLS_IP=`get-instance-ip.sh drools`
XACML_IP=`get-instance-ip.sh policy-xacml-pdp`
SIM_IP=`get-instance-ip.sh policy.api.simpledemo.onap.org`
export SIM_IP

echo DROOLS IP IS ${DROOLS_IP}
echo XACML IP IS ${XACML_IP}
echo SIMULATORS IP IS ${SIM_IP}

# activate xacml
${SCR2}/manage.sh ${SCR2}/activate.xacml.json

# give enough time for the controllers to come up
sleep 15

# wait for xacml to activate
${SCRIPTS}/policy/wait_for_port.sh ${XACML_IP} 6969

ROBOT_VARIABLES=""
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v SCR2:${SCR2}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v DROOLS_IP:${DROOLS_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v XACML_IP:${XACML_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v SIM_IP:${SIM_IP}"
