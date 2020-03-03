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

SCRIPTS_DIRECTORY="scripts"
if test -d "$CURRENT_WORKDIR_PATH/plans/aaf/certservice/$SCRIPTS_DIRECTORY"; then
    SCRIPTS_PATH="$CURRENT_WORKDIR_PATH/plans/aaf/certservice/$SCRIPTS_DIRECTORY"
else test -f "$CURRENT_WORKDIR_PATH/$SCRIPTS_DIRECTORY";
    SCRIPTS_PATH=$CURRENT_WORKDIR_PATH/$SCRIPTS_DIRECTORY
fi
echo "Use scripts from: $SCRIPTS_PATH"

CONFIGURATION_FILE="cmpServers.json"
if test -f "$CURRENT_WORKDIR_PATH/plans/aaf/certservice/$CONFIGURATION_FILE"; then
    CONFIGURATION_PATH="$CURRENT_WORKDIR_PATH/plans/aaf/certservice/$CONFIGURATION_FILE"
else test -f "$CURRENT_WORKDIR_PATH/$CONFIGURATION_FILE";
    CONFIGURATION_PATH=$CURRENT_WORKDIR_PATH/$CONFIGURATION_FILE
fi
echo "Use configuration from: $CONFIGURATION_PATH"

# -------------------------------------

export CONFIGURATION_PATH=${CONFIGURATION_PATH}
export SCRIPTS_PATH=${SCRIPTS_PATH}

docker-compose up -d

AAFCERT_IP=`get-instance-ip.sh aafcert`
export AAFCERT_IP=${AAFCERT_IP}

# Wait container ready
sleep 10

