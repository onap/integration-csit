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
WORKAROUND_SUCCESSFUL_TEXT="Finished applying workaround"
WORKAROUND_FAILURE_TEXT="Failed to execute workaround"
WORKAROUND_TIME_OUT_TEXT="workaround script timed out"
WORKAROUND_CONTAINER_NAME=$(docker ps -aqf "name=workaround-config" --format "{{.Names}}")
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

if [ -z $WORKAROUND_CONTAINER_NAME ]; then
   echo "$SCRIPT_NAME $(current_timestamp): Unable to find docker container id "
   exit 1
fi

START_TIME_IN_SECONDS=`date +%s`
TIME_OUT_END_TIME_IN_SECONDS=$(($START_TIME_IN_SECONDS+$TIME_OUT_DEFAULT_VALUE_SEC));


echo echo "$SCRIPT_NAME $(current_timestamp): $SCRIPT_NAME script Start Time `date -d @$START_TIME_IN_SECONDS`"
echo echo "$SCRIPT_NAME $(current_timestamp): $SCRIPT_NAME will time out at `date -d @$TIME_OUT_END_TIME_IN_SECONDS`"

while [ `date +%s` -lt "$TIME_OUT_END_TIME_IN_SECONDS" ]; do
    echo "$(current_timestamp): Waiting for $WORKAROUND_CONTAINER_NAME to finish ..."

    result=$(docker logs $WORKAROUND_CONTAINER_NAME 2>&1 | grep -E "$WORKAROUND_SUCCESSFUL_TEXT|$WORKAROUND_FAILURE_TEXT|$WORKAROUND_TIME_OUT_TEXT")
    if [ ! -z "$result" ]; then
        echo "$SCRIPT_NAME $(current_timestamp): Found result: $result"
        break;
    fi
    echo "$(current_timestamp): Sleeping for ${SLEEP_TIME} seconds"
    sleep ${SLEEP_TIME}
done

if [ -z "$result" ]; then
   echo "$SCRIPT_NAME $(current_timestamp): ERROR: failed to apply workaround . . . "
   echo "-------------- $WORKAROUND_CONTAINER_NAME logs -------------"
   docker logs $WORKAROUND_CONTAINER_NAME
   echo "------------------------------------------------------------"
   exit 1
fi

if echo "$result" | grep -E "$WORKAROUND_FAILURE_TEXT|$WORKAROUND_TIME_OUT_TEXT"; then
    echo "$SCRIPT_NAME $(current_timestamp): Work around script failed"
    echo "-------------- $WORKAROUND_CONTAINER_NAME logs -------------"
    docker logs $WORKAROUND_CONTAINER_NAME
    echo "------------------------------------------------------------"
    exit 1
fi

echo "$SCRIPT_NAME $(current_timestamp): Successfully applied workaround configuration . . ."
exit 0
