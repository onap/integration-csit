#!/bin/bash

SCRIPT_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
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
