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
  source setup_env_local.sh
else
  echo "Tearing down"
  source setup_env.sh
fi

COMPOSE_LOGS_FILE=${WORKSPACE}/archives/containers_logs/docker-compose.log
docker-compose logs > ${COMPOSE_LOGS_FILE}
docker-compose down
docker-compose rm -f

echo "Stopping running xnf simulators"
docker rm -f $(docker ps -a | grep ves-hv-collector-xnf-simulator700\. | awk '{print $1}')
docker network rm ${CONTAINERS_NETWORK}

if grep "LEAK:" ${COMPOSE_LOGS_FILE}; then
    echo "WARNING: Memory leak detected in docker-compose logs."
fi
