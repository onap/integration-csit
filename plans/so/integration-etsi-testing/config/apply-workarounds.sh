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

# @author Waqas Ikram (waqas.ikram@est.tech)

BUIDLING_BLOCK_TABLE_NAME="building_block_detail"
ORCH_FLOW_TABLE_NAME="orchestration_flow_reference"
NORTH_BOUND_TABLE_NAME="northbound_request_ref_lookup"
TABLE_EXISTS_QUERY="select count(*) from information_schema.tables WHERE table_schema='$CATALOG_DB' AND table_name='$BUIDLING_BLOCK_TABLE_NAME';"
BUILDING_BLOCK_COUNT_QUERY="select count(*) from $BUIDLING_BLOCK_TABLE_NAME;"
FLY_WAY_MIGRATION_QUERY="SELECT COUNT(*) FROM flyway_schema_history WHERE script LIKE '%R__MacroData%' AND installed_on IS NOT NULL;"
SLEEP_TIME=5
TIME_OUT_DEFAULT_VALUE_SEC=1200 #20 mins
SCRIPT_NAME=$(basename $0)

current_timestamp()
{
 date +"%Y-%m-%d %H:%M:%S"
}

wait_for_database_availability()
{
 echo "$SCRIPT_NAME $(current_timestamp): Checking for database availability"
 until echo '\q' | mysql -h $DB_HOST -P $DB_PORT -uroot -p$MYSQL_ROOT_PASSWORD $CATALOG_DB; do
     >&2 echo "$SCRIPT_NAME $(current_timestamp): Database is unavailable - sleeping for ${SLEEP_TIME} seconds"
     isTimeOut
     sleep ${SLEEP_TIME}
 done

 echo "$SCRIPT_NAME $(current_timestamp): Database is available now"
}

wait_container_to_create_table()
{
 while [ $(mysql -h $DB_HOST -P $DB_PORT -uroot -p$MYSQL_ROOT_PASSWORD $CATALOG_DB -sse "$TABLE_EXISTS_QUERY") -eq "0" ] ; do
     echo "$SCRIPT_NAME $(current_timestamp): Waiting for so-catalog container to create tables - sleeping for ${SLEEP_TIME} seconds"
     isTimeOut
     sleep ${SLEEP_TIME}
 done

 while [ $(mysql -h $DB_HOST -P $DB_PORT -uroot -p$MYSQL_ROOT_PASSWORD $CATALOG_DB -sse "$BUILDING_BLOCK_COUNT_QUERY") -eq "0" ] ; do
     echo "$SCRIPT_NAME $(current_timestamp): Waiting for so-catalog container to insert records in $BUIDLING_BLOCK_TABLE_NAME - sleeping for ${SLEEP_TIME} seconds"
     isTimeOut
     sleep ${SLEEP_TIME}
 done

 echo "$SCRIPT_NAME $(current_timestamp): $CATALOG_DB tables available now . . ."
}

wait_for_flyway_migration_to_finish()
{
 while [ $(mysql -h $DB_HOST -P $DB_PORT -uroot -p$MYSQL_ROOT_PASSWORD $CATALOG_DB -sse "$FLY_WAY_MIGRATION_QUERY") -ne "1" ] ; do
     echo "$SCRIPT_NAME $(current_timestamp): Waiting for flyway migration sql statement to finish with success - sleeping for ${SLEEP_TIME} seconds"
     isTimeOut
     sleep ${SLEEP_TIME}
 done
 echo "$SCRIPT_NAME $(current_timestamp): flyway migration finished . . . "
}


