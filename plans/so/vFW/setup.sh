#!/bin/bash
#
# Copyright 2016-2017 Huawei Technologies Co., Ltd.
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
# Start all process required for executing test case

#start mariadb
docker run -d --name mariadb -h mariadb.so.testlab.onap.org -e MYSQL_ROOT_PASSWORD=password -p 3306:3306 -v ${WORKSPACE}/scripts/so/volumes/mariadb/docker-entrypoint-initdb.d:/docker-entrypoint-initdb.d -v ${WORKSPACE}/scripts/so/volumes/mariadb/conf.d:/etc/mysql/conf.d mariadb:10.1.11
	
#start catalog-db container
docker run -d --name catalog-db-adapter -h catalog-db-adapter.so.testlab.onap.org -e APP=catalog-db-adapter -e JVM_ARGS='-Xms64m -Xmx512m' -e DB_HOST=mariadb --link=mariadb:mariadb.so.testlab.onap.org -p 8082:8082 -v ${WORKSPACE}/scripts/so/volumes/so/ca-certificates/onapheat:/app/ca-certificates -v ${WORKSPACE}/scripts/so/volumes/so/config/catalog-db-adapter/onapheat:/app/config nexus3.onap.org:10001/onap/so/catalog-db-adapter:1.3.0-STAGING-latest /app/wait-for.sh -q -t "600" mariadb:3306 -- "/app/start-app.sh"

#start request-db container
docker run -d --name request-db-adapter -h request-db-adapter.so.testlab.onap.org -e APP=request-db-adapter -e JVM_ARGS='-Xms64m -Xmx512m' -e DB_HOST=mariadb --link=mariadb:mariadb.so.testlab.onap.org --link=catalog-db-adapter:catalog-db-adapter.so.testlab.onap.org -p 8083:8083 -v ${WORKSPACE}/scripts/so/volumes/so/ca-certificates/onapheat:/app/ca-certificates -v ${WORKSPACE}/scripts/so/volumes/so/config/request-db-adapter/onapheat:/app/config nexus3.onap.org:10001/onap/so/request-db-adapter:1.3.0-STAGING-latest /app/wait-for.sh -q -t "600" catalog-db-adapter:8082 -- "/app/start-app.sh"

#start sdnc-adapter container
docker run -d --name sdnc-adapter -h sdnc-adapter.so.testlab.onap.org -e APP=sdnc-adapter -e JVM_ARGS='-Xms64m -Xmx512m' -e DB_HOST=mariadb --link=mariadb:mariadb.so.testlab.onap.org --link=catalog-db-adapter:catalog-db-adapter.so.testlab.onap.org --link=request-db-adapter:request-db-adapter.so.testlab.onap.org -p 8086:8086 -v ${WORKSPACE}/scripts/so/volumes/so/ca-certificates/onapheat:/app/ca-certificates -v ${WORKSPACE}/scripts/so/volumes/so/config/sdnc-adapter/onapheat:/app/config nexus3.onap.org:10001/onap/so/sdnc-adapter:1.3.0-STAGING-latest /app/wait-for.sh -q -t "600" request-db-adapter:8083 -- "/app/start-app.sh"

#start openstack-adapter container
docker run -d --name openstack-adapter -h openstack-adapter.so.testlab.onap.org -e APP=openstack-adapter -e JVM_ARGS='-Xms64m -Xmx512m' -e DB_HOST=mariadb --link=mariadb:mariadb.so.testlab.onap.org --link=catalog-db-adapter:catalog-db-adapter.so.testlab.onap.org --link=request-db-adapter:request-db-adapter.so.testlab.onap.org -p 8087:8087 -v ${WORKSPACE}/scripts/so/volumes/so/ca-certificates/onapheat:/app/ca-certificates -v ${WORKSPACE}/scripts/so/volumes/so/config/openstack-adapter/onapheat:/app/config nexus3.onap.org:10001/onap/so/openstack-adapter:1.3.0-STAGING-latest /app/wait-for.sh -q -t "600" request-db-adapter:8083 -- "/app/start-app.sh"

