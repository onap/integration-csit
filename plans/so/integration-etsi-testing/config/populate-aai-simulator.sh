#!/bin/bash
#
# ============LICENSE_START=======================================================
#  Copyright (C) 2019 Nordix Foundation.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================
#

# @author Gareth Roper (gareth.roper@est.tech)
# @auther Waqas Ikram (waqas.ikram@est.tech)

SCRIPT_NAME=$(basename $0)
SCRIPT_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WAIT_FOR_SCRIPT=$SCRIPT_HOME/wait-for.sh

current_timestamp()
{
 date +"%Y-%m-%d %H:%M:%S"
}

populate_aai_simulator()
{
 $WAIT_FOR_SCRIPT -t "$TIMEOUT_IN_SECONDS" -h "$AAI_SIMULATOR_HOST" -p "$AAI_SIMULATOR_PORT"

 if [ $?  -eq 0 ]
 then
     echo "$SCRIPT_NAME $(current_timestamp): AAI Simulator is Running."
 else
     echo "$SCRIPT_NAME $(current_timestamp): AAI Simulator could not be found. Exiting..."
     exit 1
 fi

 BASE_URL="https://$AAI_SIMULATOR_HOST:$AAI_SIMULATOR_PORT/aai/v15"
 BASIC_AUTHORIZATION_HEADER="Authorization: Basic YWFpOmFhaS5vbmFwLm9yZzpkZW1vMTIzNDU2IQ=="
 APPICATION_JSON="application/json"
 ACCEPT_HEADER="Accept: $APPICATION_JSON"
 CONTENT_TYPE_HEADER="Content-Type: $APPICATION_JSON"
 CURL_COMMAND="curl -k -H $BASIC_AUTHORIZATION_HEADER -H $ACCEPT_HEADER -H $CONTENT_TYPE_HEADER"

 AAI_SIMULATOR_DATA_DIR=$SCRIPT_HOME/aai-simulator-populate-data
 CUSTOMER_JSON_FILE=$AAI_SIMULATOR_DATA_DIR/customer.json
 PROJECT_JSON_FILE=$AAI_SIMULATOR_DATA_DIR/project.json
 OWNING_ENTITY_JSON_FILE=$AAI_SIMULATOR_DATA_DIR/owning-entity.json
 STATUS_CODE_ACCEPTED="202"

 echo "$SCRIPT_NAME $(current_timestamp): checking health of AAI Simulator"
 response=$(curl -k $BASE_URL/healthcheck)

 if [[ "$response" -ne "healthy" ]] ; then
       echo "$SCRIPT_NAME $(current_timestamp) ERROR: AAI Simulator health check failed. Response: $response"
       exit 1
 fi

 echo "$SCRIPT_NAME $(current_timestamp): AAI Simulator is healthy"

 echo "$SCRIPT_NAME $(current_timestamp): Populating AAI Simulator"

 echo "$SCRIPT_NAME $(current_timestamp): Adding Cloud-Customer Data"
 status_code=$(curl -k --write-out %{http_code} --silent --output /dev/null -H "$BASIC_AUTHORIZATION_HEADER" -H "$ACCEPT_HEADER" -H "$CONTENT_TYPE_HEADER" $BASE_URL/business/customers/customer/DemoCustomer -X PUT -d @"$CUSTOMER_JSON_FILE")

 if [[ "$status_code" -ne "$STATUS_CODE_ACCEPTED" ]] ; then
     echo "$SCRIPT_NAME $(current_timestamp) ERROR: Unable to put customer data in AAI Simulator. Status code received: $status_code"
     exit 1
 fi

 echo "$SCRIPT_NAME $(current_timestamp): Adding Project"
 status_code=$(curl -k --write-out %{http_code} --silent --output /dev/null -H "$BASIC_AUTHORIZATION_HEADER" -H "$ACCEPT_HEADER" -H "$CONTENT_TYPE_HEADER" $BASE_URL/business/projects/project/etsiCsitProject -X PUT -d @"$PROJECT_JSON_FILE")

 if [[ "$status_code" -ne "$STATUS_CODE_ACCEPTED" ]] ; then
     echo "$SCRIPT_NAME $(current_timestamp) ERROR: Unable to put project data in AAI Simulator. Status code received: $status_code"
     exit 1
 fi

  echo "$SCRIPT_NAME $(current_timestamp): Adding Owning-Entity"
  status_code=$(curl -k --write-out %{http_code} --silent --output /dev/null -H "$BASIC_AUTHORIZATION_HEADER" -H "$ACCEPT_HEADER" -H "$CONTENT_TYPE_HEADER" $BASE_URL/business/owning-entities/owning-entity/oe_1 -X PUT -d @$"$OWNING_ENTITY_JSON_FILE")

  if [[ "$status_code" -ne "$STATUS_CODE_ACCEPTED" ]] ; then
     echo "$SCRIPT_NAME $(current_timestamp) ERROR: Unable to put owning entity data in AAI Simulator. Status code received: $status_code"
     exit 1
 fi

 echo "$SCRIPT_NAME $(current_timestamp): AAI Simulator Populated Successfully"
}

# main body
populate_aai_simulator
