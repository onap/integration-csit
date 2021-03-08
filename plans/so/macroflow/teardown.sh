#!/bin/bash
#
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
# Place the scripts in run order:
# Start all process required for executing test case

# SCRIPT_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPT_HOME=$WORKSPACE/plans/so/integration-etsi-testing
SCRIPT_NAME=$(basename $0)
CONFIG_DIR=$SCRIPT_HOME/config
ENV_FILE=$CONFIG_DIR/env
TEMP_DIR_PATH=$SCRIPT_HOME/temp
TEST_LAB_DIR_PATH=$TEMP_DIR_PATH/test_lab
DOCKER_COMPOSE_FILE_PATH=$SCRIPT_HOME/docker-compose.yml
DOCKER_COMPOSE_LOCAL_OVERRIDE_FILE=$SCRIPT_HOME/docker-compose.local.yml


echo "Running $SCRIPT_HOME/$SCRIPT_NAME ..."
export $(egrep -v '^#' $ENV_FILE | xargs)
export TEST_LAB_DIR=$TEST_LAB_DIR_PATH
export CONFIG_DIR_PATH=$CONFIG_DIR

echo "Sleeping 2m for completing the macroflow task"
sleep 2m

if [ "$DOCKER_ENVIRONMENT" == "remote" ]; then
  echo "Tearing down docker containers from remote images ..."
  #docker-compose -f $DOCKER_COMPOSE_FILE_PATH -p $PROJECT_NAME down
elif [ "$DOCKER_ENVIRONMENT" == "local" ]; then
  echo "Tearing down docker containers from local images ..."
  #docker-compose -f $DOCKER_COMPOSE_FILE_PATH -f $DOCKER_COMPOSE_LOCAL_OVERRIDE_FILE -p $PROJECT_NAME down
else
  echo "Couldn't find valid property for DOCKER_ENVIRONMENT in $ENV_FILE."
  echo "Attempting normal teardown ..."
  #docker-compose -f $DOCKER_COMPOSE_FILE_PATH -p $PROJECT_NAME down
fi

echo "Finished executing $SCRIPT_HOME/$SCRIPT_NAME"
