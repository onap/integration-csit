#!/bin/bash
#
# Copyright 2020 Nokia.
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

# ------------------------------------
# Resolve path to script's directory and cmp servers configuration

SCRIPT=`realpath $0`
CURRENT_WORKDIR_PATH=`dirname $SCRIPT`
PROJECT_DIRECTORY="plans/aaf/certservice"

SCRIPTS_DIRECTORY="scripts"

JENKINS_SCRIPTS_PATH="$CURRENT_WORKDIR_PATH/$PROJECT_DIRECTORY/$SCRIPTS_DIRECTORY"
LOCAL_SCRIPTS_PATH="$CURRENT_WORKDIR_PATH/$SCRIPTS_DIRECTORY"

if test -d "$JENKINS_SCRIPTS_PATH"; then
    SCRIPTS_PATH=$JENKINS_SCRIPTS_PATH
else test -f "$LOCAL_SCRIPTS_PATH";
    SCRIPTS_PATH=$LOCAL_SCRIPTS_PATH
fi
echo "Use scripts from: $SCRIPTS_PATH"

CONFIGURATION_FILE="cmpServers.json"

JENKINS_CONFIGURATION_PATH="$CURRENT_WORKDIR_PATH/$PROJECT_DIRECTORY/$CONFIGURATION_FILE"
LOCAL_CONFIGURATION_PATH="$CURRENT_WORKDIR_PATH/$CONFIGURATION_FILE"

if test -f "$JENKINS_CONFIGURATION_PATH"; then
    CONFIGURATION_PATH="$JENKINS_CONFIGURATION_PATH"
else test -f "$LOCAL_CONFIGURATION_PATH";
    CONFIGURATION_PATH=$LOCAL_CONFIGURATION_PATH
fi
echo "Use configuration from: $CONFIGURATION_PATH"

# -------------------------------------

export CONFIGURATION_PATH=${CONFIGURATION_PATH}
export SCRIPTS_PATH=${SCRIPTS_PATH}

docker-compose up -d

AAFCERT_IP='none'
# Wait container ready
for i in {1..9}
do
   RESP_CODE=$(curl -I -s -o /dev/null -w "%{http_code}"  http://${AAFCERT_IP}:8080/actuator/health)
   if [[ "$RESP_CODE" == '200' ]]; then
       echo 'AAF Cert Service is ready'
       AAFCERT_IP=`get-instance-ip.sh aafcert`
       export AAFCERT_IP=${AAFCERT_IP}
       break
   fi
   echo 'Waiting for AAF Cert Service to start up...'
   sleep 60s
done

if [[ $AAFCERT_IP == 'none' ]]; then
    echo "AAF Cert Service is not ready!"
    exit 1 # Return error code
fi
