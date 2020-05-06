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

SLEEP_TIME=5
SUCCESSFUL_TEXT="AAI Simulator Populated Successfully"
FAILURE_TEXT="ERROR:"
TIME_OUT_TEXT="Time out"
CONTAINER_NAME=$(docker ps -aqf "name=populate-aai-config" --format "{{.Names}}")
SCRIPT_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPT_NAME=$(basename $0)

current_timestamp()
{
 date +"%Y-%m-%d %H:%M:%S"
}

# main body
if [ -z $TIME_OUT_DEFAULT_VALUE_SEC ]; then
    echo "$SCRIPT_NAME $(current_timestamp): ERROR: Undefined value for TIME_OUT_DEFAULT_VALUE_SEC attribute"
    exit 1
fi

if [ -z $CONTAINER_NAME ]; then
   echo "$SCRIPT_NAME $(current_timestamp): Unable to find docker container id "
   exit 1
fi

START_TIME_IN_SECONDS=`date +%s`
TIME_OUT_END_TIME_IN_SECONDS=$(($START_TIME_IN_SECONDS+$TIME_OUT_DEFAULT_VALUE_SEC));


echo echo "$SCRIPT_NAME $(current_timestamp): $SCRIPT_NAME script Start Time `date -d @$START_TIME_IN_SECONDS`"
echo echo "$SCRIPT_NAME $(current_timestamp): $SCRIPT_NAME will time out at `date -d @$TIME_OUT_END_TIME_IN_SECONDS`"

while [ `date +%s` -lt "$TIME_OUT_END_TIME_IN_SECONDS" ]; do
    echo "$(current_timestamp): Waiting for $CONTAINER_NAME to finish ..."

    result=$(docker logs $CONTAINER_NAME 2>&1 | grep -E "$SUCCESSFUL_TEXT|$FAILURE_TEXT|$TIME_OUT_TEXT")
    if [ ! -z "$result" ]; then
        echo "$SCRIPT_NAME $(current_timestamp): Found result: $result"
        break;
    fi
    echo "$(current_timestamp): Sleeping for ${SLEEP_TIME} seconds"
    sleep ${SLEEP_TIME}
done

if [ -z "$result" ]; then
   echo "$SCRIPT_NAME $(current_timestamp): ERROR: failed to populate AAI Simulator . . . "
   echo "-------------- $CONTAINER_NAME logs -------------"
   docker logs $CONTAINER_NAME
   echo "------------------------------------------------------------"
   exit 1
fi

if echo "$result" | grep -E "$FAILURE_TEXT|$TIME_OUT_TEXT"; then
    echo "$SCRIPT_NAME $(current_timestamp): populate-aai-simulator.sh failed"
    echo "-------------- $CONTAINER_NAME logs -------------"
    docker logs $CONTAINER_NAME
    echo "------------------------------------------------------------"
    exit 1
fi

echo "$SCRIPT_NAME $(current_timestamp): Successfully populated AAI Simulator . . ."
exit 0
