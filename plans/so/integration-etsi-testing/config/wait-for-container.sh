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

SCRIPT_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPT_NAME=$(basename $0)
WAIT_FOR_SCRIPT=$SCRIPT_HOME/wait-for.sh

# Process the arguments passed to the script
usage()
{
 _msg_="$@"
 cat<<-EOF
 Command Arguments:

 -c, --container-name
 Mandatory argument. container name

 -n, --network-name
 Mandatory argument. network name

 -t, --timeout
 Mandatory argument. time out value in seconds (must be number)

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
 SHORT_ARGS="c:n:t:"
 LONG_ARGS="help,container-name:,network-name:,timeout:"

 args=$(getopt -o $SHORT_ARGS -l $LONG_ARGS -n "$0"  -- "$@"  2>&1 )
 [[ $? -ne 0 ]] && invalid_arguments $( echo " $args"| head -1 )
 [[ $# -eq 0 ]] && invalid_arguments "No options provided"

 eval set -- "$args"
 cmd_arg="$0"

 while true; do
    case "$1" in
         -c|--container-name)
          NAME=$2
          shift 2 ;;
         -n|--network-name)
          NETWORK_NAME=$2
          shift 2 ;;
          -t|--timeout)
          TIME_OUT=$2
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

 if [ -z "$NAME" ]; then
   echo "$SCRIPT_NAME $(current_timestamp): error: Container name  must not be empty! $NAME" >&2; exit 1
 fi

 if [ -z "$NETWORK_NAME" ]; then
   echo "$SCRIPT_NAME $(current_timestamp): error: network name  must not be empty! $NETWORK_NAME" >&2; exit 1
 fi

 regex='^[0-9]+$'
 if ! [[ $TIME_OUT =~ $regex ]] ; then
   echo "$SCRIPT_NAME $(current_timestamp): error: TIME_OUT must be number $TIME_OUT" >&2; exit 1
 fi

 CONTAINER_NAME=$(docker ps -aqf "name=$NAME" --format "{{.Names}}")

 if [ $? -ne 0 ]; then
   echo "$SCRIPT_NAME $(current_timestamp) ERROR: Unable to find container using $NAME"
   exit 1
 fi

 result=$(docker inspect --format '{{.State.Running}}' $CONTAINER_NAME)

 if [ $result != "true" ] ; then
  docker logs $CONTAINER_NAME
  echo "$SCRIPT_NAME $(current_timestamp) ERROR: $CONTAINER_NAME container is not running"
  exit 1
 fi

 HOST_IP=$(docker inspect --format '{{ index .NetworkSettings.Networks "'$NETWORK_NAME'" "IPAddress"}}' $CONTAINER_NAME)

 if [ $? -ne 0 ] || [ -z $HOST_IP ] ; then
   echo "$SCRIPT_NAME $(current_timestamp) ERROR: Unable to find HOST IP using network name: $NETWORK_NAME and container name: $CONTAINER_NAME"
   exit 1
 fi

 PORT=$(docker port $CONTAINER_NAME | cut -c1-$(docker port $CONTAINER_NAME | grep -aob '/' | grep -oE '[0-9]+'))

 if [ $? -ne 0 ] || [ -z $PORT ] ; then
   echo "$SCRIPT_NAME $(current_timestamp) ERROR: Unable to find PORT using project name: $PROJECT_NAME and container name: $CONTAINER_NAME"
   exit 1
 fi

 $WAIT_FOR_SCRIPT -t "$TIME_OUT" -h "$HOST_IP" -p "$PORT"

 if [ $? -ne 0 ]; then
   docker logs $CONTAINER_NAME
   echo "$SCRIPT_NAME $(current_timestamp) ERROR: wait-for.sh failed ..."
   exit 1
 fi

 echo "$SCRIPT_NAME $(current_timestamp): finished successfully"
}

# main body
process_arguments $@
