#!/bin/bash

SCRIPT_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOCKER_COMPOSE_FILE_PATH=$SCRIPT_HOME/docker-compose.yml

echo "Tearing down docker containers from remote images ..."
docker-compose -f $DOCKER_COMPOSE_FILE_PATH -p $PROJECT_NAME down
