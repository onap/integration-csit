#!/bin/bash
#
# Copyright 2017-2020 AT&T Intellectual Property. All rights reserved.
#
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
# Place the scripts in run order:

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
POLICY_DROOLS_VERSION_EXTRACT="$(curl -q --silent https://git.onap.org/policy/drools-applications/plain/pom.xml?h=${GERRIT_BRANCH} | xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)"
export POLICY_DROOLS_VERSION="${POLICY_DROOLS_VERSION_EXTRACT:0:3}-SNAPSHOT-latest"
echo ${POLICY_DROOLS_VERSION}

sudo curl -L https://github.com/docker/compose/releases/download/1.25.4/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "user information: $(id)"
echo "docker and docker-compose versions:"
docker -v && docker-compose -v && docker info

#ls -alh ${WORKSPACE}/scripts/policy/config/drools/env ${WORKSPACE}/scripts/policy/config/drools ${WORKSPACE}/scripts/policy/config/

sudo chown -R 1000:1000 ${WORKSPACE}/scripts/policy/config/drools

ls -alh ${WORKSPACE}/scripts/policy/config/drools/env ${WORKSPACE}/scripts/policy/config/drools ${WORKSPACE}/scripts/policy/config/

export DEBUG=y
docker-compose -f ${WORKSPACE}/scripts/policy/docker-compose-drools.yml up -d
sleep 2m

docker-compose logs
docker logs mariadb
docker logs drools
docker container ls -a

POLICY_DROOLS_IP=`get-instance-ip.sh drools`
MARIADB_IP=`get-instance-ip.sh mariadb`

echo DROOLS IP IS ${POLICY_DROOLS_IP}
echo MARIADB IP IS ${MARIADB_IP}

# Wait for initialization
for i in {1..10}; do
   curl -sS ${MARIADB_IP}:3306 && break
   echo sleep $i
   sleep $i
done

for i in {1..10}; do
   curl -sS ${POLICY_DROOLS_IP}:6969 && break
   echo sleep $i
   sleep $i
done

ROBOT_VARIABLES="-v POLICY_DROOLS_IP:${POLICY_DROOLS_IP}"
