#!/bin/bash
# ============LICENSE_START=======================================================
#  Copyright (C) 2019 AT&T Intellectual Property. All rights reserved.
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

docker run -d --name policy-api -p 6969:6969 -it nexus3.onap.org:10001/onap/policy-api:2.0.0-SNAPSHOT-latest 

POLICY_API_IP=`get-instance-ip.sh policy-api`
echo API IP IS ${POLICY_API_IP}
# Wait for initialization
for i in {1..10}; do
   curl -sS ${POLICY_API_IP}:6969 && break
   echo sleep $i
   sleep $i
done

ROBOT_VARIABLES="-v POLICY_API_IP:${POLICY_API_IP}"
