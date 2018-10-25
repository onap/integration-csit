#!/bin/bash
#
# ============LICENSE_START=======================================================
# ONAP CLAMP
# ================================================================================
# Copyright (C) 2018 AT&T Intellectual Property. All rights
#                             reserved.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============LICENSE_END============================================
# ===================================================================
# ECOMP is a trademark and service mark of AT&T Intellectual Property.
#

echo "This is ${WORKSPACE}/scripts/opft-cmso/cmso/start_cmso_containers.sh"

# start cmso mariadb and  db-init containers with docker compose and configuration from cmso/cmso-service/extra/docker/cmso-service/docker-compose.yml

docker run -p 3306:3306 --name cmso-mariadb -v $(pwd)/mariadb/conf1:/etc/mysql/conf.d -e MYSQL_ROOT_PASSWORD=beer -d mariadb:10.1.11

CMSO_DB_IP=`get-instance-ip.sh  cmso-mariadb`

${WORKSPACE}/scripts/optf-osdf/osdf/wait_for_port.sh ${CMSO_DB_IP} 3306

sed  -i -e "s%192.168.56.101:3306%${CMSO_DB_IP}:3306%g" ./etc/config/cmso.properties
sed  -i -e "s%192.168.56.101:3306%${CMSO_DB_IP}:3306%g" ./etc/config/liquibase.properties


docker run --name cmso-db-init -v $(pwd)/etc:/share/etc -v $(pwd)/logs:/share/logs -d nexus3.onap.org:10001/onap/optf-cmso-dbinit

sleep 30

docker run --name cmso-service -p 8080:8080 -v $(pwd)/etc:/share/etc -v $(pwd)/logs:/share/logs -v $(pwd)/debug-logs:/share/debug-logs -d nexus3.onap.org:10001/onap/optf-cmso-service

CMSO_SERVICE_IP=`get-instance-ip.sh  cmso-service`

${WORKSPACE}/scripts/optf-osdf/osdf/wait_for_port.sh ${CMSO_SERVICE_IP} 8080


ROBOT_VARIABLES="-v GLOBAL_SCHEDULER_HOST:${CMSO_SERVICE_IP}"

echo ${ROBOT_VARIABLES}