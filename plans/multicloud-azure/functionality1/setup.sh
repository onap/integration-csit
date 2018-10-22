#!/bin/bash
#
# Copyright (c) 2018 Amdocs
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

pushd ${SCRIPTS}

# start multicloud-azure
./run-instance.sh nexus3.onap.org:10001/onap/multicloud/azure:latest multicloud-azure
SERVICE_IP=$(./get-instance-ip.sh multicloud-azure)
SERVICE_PORT=9008
popd

if [[ $no_proxy && $no_proxy != *$SERVICE_IP* ]]; then
	export no_proxy+=$no_proxy,$SERVICE_IP
fi

for i in {1..50}; do
    curl -sS ${SERVICE_IP}:${SERVICE_PORT} && break
    echo sleep $i
    sleep $i
done

# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES+="-v SERVICE_IP:${SERVICE_IP} "
ROBOT_VARIABLES+="-v SERVICE_PORT:${SERVICE_PORT} "
