#!/bin/bash
#
# ============LICENSE_START=======================================================
#   Copyright (C) 2021 Nordix Foundation.
# ================================================================================
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
#  SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================

# @author Waqas Ikram (waqas.ikram@est.tech)

MAVEN_VERSION_DIR="apache-maven-3.3.9"
MAVEN_TAR_FILE="$MAVEN_VERSION_DIR-bin.tar.gz"
MAVEN_TAR_LOCATION="https://archive.apache.org/dist/maven/maven-3/3.3.9/binaries/$MAVEN_TAR_FILE"

SCRIPT_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPT_NAME=$(basename $0)
CONFIG_DIR=$SCRIPT_HOME/config
ENV_FILE=$CONFIG_DIR/env
TEMP_DIR_PATH=$SCRIPT_HOME/temp

DOCKER_COMPOSE_FILE_PATH=$SCRIPT_HOME/docker-compose.yml
TEAR_DOWN_SCRIPT=$SCRIPT_HOME/teardown.sh

INTEGRATION_ETSI_TESTING_DIR=$WORKSPACE/plans/so/integration-etsi-testing
INTEGRATION_ETSI_TESTING_CONFIG_DIR=$INTEGRATION_ETSI_TESTING_DIR/config

MAVEN_DIR=$TEMP_DIR_PATH/maven
INSTALLED_MAVEN_DIR=$MAVEN_DIR/$MAVEN_VERSION_DIR
MVN=$INSTALLED_MAVEN_DIR/bin/mvn
MVN_VERSION="$MVN -v"
MVN_SETTINGS_XML="$INTEGRATION_ETSI_TESTING_DIR/settings.xml"
MVN_CLEAN_INSTALL="$MVN clean install"
SIMULATOR_MAVEN_PROJECT_POM="$INTEGRATION_ETSI_TESTING_DIR/so-simulators/pom.xml"
WAIT_FOR_CONTAINER_SCRIPT=$INTEGRATION_ETSI_TESTING_CONFIG_DIR/"wait-for-container.sh"

echo "Running $SCRIPT_HOME/$SCRIPT_NAME ..."

export $(egrep -v '^#' $ENV_FILE | xargs)

MANDATORY_VARIABLES_NAMES=( "PROJECT_NAME" "DEFAULT_NETWORK_NAME" )

for var in "${MANDATORY_VARIABLES_NAMES[@]}"
 do
   if [ -z "${!var}" ]; then
     echo "Missing mandatory attribute $var in $ENV_FILE"
     exit 1
  fi
done

if [[ ! "$TEMP_DIR_PATH" || ! -d "$TEMP_DIR_PATH" ]]; then
        echo "Creating temporary directory $TEMP_DIR_PATH"
        mkdir $TEMP_DIR_PATH

        if [ $? -ne 0 ]; then
                echo "Could not create $TEMP_DIR_PATH"
                exit 1
        fi

fi
echo "Will use ${TEMP_DIR_PATH} directory"

if [[ ! "$MAVEN_DIR" || ! -d "$MAVEN_DIR" ]]; then
        echo "Creating temporary maven directory $MAVEN_DIR"
        mkdir $MAVEN_DIR

        if [ $? -ne 0 ]; then
                echo "Could not create $MAVEN_DIR"
                exit 1
        fi
fi
echo "Will use ${MAVEN_DIR} directory for maven install"

if [[ ! "$INSTALLED_MAVEN_DIR" || ! -d "$INSTALLED_MAVEN_DIR" ]]; then
        echo "Installing maven ..."
        cd $MAVEN_DIR

        CURL=`which curl`
        if [[ ! "$CURL" ]]; then
                echo "curl command is not installed"
                echo "Unable to execute test plan"
                exit 1
        fi
        curl -O $MAVEN_TAR_LOCATION

        TAR=`which tar`
        if [[ ! "$TAR" ]]; then
                echo "tar command is not installed"
                echo "Unable to execute test plan"
                exit 1
        fi

        tar -xzvf $MAVEN_TAR_FILE

        echo "Finished installing maven ..."
fi

echo "Maven installed under directory $INSTALLED_MAVEN_DIR"

$MVN_VERSION

if [ $? -ne 0 ]; then
        echo "Unable to run mvn -v command"
        exit 1
fi

cd $SCRIPT_HOME

echo "Will build simulator project using $MVN_CLEAN_INSTALL -f $SIMULATOR_MAVEN_PROJECT_POM --settings $MVN_SETTINGS_XML"
$MVN_CLEAN_INSTALL -f $SIMULATOR_MAVEN_PROJECT_POM --settings $MVN_SETTINGS_XML

if [ $? -ne 0 ]; then
        echo "Maven build failed"
        exit 1
fi

docker-compose -f $DOCKER_COMPOSE_FILE_PATH -p $PROJECT_NAME up -d

echo "Sleeping for 1m"
sleep 1m

AAI_SIMULATOR_CONTAINER_NAME="aai-simulator"
echo "Will execute $WAIT_FOR_CONTAINER_SCRIPT to wait for $AAI_SIMULATOR_CONTAINER_NAME container to start up"
$WAIT_FOR_CONTAINER_SCRIPT -c "$AAI_SIMULATOR_CONTAINER_NAME" -t "300" -n "$DEFAULT_NETWORK_NAME"
if [ $? -ne 0 ]; then
   echo "ERROR: $WAIT_FOR_CONTAINER_SCRIPT failed"
   echo "Will stop running docker containers . . ."
   $TEAR_DOWN_SCRIPT
   exit 1
fi

REPO_IP='127.0.0.1'
ROBOT_VARIABLES="-v REPO_IP:${REPO_IP}"

echo "Finished executing $SCRIPT_HOME/$SCRIPT_NAME"