apply_workaround()
{
 echo "$SCRIPT_NAME $(current_timestamp): Applying workaround . . ."

 wait_for_database_availability
 wait_container_to_create_table
 wait_for_flyway_migration_to_finish

 echo "$SCRIPT_NAME $(current_timestamp): Will insert data into $CATALOG_DB"
mysql -h $DB_HOST -uroot -p$MYSQL_ROOT_PASSWORD $CATALOG_DB << EOF
  BEGIN;
  
  UPDATE $NORTH_BOUND_TABLE_NAME SET SERVICE_TYPE="*";

  INSERT INTO $BUIDLING_BLOCK_TABLE_NAME (BUILDING_BLOCK_NAME,RESOURCE_TYPE,TARGET_ACTION) values ("EtsiVnfInstantiateBB", "VNF", "ACTIVATE");
  INSERT INTO $BUIDLING_BLOCK_TABLE_NAME (BUILDING_BLOCK_NAME,RESOURCE_TYPE,TARGET_ACTION) values ("EtsiVnfDeleteBB", "VNF", "DEACTIVATE");
 
  DELETE FROM $ORCH_FLOW_TABLE_NAME where COMPOSITE_ACTION = "VNF-Create";

  INSERT INTO $ORCH_FLOW_TABLE_NAME (COMPOSITE_ACTION,SEQ_NO,FLOW_NAME,FLOW_VERSION,NB_REQ_REF_LOOKUP_ID ) SELECT "VNF-Create" AS COMPOSITE_ACTION, 1 AS SEQ_NO, "AssignVnfBB" AS FLOW_NAME, 1 AS FLOW_VERSION,  id AS NB_REQ_REF_LOOKUP_ID FROM $NORTH_BOUND_TABLE_NAME WHERE REQUEST_SCOPE='Vnf' AND IS_ALACARTE is true AND ACTION="createInstance";

  INSERT INTO $ORCH_FLOW_TABLE_NAME (COMPOSITE_ACTION,SEQ_NO,FLOW_NAME,FLOW_VERSION,NB_REQ_REF_LOOKUP_ID ) SELECT "VNF-Create" AS COMPOSITE_ACTION, 2 AS SEQ_NO, "EtsiVnfInstantiateBB" AS FLOW_NAME, 1 AS FLOW_VERSION, id AS NB_REQ_REF_LOOKUP_ID FROM $NORTH_BOUND_TABLE_NAME WHERE REQUEST_SCOPE='Vnf' AND IS_ALACARTE is true AND ACTION="createInstance";

  INSERT INTO $ORCH_FLOW_TABLE_NAME (COMPOSITE_ACTION,SEQ_NO,FLOW_NAME,FLOW_VERSION,NB_REQ_REF_LOOKUP_ID ) SELECT "VNF-Create" AS COMPOSITE_ACTION, 3 AS SEQ_NO, "ActivateVnfBB" AS FLOW_NAME, 1 AS FLOW_VERSION, id AS NB_REQ_REF_LOOKUP_ID FROM $NORTH_BOUND_TABLE_NAME WHERE REQUEST_SCOPE='Vnf' AND IS_ALACARTE is true AND ACTION="createInstance";

 DELETE FROM $ORCH_FLOW_TABLE_NAME where COMPOSITE_ACTION = "VNF-Delete";

 INSERT INTO $ORCH_FLOW_TABLE_NAME (COMPOSITE_ACTION,SEQ_NO,FLOW_NAME,FLOW_VERSION,NB_REQ_REF_LOOKUP_ID ) SELECT "VNF-Delete" AS COMPOSITE_ACTION, 1 AS SEQ_NO, "EtsiVnfDeleteBB" AS FLOW_NAME, 1 AS FLOW_VERSION, id AS NB_REQ_REF_LOOKUP_ID FROM $NORTH_BOUND_TABLE_NAME WHERE REQUEST_SCOPE='Vnf' AND IS_ALACARTE is true AND ACTION="deleteInstance";

 INSERT INTO $ORCH_FLOW_TABLE_NAME (COMPOSITE_ACTION,SEQ_NO,FLOW_NAME,FLOW_VERSION,NB_REQ_REF_LOOKUP_ID ) SELECT "VNF-Delete" AS COMPOSITE_ACTION, 2 AS SEQ_NO, "UnassignVnfBB" AS FLOW_NAME, 1 AS FLOW_VERSION, id AS NB_REQ_REF_LOOKUP_ID FROM $NORTH_BOUND_TABLE_NAME WHERE REQUEST_SCOPE='Vnf' AND IS_ALACARTE is true AND ACTION="deleteInstance";

 UPDATE orchestration_status_state_transition_directive SET FLOW_DIRECTIVE='CONTINUE' WHERE RESOURCE_TYPE='VNF' AND ORCHESTRATION_STATUS='CREATED' AND TARGET_ACTION='ACTIVATE' AND FLOW_DIRECTIVE='FAIL';

 COMMIT;
EOF

 if [ $? -ne 0 ]; then
    echo "$SCRIPT_NAME $(current_timestamp): Failed to execute workaround . . ."
    exit 1
 fi

 echo "$SCRIPT_NAME $(current_timestamp): Finished applying workaround . . ."
}

isTimeOut()
{
 if [ `date +%s` -gt $TIME_OUT_END_TIME_IN_SECONDS ]; then
    echo "$SCRIPT_NAME $(current_timestamp): workaround script timed out . . ."
    exit 1;
 fi
}

# main body
if [ -z "$TIME_OUT_IN_SECONDS"]; then
    echo "$SCRIPT_NAME $(current_timestamp): TIME_OUT_IN_SECONDS attribute is empty will use default val: $TIME_OUT_DEFAULT_VALUE_SEC"
    TIME_OUT_IN_SECONDS=$TIME_OUT_DEFAULT_VALUE_SEC
fi

DIGITS_REGEX='^[0-9]+$'
if ! [[ $TIME_OUT_IN_SECONDS =~ $DIGIT_REGEX ]] ; then
    echo "$SCRIPT_NAME $(current_timestamp): TIME_OUT_IN_SECONDS attribute Must be number: $TIME_OUT_IN_SECONDS, will use default val: $TIME_OUT_DEFAULT_VALUE_SEC"
    TIME_OUT_IN_SECONDS=$TIME_OUT_DEFAULT_VALUE_SEC
fi

START_TIME_IN_SECONDS=`date +%s`
TIME_OUT_END_TIME_IN_SECONDS=$(($START_TIME_IN_SECONDS+$TIME_OUT_IN_SECONDS));
echo "$SCRIPT_NAME $(current_timestamp): Workaround script will time out at `date -d @$TIME_OUT_END_TIME_IN_SECONDS`"

apply_workaround

