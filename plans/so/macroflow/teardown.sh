#!/bin/bash
#
# ============LICENSE_START=======================================================
# Copyright 2021 Huawei Technologies Co., Ltd.
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
#  SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================

INTEGRATION_ETSI_TESTING_DIR=$WORKSPACE/plans/so/integration-etsi-testing
INTEGRATION_ETSI_TESTING_CONFIG_DIR=$INTEGRATION_ETSI_TESTING_DIR/config

# Macroflow Path
SCRIPT_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPT_NAME=$(basename $0)
CONFIG_DIR_MACRO=$SCRIPT_HOME/config
ENV_FILE=$CONFIG_DIR_MACRO/env
DOCKER_COMPOSE_FILE_PATH=$SCRIPT_HOME/docker-compose.yml
DOCKER_COMPOSE_LOCAL_OVERRIDE_FILE=$SCRIPT_HOME/docker-compose.local.yml

TEMP_DIR_PATH=$MACRO_HOME/temp
TEST_LAB_DIR_PATH=$TEMP_DIR_PATH/test_lab

echo "Running $SCRIPT_HOME/$SCRIPT_NAME ..."
export $(egrep -v '^#' $ENV_FILE | xargs)
export TEST_LAB_DIR=$TEST_LAB_DIR_PATH
export CONFIG_DIR_PATH=$INTEGRATION_ETSI_TESTING_CONFIG_DIR
export CONFIG_DIR_PATH_MACRO=$CONFIG_DIR_MACRO


if [ "$DOCKER_ENVIRONMENT" == "remote" ]; then
  echo "Tearing down docker containers from remote images ..."
  docker-compose -f $DOCKER_COMPOSE_FILE_PATH -p $PROJECT_NAME down
elif [ "$DOCKER_ENVIRONMENT" == "local" ]; then
  echo "Tearing down docker containers from local images ..."
  docker-compose -f $DOCKER_COMPOSE_FILE_PATH -f $DOCKER_COMPOSE_LOCAL_OVERRIDE_FILE -p $PROJECT_NAME down
else
  echo "Couldn't find valid property for DOCKER_ENVIRONMENT in $ENV_FILE."
  echo "Attempting normal teardown ..."
  docker-compose -f $DOCKER_COMPOSE_FILE_PATH -p $PROJECT_NAME down
fi

echo "Finished executing $SCRIPT_HOME/$SCRIPT_NAME"
