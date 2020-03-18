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

# ------------------------------------
#Prepare enviroment for client
#install docker sdk
echo "Uninstall docker-py and reinstall docker."
pip uninstall -y docker-py
pip uninstall -y docker
pip install -U docker==2.7.0

#Disable proxy - for local run
unset http_proxy https_proxy

#export container name
export ClientContainerName=CertServiceClient
# ------------------------------------

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
   AAFCERT_IP=`get-instance-ip.sh aafcert`
   RESP_CODE=$(curl -I -s -o /dev/null -w "%{http_code}"  http://${AAFCERT_IP}:8080/actuator/health)
   if [[ "$RESP_CODE" == '200' ]]; then
       echo 'AAF Cert Service is ready'
       export AAFCERT_IP=${AAFCERT_IP}
       docker exec aafcert-ejbca /opt/primekey/scripts/ejbca-configuration.sh
       break
   fi
   echo 'Waiting for AAF Cert Service to start up...'
   sleep 30s
done

if [ "$AAFCERT_IP" == 'none' -o "$AAFCERT_IP" == '' ]; then
    echo "AAF Cert Service is not ready!"
    exit 1 # Return error code
fi
