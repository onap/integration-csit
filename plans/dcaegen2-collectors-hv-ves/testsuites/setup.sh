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

set -euo pipefail

RUN_CSIT_LOCAL=${RUN_CSIT_LOCAL:-false}

echo "Replacing obsolete 'docker-py' with 'docker' package"
pip uninstall -y docker-py
pip install docker

if ${RUN_CSIT_LOCAL} ; then
  echo "Local run"
  source env_local.sh
else
  echo "Default (CI) run"
  COMPOSE_VERSION=1.23.2
  COMPOSE_LOCATION='/usr/local/bin/docker-compose'
  sudo curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m) -o ${COMPOSE_LOCATION}
  sudo chmod +x ${COMPOSE_LOCATION}
  source env.sh
fi

echo "Removing not used docker networks"
docker network prune -f

echo "Creating network for containers: ${CONTAINERS_NETWORK}"
docker network create ${CONTAINERS_NETWORK}

cd collector/ssl
./gen-certs.sh
cd ../..

docker-compose up -d
docker images --digests

mkdir -p ${WORKSPACE}/archives/containers_logs
