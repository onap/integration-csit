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

if [[ $# -eq 1 ]] && [[ $1 == "local-test-run" ]]; then
  echo "Building locally - assuming all dependencies are installed"
  export DOCKER_REGISTRY=""
  export DOCKER_REGISTRY_PREFIX=""
  export WORKSPACE=$(git rev-parse --show-toplevel)
else
  echo "Default run - install all dependencies"

  pip uninstall -y docker-py
  pip install docker

  COMPOSE_VERSION=1.23.2
  COMPOSE_LOCATION='/usr/local/bin/docker-compose'
  sudo curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m) -o ${COMPOSE_LOCATION}
  sudo chmod +x ${COMPOSE_LOCATION}

  export DOCKER_REGISTRY="nexus3.onap.org:10001"
  export DOCKER_REGISTRY_PREFIX="${DOCKER_REGISTRY}/"
fi

echo "Removing not used docker networks"
docker network prune -f

export CONTAINERS_NETWORK=ves-hv-default
echo "Creating network for containers: ${CONTAINERS_NETWORK}"
docker network create ${CONTAINERS_NETWORK}

cd collector/ssl
./gen-certs.sh
cd ../..

docker-compose up -d

mkdir -p ${WORKSPACE}/archives/containers_logs

export ROBOT_VARIABLES="--pythonpath ${WORKSPACE}/tests/dcaegen2-collectors-hv-ves/testcases/libraries"
