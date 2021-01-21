#!/bin/bash

#  ============LICENSE_START===============================================
#  Copyright (C) 2020 Nordix Foundation. All rights reserved.
#  ========================================================================
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#  ============LICENSE_END=================================================

SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)
docker stop $(docker ps -aq)
docker system prune -f

cd ${SHELL_FOLDER}/../config
cp application_configuration.json.nosdnc application_configuration.json

cd ${SHELL_FOLDER}/../
docker-compose up -d

# Healthcheck docker containers
for i in {1..20}; do
    echo "policy types from policy agent:"
    curlString="curl -skw %{http_code} http://localhost:30001/"
    res=$($curlString)
    echo "$res"
    expect="OK200"
    if [ "$res" == "$expect" ]; then
        echo -e "SIM1 is alive!\n"
        break;
    else
        sleep $i
    fi
done

for i in {1..20}; do
    echo "policy types from policy agent:"
    curlString="curl -skw %{http_code} http://localhost:30003/"
    res=$($curlString)
    echo "$res"
    expect="OK200"
    if [ "$res" == "$expect" ]; then
        echo -e "SIM2 is alive!\n"
        break;
    else
        sleep $i
    fi
done

for i in {1..20}; do
    echo "policy types from policy agent:"
    curlString="curl -skw %{http_code} http://localhost:30005/"
    res=$($curlString)
    echo "$res"
    expect="OK200"
    if [ "$res" == "$expect" ]; then
        echo -e "SIM3 is alive!\n"
        break;
    else
        sleep $i
    fi
done

for i in {1..20}; do
    echo "policy types from policy agent:"
    curlString="curl -skw %{http_code} http://localhost:8001/status/"
    res=$($curlString)
    echo "$res"
    expect="hunky dory200"
    if [ "$res" == "$expect" ]; then
        echo -e "PMS is alive!\n"
        break;
    else
        sleep $i
    fi
done

cd ${SHELL_FOLDER}/../data
./preparePmsData.sh

