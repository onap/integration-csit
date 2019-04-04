#!/usr/bin/env bash
# ============LICENSE_START=======================================================
# csit-dcaegen2-collectors-hv-ves
# ================================================================================
# Copyright (C) 2018-2019 NOKIA
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
# ============LICENSE_END=========================================================

RUN_CSIT_LOCAL=${RUN_CSIT_LOCAL:-false}

cd collector/ssl
./gen-certs.sh clean
cd ../..

if ${RUN_CSIT_LOCAL} ; then
  echo "Tearing down local setup"
  source env_local.sh
else
  echo "Tearing down"
  source env.sh
fi

set +e

METRICS_FILE=${WORKSPACE}/archives/containers_logs/hv-ves-metrics.dump
docker-compose exec hv-ves-collector curl -qs localhost:6060/monitoring/prometheus > ${METRICS_FILE}

CONTAINER_LOGS=${WORKSPACE}/archives/containers_logs/
COMPOSE_LOGS_FILE=${CONTAINER_LOGS}/docker-compose.log

docker-compose logs hv-ves-collector > ${CONTAINER_LOGS}/hv-ves-collector.log
docker-compose logs unencrypted-hv-ves-collector > ${CONTAINER_LOGS}/unencrypted-hv-ves-collector.log
docker-compose logs dcae-app-simulator > ${CONTAINER_LOGS}/dcae-app-simulator.log
docker-compose logs > ${COMPOSE_LOGS_FILE}
docker-compose down
docker-compose rm -f

echo "Stopping leftover containers"
LEFTOVER_CONTAINERS=$(docker ps -aqf network=${CONTAINERS_NETWORK} | awk '{print $1}')
docker stop ${LEFTOVER_CONTAINERS}
docker rm ${LEFTOVER_CONTAINERS}
docker network rm ${CONTAINERS_NETWORK}

set -e

if grep "LEAK:" ${COMPOSE_LOGS_FILE}; then
    echo "WARNING: Memory leak detected in docker-compose logs."
fi
