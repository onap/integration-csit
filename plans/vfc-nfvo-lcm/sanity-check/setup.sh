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

source ${SCRIPTS}/common_functions.sh

#start msb
docker run -d -p 8500:8500  --name msb_consul consul:0.9.3
MSB_CONSUL_IP=`get-instance-ip.sh msb_consul`
echo MSB_CONSUL_IP=${MSB_CONSUL_IP}

docker run -d  -p 10081:10081  -e CONSUL_IP=$MSB_CONSUL_IP --name msb_discovery nexus3.onap.org:10001/onap/msb/msb_discovery
MSB_DISCOVERY_IP=`get-instance-ip.sh msb_discovery`
echo DISCOVERY_IP=${MSB_DISCOVERY_IP}

docker run -d -p 80:80 -e CONSUL_IP=$MSB_CONSUL_IP -e SDCLIENT_IP=$MSB_DISCOVERY_IP -e "ROUTE_LABELS=visualRange:1" --name msb_internal_apigateway nexus3.onap.org:10001/onap/msb/msb_apigateway
MSB_IAG_IP=`get-instance-ip.sh msb_internal_apigateway`
echo MSB_IAG_IP=${MSB_IAG_IP}

# Mysql
docker run -d -p 3306:3306 --name vfc-db -v /var/lib/mysql -e MYSQL_USER="vfcnfvolcm" -e MYSQL_PASSWORD="vfcnfvolcm" -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE="vfcnfvolcm" nexus3.onap.org:10001/library/mariadb
VFC_DB_IP=`get-instance-ip.sh vfc-db`
echo VFC_DB_IP=${VFC_DB_IP}

# Redis
docker run -d -p 6379:6379 --name vfc-redis redis
VFC_REDIS_IP=`get-instance-ip.sh vfc-redis`
echo VFC_REDIS_IP=${VFC_REDIS_IP}

# Wait for initialization(8500 Consul, 10081 Service Registration & Discovery, 80 api gateway)
for i in {1..10}; do
    curl -sS -m 1 ${MSB_CONSUL_IP}:8500 && curl -sS -m 1 ${MSB_DISCOVERY_IP}:10081 && curl -sS -m 1 ${MSB_IAG_IP}:80 && break
    echo sleep $i
    sleep $i
done

# Wait for initialization(3306 DB)
for i in {1..3}; do
    curl -sS -m 1 ${VFC_DB_IP}:3306 && break
    echo sleep $i
    sleep $i
done

docker ps -a > ps.txt
cat ps.txt
echo "****************************"
docker logs -f vfc-db > db.txt &
cat db.txt

# Need some time so service info can be synced from discovery to api gateway
echo sleep 60
sleep 60

# start vfc-nslcm
docker run -d --name vfc-nslcm -v /var/lib/mysql -e MSB_ADDR=${MSB_IAG_IP}:80 -e MYSQL_ADDR=${VFC_DB_IP}:3306 -e REDIS_HOST=${VFC_REDIS_IP} -e REG_TO_MSB_WHEN_START=true nexus3.onap.org:10001/onap/vfc/nslcm
NSLCM_IP=`get-instance-ip.sh vfc-nslcm`

# Wait for initialization
for i in {1..10}; do
    curl -sS -m 1 ${NSLCM_IP}:8403 && break
    echo sleep $i
    sleep $i
done

docker logs -f vfc-nslcm > dockerlogs.txt &
cat dockerlogs.txt

docker cp vfc-nslcm:/service/vfc/nfvo/lcm/logs/runtime_lcm.log ./
cat runtime_lcm.log

# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v MSB_IAG_IP:${MSB_IAG_IP} -v NSLCM_IP:${NSLCM_IP} -v SCRIPTS:${SCRIPTS}"
