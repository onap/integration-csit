#!/bin/bash
# ============LICENSE_START===================================================
#  Copyright (C) 2019-2021 Nordix Foundation.
# ============================================================================
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
# ============LICENSE_END=====================================================

function teardown_dmaap_dr (){
    cd ${WORKSPACE}/archives/dmaap/dr
    rm -rf last_run_logs/*
    docker cp datarouter-prov:/opt/app/datartr/logs last_run_logs/prov_logs
    docker cp datarouter-node:/opt/app/datartr/logs last_run_logs/node_event_logs
    docker cp datarouter-node:/var/log/onap/datarouter last_run_logs/node_server_logs
    docker cp subscriber-node:/var/log/onap/datarouter last_run_logs/sub1_logs
    docker cp subscriber-node2:/var/log/onap/datarouter last_run_logs/sub2_logs
    sudo sed -i".bak" '/dmaap-dr-prov/d' /etc/hosts
    sudo sed -i".bak" '/dmaap-dr-node/d' /etc/hosts
    docker-compose -f ${WORKSPACE}/scripts/dmaap-datarouter/docker-compose/docker-compose.yml rm -sf
    cd ${WORKSPACE}/scripts/dmaap-datarouter/robot_ssl
    python -c 'import update_ca; update_ca.remove_onap_ca_cert()'
}