#start vfc-adapter container
docker run -d --name vfc-adapter -h vfc-adapter.so.testlab.onap.org -e APP=vfc-adapter -e JVM_ARGS='-Xms64m -Xmx512m' -e DB_HOST=mariadb --link=mariadb:mariadb.so.testlab.onap.org --link=catalog-db-adapter:catalog-db-adapter.so.testlab.onap.org --link=request-db-adapter:request-db-adapter.so.testlab.onap.org -p 8084:8084 -v ${WORKSPACE}/scripts/so/volumes/so/ca-certificates/onapheat:/app/ca-certificates -v ${WORKSPACE}/scripts/so/volumes/so/config/vfc-adapter/onapheat:/app/config nexus3.onap.org:10001/onap/so/vfc-adapter:1.3.0-STAGING-latest /app/wait-for.sh -q -t "600" request-db-adapter:8083 -- "/app/start-app.sh"

#start sdc-controller container
docker run -d --name sdc-controller -h sdc-controller.so.testlab.onap.org -e APP=sdc-controller -e JVM_ARGS='-Xms64m -Xmx512m' -e DB_HOST=mariadb --link=mariadb:mariadb.so.testlab.onap.org --link=catalog-db-adapter:catalog-db-adapter.so.testlab.onap.org --link=request-db-adapter:request-db-adapter.so.testlab.onap.org -p 8085:8085 -v ${WORKSPACE}/scripts/so/volumes/so/ca-certificates/onapheat:/app/ca-certificates -v ${WORKSPACE}/scripts/so/volumes/so/config/sdc-controller/onapheat:/app/config nexus3.onap.org:10001/onap/so/sdc-controller:1.3.0-STAGING-latest /app/wait-for.sh -q -t "600" request-db-adapter:8083 -- "/app/start-app.sh"

#start bpmn-infra container
docker run -d --name bpmn-infra -h bpmn-infra.so.testlab.onap.org -e APP=bpmn-infra -e JVM_ARGS='-Xms64m -Xmx512m' -e DB_HOST=mariadb --link=mariadb:mariadb.so.testlab.onap.org --link=catalog-db-adapter:catalog-db-adapter.so.testlab.onap.org --link=request-db-adapter:request-db-adapter.so.testlab.onap.org -p 8081:8081 -v ${WORKSPACE}/scripts/so/volumes/so/ca-certificates/onapheat:/app/ca-certificates -v ${WORKSPACE}/scripts/so/volumes/so/config/bpmn-infra/onapheat:/app/config nexus3.onap.org:10001/onap/so/bpmn-infra:1.3.0-STAGING-latest /app/wait-for.sh -q -t "600" request-db-adapter:8083 -- "/app/start-app.sh"

#start api-handler-infra container
docker run -d --name api-handler-infra -h api-handler-infra.so.testlab.onap.org -e APP=api-handler-infra -e JVM_ARGS='-Xms64m -Xmx512m' -e DB_HOST=mariadb --link=mariadb:mariadb.so.testlab.onap.org --link=catalog-db-adapter:catalog-db-adapter.so.testlab.onap.org --link=request-db-adapter:request-db-adapter.so.testlab.onap.org --link=bpmn-infra:bpmn-infra.so.testlab.onap.org -p 8080:8080 -v ${WORKSPACE}/scripts/so/volumes/so/ca-certificates/onapheat:/app/ca-certificates -v ${WORKSPACE}/scripts/so/volumes/so/config/api-handler-infra/onapheat:/app/config nexus3.onap.org:10001/onap/so/api-handler-infra:1.3.0-STAGING-latest /app/wait-for.sh -q -t "600" request-db-adapter:8083 -- "/app/start-app.sh"

#start so-monitoring container
docker run -d --name so-monitoring -h so-monitoring.so.testlab.onap.org -e APP=so-monitoring -e JVM_ARGS='-Xms64m -Xmx512m' -e DB_HOST=mariadb --link=mariadb:mariadb.so.testlab.onap.org --link=catalog-db-adapter:catalog-db-adapter.so.testlab.onap.org --link=request-db-adapter:request-db-adapter.so.testlab.onap.org -p 8088:8088 -v ${WORKSPACE}/scripts/so/volumes/so/ca-certificates/onapheat:/app/ca-certificates -v ${WORKSPACE}/scripts/so/volumes/so/config/so-monitoring/onapheat:/app/config nexus3.onap.org:10001/onap/so/so-monitoring:1.3.0-STAGING-latest /app/wait-for.sh -q -t "600" request-db-adapter:8083 -- "/app/start-app.sh"

# Wait for initialization
sleep 600

#REPO_IP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' so`
REPO_IP='127.0.0.1'
# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v REPO_IP:${REPO_IP}"
