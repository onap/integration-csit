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

WORKFLOW_TABLE_NAME="workflow"
TABLE_EXISTS_QUERY="select count(*) from information_schema.tables WHERE table_schema='$CATALOG_DB' AND table_name='$WORKFLOW_TABLE_NAME';"
SLEEP_TIME=5
FLY_WAY_MIGRATION_QUERY="SELECT COUNT(*) FROM flyway_schema_history WHERE script LIKE '%R__MacroData%' AND installed_on IS NOT NULL;"
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
 sleep 5s
 echo "$SCRIPT_NAME $(current_timestamp): $CATALOG_DB tables available now . . ."
}

apply_workaround()
{
 echo "$SCRIPT_NAME $(current_timestamp): Applying workaround . . ."

 wait_for_database_availability
 wait_container_to_create_table
 echo "$SCRIPT_NAME $(current_timestamp): Will insert data into $CATALOG_DB"
 mysql -h $DB_HOST -uroot -p$MYSQL_ROOT_PASSWORD $CATALOG_DB << EOF
 BEGIN;
  
  insert into $WORKFLOW_TABLE_NAME(artifact_uuid, artifact_name, name, operation_name, version, description, body, resource_target, source) values
  ('4752c287-c5a8-40a6-8fce-077e1d54104b','GenericPnfSoftwareUpgrade','GenericPnfSoftwareUpgrade','GenericPnfSoftwareUpgrade',1.0,'Pnf Workflow to upgrade software',null,'pnf','native');

  insert into $WORKFLOW_TABLE_NAME(artifact_uuid, artifact_name, name, operation_name, version, description, body, resource_target, source) values
  ('02bffbd9-6af0-4f8d-bf9b-d1dfccd28c84','GenericPnfSWUPDownload','GenericPnfSWUPDownload','GenericPnfSWUPDownload',1.0,'Pnf Workflow to download software',null,'pnf','native');

  insert into $WORKFLOW_TABLE_NAME(artifact_uuid, artifact_name, name, operation_name, version, description, body, resource_target, source) values
  ('03fcdjf2-6af0-4f8d-bf9b-s3frzca23c19','ServiceLevelUpgrade','ServiceLevelUpgrade','ServiceLevelUpgrade',1.0,'ServiceLevel Upgrade Workflow to upgrade software',null,'service','native');

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

