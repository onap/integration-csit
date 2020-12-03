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
 LINE_OF_BUSINESS_JSON_FILE=$AAI_SIMULATOR_DATA_DIR/line-of-business.json
 PLATFORM_JSON_FILE=$AAI_SIMULATOR_DATA_DIR/platform.json
 CLOUD_REGION_JSON_FILE=$AAI_SIMULATOR_DATA_DIR/cloud-region.json
 TENANT_JSON_FILE=$AAI_SIMULATOR_DATA_DIR/tenant.json
 ESR_VNFM_JSON_FILE=$AAI_SIMULATOR_DATA_DIR/esr-vnfm.json
 ESR_SYSTEM_INFO_JSON_FILE=$AAI_SIMULATOR_DATA_DIR/esr-system-info.json
 CLOUD_ESR_SYSTEM_INFO_JSON_FILE=$AAI_SIMULATOR_DATA_DIR/cloud-esr-system-info.json
 PNF_JSON_FILE=$AAI_SIMULATOR_DATA_DIR/pnf.json
 PNF2_JSON_FILE=$AAI_SIMULATOR_DATA_DIR/pnf2.json
 SERVICE_INSTANCE_JSON_FILE=$AAI_SIMULATOR_DATA_DIR/service-instance-aai.json
 STATUS_CODE_ACCEPTED="202"

 echo "$SCRIPT_NAME $(current_timestamp): checking health of AAI Simulator"
 response=$(curl -k $BASE_URL/healthcheck)

 if [[ "$response" -ne "healthy" ]] ; then
       echo "$SCRIPT_NAME $(current_timestamp) ERROR: AAI Simulator health check failed. Response: $response"
       exit 1
 fi

 echo "$SCRIPT_NAME $(current_timestamp): AAI Simulator is healthy"

 echo "$SCRIPT_NAME $(current_timestamp): Populating AAI Simulator"

 echo "$SCRIPT_NAME $(current_timestamp): Adding Project"
 status_code=$(curl -k --write-out %{http_code} --silent --output /dev/null -H "$BASIC_AUTHORIZATION_HEADER" -H "$ACCEPT_HEADER" -H "$CONTENT_TYPE_HEADER" $BASE_URL/business/projects/project/PnfSwUCsitProject -X PUT -d @"$PROJECT_JSON_FILE")

 if [[ "$status_code" -ne "$STATUS_CODE_ACCEPTED" ]] ; then
     echo "$SCRIPT_NAME $(current_timestamp) ERROR: Unable to put project data in AAI Simulator. Status code received: $status_code"
     exit 1
 fi

  echo "$SCRIPT_NAME $(current_timestamp): Adding Owning-Entity"
  status_code=$(curl -k --write-out %{http_code} --silent --output /dev/null -H "$BASIC_AUTHORIZATION_HEADER" -H "$ACCEPT_HEADER" -H "$CONTENT_TYPE_HEADER" $BASE_URL/business/owning-entities/owning-entity/f2e1071e-3d47-4a65-94d4-e473ec03326a -X PUT -d @$"$OWNING_ENTITY_JSON_FILE")

  if [[ "$status_code" -ne "$STATUS_CODE_ACCEPTED" ]] ; then
     echo "$SCRIPT_NAME $(current_timestamp) ERROR: Unable to put owning entity data in AAI Simulator. Status code received: $status_code"
     exit 1
 fi

 echo "$SCRIPT_NAME $(current_timestamp): Adding Line Of Business"
 status_code=$(curl -k --write-out %{http_code} --silent --output /dev/null -H "$BASIC_AUTHORIZATION_HEADER" -H "$ACCEPT_HEADER" -H "$CONTENT_TYPE_HEADER" $BASE_URL/business/lines-of-business/line-of-business/PnfSwUCsitLineOfBusiness -X PUT -d @$"$LINE_OF_BUSINESS_JSON_FILE")

 if [[ "$status_code" -ne "$STATUS_CODE_ACCEPTED" ]] ; then
     echo "$SCRIPT_NAME $(current_timestamp) ERROR: Unable to put line of business data in AAI Simulator. Status code received: $status_code"
     exit 1
 fi

 echo "$SCRIPT_NAME $(current_timestamp): Adding Platform"
 status_code=$(curl -k --write-out %{http_code} --silent --output /dev/null -H "$BASIC_AUTHORIZATION_HEADER" -H "$ACCEPT_HEADER" -H "$CONTENT_TYPE_HEADER" $BASE_URL/business/platforms/platform/PnfSwUCsitPlatform -X PUT -d @$"$PLATFORM_JSON_FILE")

 if [[ "$status_code" -ne "$STATUS_CODE_ACCEPTED" ]] ; then
     echo "$SCRIPT_NAME $(current_timestamp) ERROR: Unable to put platform data in AAI Simulator. Status code received: $status_code"
     exit 1
 fi

 echo "$SCRIPT_NAME $(current_timestamp): Adding Cloud Region"
 status_code=$(curl -k --write-out %{http_code} --silent --output /dev/null -H "$BASIC_AUTHORIZATION_HEADER" -H "$ACCEPT_HEADER" -H "$CONTENT_TYPE_HEADER" $BASE_URL/cloud-infrastructure/cloud-regions/cloud-region/CloudOwner/PnfSwUCloudRegion -X PUT -d @$"$CLOUD_REGION_JSON_FILE")

  if [[ "$status_code" -ne "$STATUS_CODE_ACCEPTED" ]] ; then
     echo "$SCRIPT_NAME $(current_timestamp) ERROR: Unable to put Cloud Region data in AAI Simulator. Status code received: $status_code"
     exit 1
 fi

 echo "$SCRIPT_NAME $(current_timestamp): Adding Tenant"
  status_code=$(curl -k --write-out %{http_code} --silent --output /dev/null -H "$BASIC_AUTHORIZATION_HEADER" -H "$ACCEPT_HEADER" -H "$CONTENT_TYPE_HEADER" $BASE_URL/cloud-infrastructure/cloud-regions/cloud-region/CloudOwner/PnfSwUCloudRegion/tenants/tenant/693c7729b2364a26a3ca602e6f66187d -X PUT -d @$"$TENANT_JSON_FILE")

  if [[ "$status_code" -ne "$STATUS_CODE_ACCEPTED" ]] ; then
     echo "$SCRIPT_NAME $(current_timestamp) ERROR: Unable to put Tenant data in AAI Simulator. Status code received: $status_code"
     exit 1
 fi

 echo "$SCRIPT_NAME $(current_timestamp): Adding esr-vnfm"
 status_code=$(curl -k --write-out %{http_code} --silent --output /dev/null -H "$BASIC_AUTHORIZATION_HEADER" -H "$ACCEPT_HEADER" -H "$CONTENT_TYPE_HEADER" $BASE_URL/external-system/esr-vnfm-list/esr-vnfm/c5e99cee-1996-4606-b697-838d51d4e1a3 -X PUT -d @$"$ESR_VNFM_JSON_FILE")

  if [[ "$status_code" -ne "$STATUS_CODE_ACCEPTED" ]] ; then
     echo "$SCRIPT_NAME $(current_timestamp) ERROR: Unable to put esr-vnfm data in AAI Simulator. Status code received: $status_code"
     exit 1
 fi

  echo "$SCRIPT_NAME $(current_timestamp): Adding esr-system-info"
 status_code=$(curl -k --write-out %{http_code} --silent --output /dev/null -H "$BASIC_AUTHORIZATION_HEADER" -H "$ACCEPT_HEADER" -H "$CONTENT_TYPE_HEADER" $BASE_URL/external-system/esr-vnfm-list/esr-vnfm/c5e99cee-1996-4606-b697-838d51d4e1a3/esr-system-info-list/esr-system-info/5c067098-f2e3-40f7-a7ba-155e7c61e916 -X PUT -d @$"$ESR_SYSTEM_INFO_JSON_FILE")

  if [[ "$status_code" -ne "$STATUS_CODE_ACCEPTED" ]] ; then
     echo "$SCRIPT_NAME $(current_timestamp) ERROR: Unable to put esr-system-info data in AAI Simulator. Status code received: $status_code"
     exit 1
 fi

  echo "$SCRIPT_NAME $(current_timestamp): Adding cloud esr-system-info"
 status_code=$(curl -k --write-out %{http_code} --silent --output /dev/null -H "$BASIC_AUTHORIZATION_HEADER" -H "$ACCEPT_HEADER" -H "$CONTENT_TYPE_HEADER" $BASE_URL/cloud-infrastructure/cloud-regions/cloud-region/CloudOwner/PnfSwUCloudRegion/esr-system-info-list/esr-system-info/e6a0b318-9756-4f11-94e8-919312d6c2bd -X PUT -d @$"$CLOUD_ESR_SYSTEM_INFO_JSON_FILE")

  if [[ "$status_code" -ne "$STATUS_CODE_ACCEPTED" ]] ; then
     echo "$SCRIPT_NAME $(current_timestamp) ERROR: Unable to put cloud esr-system-info data in AAI Simulator. Status code received: $status_code"
     exit 1
 fi

  echo "$SCRIPT_NAME $(current_timestamp): Adding PNF"
 status_code=$(curl -k --write-out %{http_code} --silent --output /dev/null -H "$BASIC_AUTHORIZATION_HEADER" -H "$ACCEPT_HEADER" -H "$CONTENT_TYPE_HEADER" $BASE_URL/network/pnfs/pnf/PNFDemo -X PUT -d @$"$PNF_JSON_FILE")

  if [[ "$status_code" -ne "$STATUS_CODE_ACCEPTED" ]] ; then
     echo "$SCRIPT_NAME $(current_timestamp) ERROR: Unable to put PNF data in AAI Simulator. Status code received: $status_code"
     exit 1
 fi

  echo "$SCRIPT_NAME $(current_timestamp): Adding PNF_2.0"
 status_code=$(curl -k --write-out %{http_code} --silent --output /dev/null -H "$BASIC_AUTHORIZATION_HEADER" -H "$ACCEPT_HEADER" -H "$CONTENT_TYPE_HEADER" $BASE_URL/network/pnfs/pnf/PNFDemo1 -X PUT -d @$"$PNF2_JSON_FILE")

  if [[ "$status_code" -ne "$STATUS_CODE_ACCEPTED" ]] ; then
     echo "$SCRIPT_NAME $(current_timestamp) ERROR: Unable to put PNF data in AAI Simulator. Status code received: $status_code"
     exit 1
 fi

  echo "$SCRIPT_NAME $(current_timestamp): Adding ServiceInstance"
 status_code=$(curl -k --write-out %{http_code} --silent --output /dev/null -H "$BASIC_AUTHORIZATION_HEADER" -H "$ACCEPT_HEADER" -H "$CONTENT_TYPE_HEADER" $BASE_URL/business/customers/customer/807c7a02-249c-4db8-9fa9-bee973fe08ce/service-subscriptions/service-subscription/pNF/service-instances/service-instance/cd4decf6-4f27-4775-9561-0e683ed43635 -X PUT -d @$"$SERVICE_INSTANCE_JSON_FILE")

  if [[ "$status_code" -ne "$STATUS_CODE_ACCEPTED" ]] ; then
     echo "$SCRIPT_NAME $(current_timestamp) ERROR: Unable to put ServiceInstance data in AAI Simulator. Status code received: $status_code"
     exit 1
 fi

 echo "$SCRIPT_NAME $(current_timestamp): AAI Simulator Populated Successfully"
}

# main body
populate_aai_simulator
