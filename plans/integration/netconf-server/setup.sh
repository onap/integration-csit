#!/bin/bash
#
# Copyright (C) 2021 Nokia. All rights reserved.
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

# Start netconf-server image with dependencies
${WORKSPACE}/scripts/integration/netconf-server/start-netconf-server.sh

# Setup IP for netconf-server
NETCONF_SERVER_NAME=netconf-server
NETCONF_SERVER_REST_PORT=6555
NETCONF_SERVER_IP=`get-instance-ip.sh $NETCONF_SERVER_NAME`

# Wait until container ready
for i in {1..9}
do
   RESP_CODE=$(curl -I -s -o /dev/null -w "%{http_code}"  http://${NETCONF_SERVER_IP}:${NETCONF_SERVER_REST_PORT}/healthcheck)
   if [[ "$RESP_CODE" == '200' ]]; then
       echo 'Netconf Server is ready'
       export NETCONF_SERVER_IP=${NETCONF_SERVER_IP}
       export NETCONF_SERVER_REST_PORT=${NETCONF_SERVER_REST_PORT}
       break
   fi
   echo 'Waiting for Netconf Server to start up...'
   sleep 5s
done
