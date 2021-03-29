#!/bin/bash
#
# ============LICENSE_START=======================================================
# org.onap.dmaap
# ================================================================================
# Copyright (C) 2018 AT&T Intellectual Property. All rights reserved.
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
# ============LICENSE_END=========================================================

#kill-instance.sh dmaapbc
cd ${WORKSPACE}/archives/dmaap/dr
rm -rf last_run_logs/*
docker cp datarouter-prov:/opt/app/datartr/logs last_run_logs/prov_logs
docker cp datarouter-node:/opt/app/datartr/logs last_run_logs/node_event_logs
docker cp datarouter-node:/var/log/onap/datarouter last_run_logs/node_server_logs
docker cp subscriber-node:/var/log/onap/datarouter last_run_logs/sub1_logs
docker cp subscriber-node2:/var/log/onap/datarouter last_run_logs/sub2_logs
docker cp dmaap-bc:/opt/app/dmaapbc/logs/ONAP last_run_logs/bc_logs

sudo sed -i".bak" '/dmaap-dr-prov/d' /etc/hosts
sudo sed -i".bak" '/dmaap-dr-node/d' /etc/hosts
docker-compose -f ${WORKSPACE}/scripts/dmaap-datarouter/docker-compose/docker-compose.yml rm -sf
docker-compose -f ${WORKSPACE}/scripts/dmaap-buscontroller/docker-compose/docker-compose-bc.yml rm -sf
