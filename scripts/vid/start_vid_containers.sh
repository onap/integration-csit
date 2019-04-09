#!/bin/bash
#
# ============LICENSE_START=======================================================
# ONAP CLAMP
# ================================================================================
# Copyright (C) 2017 AT&T Intellectual Property. All rights
#                             reserved.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Modifications copyright (c) 2018 Nokia Intellectual Property
# ============LICENSE_END============================================
# ===================================================================
# ECOMP is a trademark and service mark of AT&T Intellectual Property.

echo "This is ${WORKSPACE}/scripts/vid/start_vid_containers.sh"

export IP=`ifconfig eth0 | awk -F: '/inet addr/ {gsub(/ .*/,"",$2); print $2}'`

cd ${WORKSPACE}/tests/vid/resources
docker-compose up -d --build

# WAIT 5 minutes maximum and test every 5 seconds if VID up using HealthCheck API

TIME_OUT=300
INTERVAL=5
TIME=0

	for i in {1..10}; do
	    if [ $(docker inspect -f '{{ .State.Running }}' vid-server) ]
	    then
		echo "VID service is running"
		VID_DOCKER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' vid-server)
		break
	    else
		echo "Waiting for vid-server docker initialization... $i"
		sleep $i
	    fi
	done

while [ "$TIME" -lt "$TIME_OUT" ]; do
  response=$(curl --write-out '%{http_code}' --silent --output /dev/null http://"$VID_DOCKER_IP":8080/vid/healthCheck); echo $response

  if [ "$response" == "200" ]; then
    echo VID and its database well started in $TIME seconds
    break;
  fi

  echo Sleep: $INTERVAL seconds before testing if VID is up. Total wait time up now is: $TIME seconds. Timeout is: $TIME_OUT seconds
  sleep $INTERVAL
  TIME=$(($TIME+$INTERVAL))
done

if [ "$TIME" -ge "$TIME_OUT" ]; then
   echo TIME OUT: Docker containers not started in $TIME_OUT seconds... Could cause problems for tests...
fi
