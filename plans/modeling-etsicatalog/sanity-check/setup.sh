#!/bin/bash
#
# Copyright 2017 ZTE Corporation.
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

#login to the onap nexus docker repo
docker login -u docker -p docker nexus3.onap.org:10001

# start msb
docker run -d -p 8500:8500 --name msb_consul consul:0.9.3
CONSUL_IP=`get-instance-ip.sh msb_consul`
echo CONSUL_IP=${CONSUL_IP}

docker run -d -p 10081:10081 -e CONSUL_IP=$CONSUL_IP --name msb_discovery nexus3.onap.org:10001/onap/msb/msb_discovery
DISCOVERY_IP=`get-instance-ip.sh msb_discovery`
echo DISCOVERY_IP=${DISCOVERY_IP}

docker run -d -p 80:80 -e CONSUL_IP=$CONSUL_IP -e SDCLIENT_IP=$DISCOVERY_IP -e "ROUTE_LABELS=visualRange:1" --name msb_internal_apigateway nexus3.onap.org:10001/onap/msb/msb_apigateway
MSB_IP==`get-instance-ip.sh msb_internal_apigateway`
echo MSB_IP=${MSB_IP}

docker run -d -p 3306:3306 --name vfc-db -v /var/lib/mysql -e MYSQL_USER="etsicatalog" -e MYSQL_PASSWORD="etsicatalog" -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE="etsicatalog" nexus3.onap.org:10001/library/mariadb
DB_IP=`get-instance-ip.sh vfc-db`
echo DB_IP=${DB_IP}

# Wait for initialization(8500 Consul, 10081 Service Registration & Discovery, 80 api gateway)
for i in {1..10}; do
    curl -sS -m 1 ${CONSUL_IP}:8500 && curl -sS -m 1 ${DISCOVERY_IP}:10081 && curl -sS -m 1 ${MSB_IP}:80 && break
    echo sleep $i
    sleep $i
done

# Wait for initialization(3306 DB)
for i in {1..3}; do
    curl -sS -m 1 ${DB_IP}:3306 && break
    echo sleep $i
    sleep $i
done

# Need some time so service info can be synced from discovery to api gateway
echo sleep 60
sleep 60

# start modeling-etsicatalog
docker run -d --name modeling-etsicatalog -v /var/lib/mysql -e MSB_ADDR=${DISCOVERY_IP}:10081 -e DB_IP=${DB_IP} nexus3.onap.org:10001/onap/modeling/etsicatalog
EtsiCatalog_IP=`get-instance-ip.sh modeling-etsicatalog`
for i in {1..10}; do
    curl -sS -m 1 ${EtsiCatalog_IP}:8806 && break
    echo sleep $i
    sleep $i
done
docker logs modeling-etsicatalog

# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v MSB_IP:${MSB_IP} -v EtsiCatalog_IP:${EtsiCatalog_IP} -v MSB_DISCOVERY_IP:${DISCOVERY_IP}"
