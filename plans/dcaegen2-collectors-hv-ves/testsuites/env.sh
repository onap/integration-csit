#!/usr/bin/env bash
# ============LICENSE_START=======================================================
# csit-dcaegen2-collectors-hv-ves
# ================================================================================
# Copyright (C) 2019 NOKIA
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

# using WORKSPACE variable defined in run-csit.sh
export ROBOT_VARIABLES="--pythonpath ${WORKSPACE}/tests/dcaegen2-collectors-hv-ves/testcases/libraries --noncritical non-critical"

export JAVA_OPTS="-Dio.netty.leakDetection.level=paranoid"
export CONSUL_HOST="consul-server"
export CONFIG_BINDING_SERVICE="config-binding-service"

export DOCKER_REGISTRY="nexus3.onap.org:10001"
export DOCKER_REGISTRY_PREFIX="${DOCKER_REGISTRY}/"
export CONTAINERS_NETWORK="hv-ves-default"
export HV_VES_SERVICE_NAME="hv-ves-collector"
export UNENCRYPTED_HV_VES_SERVICE_NAME="unencrypted-hv-ves-collector"
export KAFKA_IMAGE_FULL_NAME="${DOCKER_REGISTRY_PREFIX}onap/dmaap/kafka111:0.0.6"

export HV_VES_GROUP_ID="org.onap.dcaegen2.collectors.hv-ves"
export HV_VES_HOSTNAME="dcae-hv-ves-collector"
export HV_VES_COLLECTOR_NAMESPACE="onap"
export HV_VES_HEALTHCHECK_CMD="curl --request GET --fail --silent --show-error localhost:6060/health/ready && nc -vz localhost 6061"
export HV_VES_VERSION="1.1-SNAPSHOT"
export HV_VES_IMAGE="hv-collector-main"
export DCAE_APP_SIMULATOR_IMAGE="hv-collector-dcae-app-simulator"
export XNF_SIMULATOR_IMAGE="hv-ves-collector-xnf-simulator"


