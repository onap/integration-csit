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

# bring down maven
mkdir maven
cd maven
# download maven from automatically selected mirror server
curl -vLO  "https://www.apache.org/dyn/mirrors/mirrors.cgi?cca2=us&preferred=http://apache.claz.org/&action=download&filename=maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz"
if ! tar -xzvf apache-maven-3.3.9-bin.tar.gz ; then
    echo "Installation of maven has failed!"
    exit 1
fi
ls -l
export PATH=${PATH}:${WORK_DIR}/maven/apache-maven-3.3.9/bin
${WORK_DIR}/maven/apache-maven-3.3.9/bin/mvn -v
cd ..

git clone http://gerrit.onap.org/r/oparent
git clone --depth 1 https://gerrit.onap.org/r/policy/models -b ${GERRIT_BRANCH}
cd models/models-sim/models-sim-dmaap
${WORK_DIR}/maven/apache-maven-3.3.9/bin/mvn clean install -DskipTests  --settings ${WORK_DIR}/oparent/settings.xml
bash ./src/main/package/docker/docker_build.sh
cd ${WORKSPACE}
rm -rf ${WORK_DIR}
sleep 3



sudo apt-get -y install libxml2-utils
export POLICY_API_VERSION="$(curl -q --silent https://git.onap.org/policy/api/plain/pom.xml?h=${GERRIT_BRANCH} | xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)"
export POLICY_PAP_VERSION="$(curl -q --silent https://git.onap.org/policy/pap/plain/pom.xml?h=${GERRIT_BRANCH} | xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)"
export POLICY_XACML_PDP_VERSION="$(curl -q --silent https://git.onap.org/policy/xacml-pdp/plain/pom.xml?h=${GERRIT_BRANCH} | xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)"

echo ${POLICY_API_VERSION}
echo ${POLICY_PAP_VERSION}
echo ${POLICY_XACML_PDP_VERSION}
# Adding this waiting container due to race condition between pap and mariadb
docker-compose -f ${WORKSPACE}/scripts/policy/policy-xacml-pdp/docker-compose-pdpx.yml run --rm start_dependencies

#Configure the database
docker exec -it mariadb  chmod +x /docker-entrypoint-initdb.d/db.sh
docker exec -it mariadb  /docker-entrypoint-initdb.d/db.sh

# now bring everything else up
docker-compose -f ${WORKSPACE}/scripts/policy/policy-xacml-pdp/docker-compose-pdpx.yml run --rm start_all

unset http_proxy https_proxy

POLICY_API_IP=`get-instance-ip.sh policy-api`
MARIADB_IP=`get-instance-ip.sh mariadb`
POLICY_PDPX_IP=`get-instance-ip.sh policy-xacml-pdp`
DMAAP_IP=`get-instance-ip.sh dmaap-simulator`
POLICY_PAP_IP=`get-instance-ip.sh policy-pap`


echo PDP IP IS ${POLICY_PDPX_IP}
echo API IP IS ${POLICY_API_IP}
echo PAP IP IS ${POLICY_PAP_IP}
echo MARIADB IP IS ${MARIADB_IP}
echo DMAAP_IP IS ${DMAAP_IP}

ROBOT_VARIABLES="-v POLICY_PDPX_IP:${POLICY_PDPX_IP} -v POLICY_API_IP:${POLICY_API_IP} -v POLICY_PAP_IP:${POLICY_PAP_IP}"

sleep 10s

docker logs policy-xacml-pdp

docker exec -it policy-xacml-pdp bash -c "cat /opt/app/policy/logs/debug.log"

docker exec -it policy-xacml-pdp bash -c "cat /opt/app/policy/pdpx/etc/defaultConfig.json"

cat /opt/app/policy/pdpx/etc/defaultConfig.json
