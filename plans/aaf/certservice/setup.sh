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

AAFCERT_IMAGE=nexus3.onap.org:10001/onap/org.onap.aaf.certservice.aaf-certservice-api:latest

echo AAFCERT_IMAGE=${AAFCERT_IMAGE}

# ------------------------------------
# Resolve path to cmp servers configuration

SCRIPT=`realpath $0`
CURRENT_WORKDIR_PATH=`dirname $SCRIPT`

CONFIGURATION_FILE="cmpServers.json"
if test -f "$CURRENT_WORKDIR_PATH/plans/aaf/certservice/$CONFIGURATION_FILE"; then
    CONFIGURATION_PATH="$CURRENT_WORKDIR_PATH/plans/aaf/certservice/$CONFIGURATION_FILE"
else test -f "$CURRENT_WORKDIR_PATH/$CONFIGURATION_FILE";
    CONFIGURATION_PATH=$CURRENT_WORKDIR_PATH/$CONFIGURATION_FILE
fi
echo "Use configuration from: $CONFIGURATION_PATH"
# -------------------------------------

# Start AAF Cert Srevice
docker run -p 8080:8080 -d --mount type=bind,source=${CONFIGURATION_PATH},target=/etc/onap/aaf/certservice/cmpServers.json --name aafcert ${AAFCERT_IMAGE}

AAFCERT_IP=`get-instance-ip.sh aafcert`
export AAFCERT_IP=${AAFCERT_IP}

# Wait container ready
sleep 5

