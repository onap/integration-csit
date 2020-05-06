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

SCRIPT_NAME=$(basename $0)

# Process the arguments passed to the script
usage()
{
 _msg_="$@"
 cat<<-EOF
 Command Arguments:

 -t, --timeout
 Mandatory argument. time out value in seconds (must be number) 

 -h --host
 Mandatory argument. Host name or IP

 -p, --port
 Mandatory argument. Port of the host

 --help
 Optional argument.  Display this usage.

EOF
 exit 1
}

current_timestamp()
{
 date +"%Y-%m-%d %H:%M:%S"
}

# Called when script is executed with invalid arguments
invalid_arguments()
{
 echo "Missing or invalid option(s):"
 echo "$@"
 echo "Try --help for more information"
 exit 1
}

process_arguments()
{
 SHORT_ARGS="t:h:p:"
 LONG_ARGS="help,timeout:,host:,port:"

 args=$(getopt -o $SHORT_ARGS -l $LONG_ARGS -n "$0"  -- "$@"  2>&1 )
 [[ $? -ne 0 ]] && invalid_arguments $( echo " $args"| head -1 )
 [[ $# -eq 0 ]] && invalid_arguments "No options provided"

 eval set -- "$args"
 cmd_arg="$0"

 while true; do
    case "$1" in
         -t|--timeout)
          TIME_OUT=$2
          shift 2 ;;
          -h|--host)
          HOST=$2
          shift 2 ;;
          -p|--port)
          PORT=$2
	  shift 2 ;;
         --help)
          usage
          exit 0
          ;;
         --)
          shift
          break ;;
         *)
          echo BAD ARGUMENTS # perhaps error
          break ;;
      esac
 done

 regex='^[0-9]+$'
 if ! [[ $TIME_OUT =~ $regex ]] ; then
   echo "$SCRIPT_NAME $(current_timestamp): error: TIME_OUT must be number $TIME_OUT" >&2; exit 1
 fi

 if [ -z "$HOST" ]; then
   echo "$SCRIPT_NAME $(current_timestamp): error: HOST must not be empty! $HOST" >&2; exit 1
 fi

 if ! [[ $PORT =~ $regex ]]; then
   echo "$SCRIPT_NAME $(current_timestamp): error: PORT must be number! $PORT" >&2; exit 1
 fi

 SLEEP_TIME=5
 START_TIME_IN_SECONDS=`date +%s`
 TIME_OUT_END_TIME_IN_SECONDS=$(($START_TIME_IN_SECONDS+$TIME_OUT));

 while [ `date +%s` -lt "$TIME_OUT_END_TIME_IN_SECONDS" ]; do
    echo "$(current_timestamp): Waiting for $HOST:$PORT to startup ..."

    nc -z "$HOST" "$PORT" > /dev/null 2>&1
    result=$?
    if [ $result -eq 0 ] ; then
        echo "$SCRIPT_NAME $(current_timestamp): $HOST:$PORT is up and running"
        break;
    fi
    echo "$SCRIPT_NAME $(current_timestamp): Sleeping for ${SLEEP_TIME} seconds"
    sleep ${SLEEP_TIME}
 done

 if [ $result -ne 0 ]; then
    echo "$SCRIPT_NAME $(current_timestamp): Time out: could not get any response from $HOST:$PORT . . ."
    exit 1
 fi

 echo "$SCRIPT_NAME $(current_timestamp): finished successfully"
}

# main body
process_arguments $@
