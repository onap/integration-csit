#!/bin/bash
#
# ============LICENSE_START=======================================================
#   Copyright (C) 2023 Nordix Foundation.
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

#SO-CNFM
SCRIPT_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPT_NAME=$(basename $0)
CONFIG_DIR_CNFM=$SCRIPT_HOME/config
ENV_FILE=$CONFIG_DIR_CNFM/env
TEMP_DIR_PATH=$SCRIPT_HOME/temp
TEST_LAB_DIR_PATH=$TEMP_DIR_PATH/test_lab
DOCKER_COMPOSE_FILE_PATH=$SCRIPT_HOME/docker-compose.yml
DOCKER_COMPOSE_LOCAL_OVERRIDE_FILE=$SCRIPT_HOME/docker-compose.local.yml
TEAR_DOWN_SCRIPT=$SCRIPT_HOME/teardown.sh
WAIT_FOR_KIND_CLUSTER_CONTAINER_SCRIPT=$CONFIG_DIR_CNFM/"wait-for-kind-cluster-container.sh"
KIND_CLUSTER_KUBE_CONFIG_FILE="$TEMP_DIR_PATH/kind-cluster-kube-config.yaml"

# INTEGRATION_ETSI
INTEGRATION_ETSI_TESTING_DIR="$(realpath "$SCRIPT_HOME"/../integration-etsi-testing)"
INTEGRATION_ETSI_TESTING_CONFIG_DIR=$INTEGRATION_ETSI_TESTING_DIR/config
SIMULATOR_MAVEN_PROJECT_POM="$INTEGRATION_ETSI_TESTING_DIR/so-simulators/pom.xml"
WAIT_FOR_POPULATE_AAI_SCRIPT=$INTEGRATION_ETSI_TESTING_CONFIG_DIR/"wait-for-aai-config-job.sh"
WAIT_FOR_CONTAINER_SCRIPT=$INTEGRATION_ETSI_TESTING_CONFIG_DIR/"wait-for-container.sh"

#CAMUNDA SQL SCRIPTS
CAMUNDA_SQL_SCRIPT_NAME=mariadb_engine_7.10.0.sql
CAMUNDA_SQL_SCRIPT_DIR=$INTEGRATION_ETSI_TESTING_CONFIG_DIR/camunda-sql
TEST_LAB_SQL_SCRIPTS_DIR=$TEST_LAB_DIR_PATH/volumes/mariadb/docker-entrypoint-initdb.d/db-sql-scripts

#MAVEN
MAVEN_VERSION_DIR="apache-maven-3.3.9"
MAVEN_TAR_FILE="$MAVEN_VERSION_DIR-bin.tar.gz"
MAVEN_TAR_LOCATION="https://archive.apache.org/dist/maven/maven-3/3.3.9/binaries/$MAVEN_TAR_FILE"
MAVEN_DIR=$TEMP_DIR_PATH/maven
INSTALLED_MAVEN_DIR=$MAVEN_DIR/$MAVEN_VERSION_DIR
MVN=$INSTALLED_MAVEN_DIR/bin/mvn
MVN_VERSION="$MVN -v"
MVN_SETTINGS_XML="$INTEGRATION_ETSI_TESTING_DIR/settings.xml"
MVN_CLEAN_INSTALL="$MVN clean install"
SKIP_KIND_CLUSTER_FLAG="-Dskip-kind-cluster=false"

echo "Running $SCRIPT_HOME/$SCRIPT_NAME ..."

export $(egrep -v '^#' $ENV_FILE | xargs)

MANDATORY_VARIABLES_NAMES=( "NEXUS_DOCKER_REPO_MSO" "DOCKER_ENVIRONMENT" "TIME_OUT_DEFAULT_VALUE_SEC" "PROJECT_NAME" "DEFAULT_NETWORK_NAME" "SO_IMAGE_VERSION" "SO_ADMIN_COCKPIT_IMAGE_VERSION" "MARIADB_VERSION" "SO_CNFM_AS_LCM")

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

echo "Will build simulator project using $MVN_CLEAN_INSTALL -f $SIMULATOR_MAVEN_PROJECT_POM --settings $MVN_SETTINGS_XML"
$MVN_CLEAN_INSTALL -f $SIMULATOR_MAVEN_PROJECT_POM --settings $MVN_SETTINGS_XML $SKIP_KIND_CLUSTER_FLAG
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
cp $CAMUNDA_SQL_SCRIPT_DIR/$CAMUNDA_SQL_SCRIPT_NAME $TEST_LAB_SQL_SCRIPTS_DIR

export TEST_LAB_DIR=$TEST_LAB_DIR_PATH
export CONFIG_DIR_PATH=$INTEGRATION_ETSI_TESTING_CONFIG_DIR
export CONFIG_DIR_PATH_CNFM=$CONFIG_DIR_CNFM

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

docker ps -a

echo "Will execute $WAIT_FOR_POPULATE_AAI_SCRIPT script"
$WAIT_FOR_POPULATE_AAI_SCRIPT
if [ $? -ne 0 ]; then
   echo "ERROR: $WAIT_FOR_POPULATE_AAI_SCRIPT failed"
   echo "Will stop running docker containers . . ."
   $TEAR_DOWN_SCRIPT
   exit 1
fi

PODS_NAMES=( "api-handler-infra" "so-cnfm-lcm" "kind-cluster")
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

echo "Will execute $WAIT_FOR_KIND_CLUSTER_CONTAINER_SCRIPT script"
$WAIT_FOR_KIND_CLUSTER_CONTAINER_SCRIPT
if [ $? -ne 0 ]; then
   echo "ERROR: $WAIT_FOR_KIND_CLUSTER_CONTAINER_SCRIPT failed"
   echo "Will stop running docker containers . . ."
   $TEAR_DOWN_SCRIPT
   exit 1
fi

if [ -f "$KIND_CLUSTER_KUBE_CONFIG_FILE" ]; then
  echo "Old Kube-config file exits $KIND_CLUSTER_KUBE_CONFIG_FILE will remove it"
  rm "$KIND_CLUSTER_KUBE_CONFIG_FILE"
fi

CONTAINER_NAME=$(docker ps -aqf "name=kind-cluster" --format "{{.Names}}")
if [ -z "$CONTAINER_NAME" ]; then
   echo "Unable to find kind-cluster docker container id CONTAINER_NAME=$CONTAINER_NAME"
   exit 1
fi

echo "Copying kube-config from $CONTAINER_NAME container"
docker cp "$CONTAINER_NAME":/root/.kube/config "$KIND_CLUSTER_KUBE_CONFIG_FILE"

if [ $? -ne 0 ] || [ ! -f "$KIND_CLUSTER_KUBE_CONFIG_FILE" ]; then
   echo "ERROR: Failed to copy kube-config file from $CONTAINER_NAME"
   echo "Will stop running docker containers . . ."
   $TEAR_DOWN_SCRIPT
   exit 1
fi

# Pass variables required in robot test suites in ROBOT_VARIABLES
REPO_IP='127.0.0.1'
ROBOT_VARIABLES="-v REPO_IP:${REPO_IP} -v KIND_CLUSTER_KUBE_CONFIG_FILE:${KIND_CLUSTER_KUBE_CONFIG_FILE}"

echo "Finished executing $SCRIPT_HOME/$SCRIPT_NAME"