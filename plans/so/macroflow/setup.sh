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

MAVEN_VERSION_DIR="apache-maven-3.3.9"
MAVEN_TAR_FILE="$MAVEN_VERSION_DIR-bin.tar.gz"
MAVEN_TAR_LOCATION="https://archive.apache.org/dist/maven/maven-3/3.3.9/binaries/$MAVEN_TAR_FILE"

# Macroflow
SCRIPT_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPT_NAME=$(basename $0)
CONFIG_DIR_MACRO=$SCRIPT_HOME/config
ENV_FILE=$CONFIG_DIR_MACRO/env
SQL_PATH=$SCRIPT_HOME/cloud_owner_sql
DOCKER_COMPOSE_FILE_PATH=$SCRIPT_HOME/docker-compose.yml
DOCKER_COMPOSE_LOCAL_OVERRIDE_FILE=$SCRIPT_HOME/docker-compose.local.yml
TEAR_DOWN_SCRIPT=$SCRIPT_HOME/teardown.sh
TEMP_DIR_PATH=$SCRIPT_HOME/temp
TEST_LAB_DIR_PATH=$TEMP_DIR_PATH/test_lab

#CAMUNDA SQL SCRIPTS
TEST_LAB_SQL_SCRIPTS_DIR=$TEST_LAB_DIR_PATH/volumes/mariadb/docker-entrypoint-initdb.d/db-sql-scripts
CAMUNDA_SQL_SCRIPT_NAME=mariadb_engine_7.10.0.sql

# INTEGRATION_ETSI
INTEGRATION_ETSI_TESTING_DIR=$WORKSPACE/plans/so/integration-etsi-testing
INTEGRATION_ETSI_TESTING_CONFIG_DIR=$INTEGRATION_ETSI_TESTING_DIR/config

MAVEN_DIR=$TEMP_DIR_PATH/maven
INSTALLED_MAVEN_DIR=$MAVEN_DIR/$MAVEN_VERSION_DIR
MVN=$INSTALLED_MAVEN_DIR/bin/mvn
MVN_VERSION="$MVN -v"
MVN_SETTINGS_XML="$INTEGRATION_ETSI_TESTING_DIR/settings.xml"
MVN_CLEAN_INSTALL="$MVN clean install"
SIMULATOR_MAVEN_PROJECT_POM="$INTEGRATION_ETSI_TESTING_DIR/so-simulators/pom.xml"
WAIT_FOR_WORKAROUND_SCRIPT=$INTEGRATION_ETSI_TESTING_CONFIG_DIR/"wait-for-workaround-job.sh"
WAIT_FOR_POPULATE_AAI_SCRIPT=$INTEGRATION_ETSI_TESTING_CONFIG_DIR/"wait-for-aai-config-job.sh"
WAIT_FOR_CONTAINER_SCRIPT=$INTEGRATION_ETSI_TESTING_CONFIG_DIR/"wait-for-container.sh"

echo "Running $SCRIPT_HOME/$SCRIPT_NAME ..."

export $(egrep -v '^#' $ENV_FILE | xargs)

MANDATORY_VARIABLES_NAMES=( "NEXUS_DOCKER_REPO_MSO" "DOCKER_ENVIRONMENT" "TAG" "TIME_OUT_DEFAULT_VALUE_SEC" "PROJECT_NAME" "DEFAULT_NETWORK_NAME")

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

echo "Will clone docker-config project ... "


if [[ -d "$TEST_LAB_DIR_PATH" ]]; then
       echo "$TEST_LAB_DIR_PATH already exists"
       echo "Removing $TEST_LAB_DIR_PATH directory ..."
       rm -rf $TEST_LAB_DIR_PATH
fi

git clone http://gerrit.onap.org/r/so/docker-config.git $TEST_LAB_DIR_PATH

echo "Replacing $CAMUNDA_SQL_SCRIPT_NAME ..."
rm -rf $TEST_LAB_SQL_SCRIPTS_DIR/$CAMUNDA_SQL_SCRIPT_NAME
cp $CONFIG_DIR_MACRO/$CAMUNDA_SQL_SCRIPT_NAME $TEST_LAB_SQL_SCRIPTS_DIR

export TEST_LAB_DIR=$TEST_LAB_DIR_PATH
export CONFIG_DIR_PATH=$INTEGRATION_ETSI_TESTING_CONFIG_DIR
export CONFIG_DIR_PATH_MACRO=$CONFIG_DIR_MACRO

if [ "$DOCKER_ENVIRONMENT" == "remote" ]; then
  echo "Starting docker containers with remote images ..."
  docker-compose -f $DOCKER_COMPOSE_FILE_PATH -p $PROJECT_NAME up -d
elif [ "$DOCKER_ENVIRONMENT" == "local" ]; then
  echo "Starting docker containers with local images ..."
  docker-compose -f $DOCKER_COMPOSE_FILE_PATH -f $DOCKER_COMPOSE_LOCAL_OVERRIDE_FILE -p $PROJECT_NAME up -d
else
  echo "DOCKER_ENVIRONMENT not set correctly in $ENV_FILE.  Allowed values: local | remote"
  exit 1
fi

echo "Sleeping for 3m"
sleep 3m

echo "Will execute $WAIT_FOR_WORKAROUND_SCRIPT script"
$WAIT_FOR_WORKAROUND_SCRIPT

if [ $? -ne 0 ]; then
   echo "ERROR: $WAIT_FOR_WORKAROUND_SCRIPT failed"
   echo "Will stop running docker containers . . ."
   $TEAR_DOWN_SCRIPT
   exit 1
fi

echo "Will execute $WAIT_FOR_POPULATE_AAI_SCRIPT script"
$WAIT_FOR_POPULATE_AAI_SCRIPT

if [ $? -ne 0 ]; then
   echo "ERROR: $WAIT_FOR_POPULATE_AAI_SCRIPT failed"
   echo "Will stop running docker containers . . ."
   $TEAR_DOWN_SCRIPT
   exit 1
fi

PODS_NAMES=( "api-handler-infra" "bpmn-infra")

for pod in "${PODS_NAMES[@]}"
 do
     echo "Will execute $WAIT_FOR_CONTAINER_SCRIPT to wait for $pod container to start up"
     $WAIT_FOR_CONTAINER_SCRIPT -c "$pod" -t "300" -n "$DEFAULT_NETWORK_NAME"

     if [ $? -ne 0 ]; then
        echo "ERROR: $WAIT_FOR_CONTAINER_SCRIPT for pod: $pod failed"
        echo "Will stop running docker containers . . ."
        $TEAR_DOWN_SCRIPT
        exit 1
     fi
done

REPO_IP='127.0.0.1'
ROBOT_VARIABLES="-v REPO_IP:${REPO_IP}"

echo "Finished executing $SCRIPT_HOME/$SCRIPT_NAME"
