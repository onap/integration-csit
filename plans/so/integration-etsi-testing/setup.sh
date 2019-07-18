#!/bin/bash
#
# ============LICENSE_START=======================================================
#   Copyright (C) 2019 Nordix Foundation.
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
MAVEN_TAR_LOCATION="http://apache.claz.org/maven/maven-3/3.3.9/binaries/$MAVEN_TAR_FILE"

SCRIPT_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPT_NAME=$(basename $0)
CONFIG_DIR=$SCRIPT_HOME/config
ENV_FILE=$CONFIG_DIR/env
TEMP_DIR_PATH=$SCRIPT_HOME/temp
TEST_LAB_DIR_PATH=$TEMP_DIR_PATH/test_lab
DOCKER_COMPOSE_FILE_PATH=$SCRIPT_HOME/docker-compose.yml

MAVEN_DIR=$TEMP_DIR_PATH/maven
INSTALLED_MAVEN_DIR=$MAVEN_DIR/$MAVEN_VERSION_DIR
MVN=$INSTALLED_MAVEN_DIR/bin/mvn
MVN_VERSION="$MVN -v"
MVN_SETTINGS_XML="$SCRIPT_HOME/settings.xml"
MVN_CLEAN_INSTALL="$MVN clean install"
SIMULATOR_MAVEN_PROJECT_POM="$SCRIPT_HOME/so-simulators/pom.xml"

echo "Running $SCRIPT_HOME/$SCRIPT_NAME ..."

export $(egrep -v '^#' $ENV_FILE | xargs)

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

        tar -xzvf apache-maven-3.3.9-bin.tar.gz

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


export TEST_LAB_DIR=$TEST_LAB_DIR_PATH
export CONFIG_DIR_PATH=$CONFIG_DIR

docker-compose -f $DOCKER_COMPOSE_FILE_PATH up -d 

echo "Sleeping for 3m"
sleep 3m

REPO_IP='127.0.0.1'
ROBOT_VARIABLES="-v REPO_IP:${REPO_IP}"

echo "Finished executing $SCRIPT_HOME/$SCRIPT_NAME"
