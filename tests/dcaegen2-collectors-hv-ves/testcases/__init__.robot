# ============LICENSE_START=======================================================
# csit-dcaegen2-collectors-hv-ves
# ================================================================================
# Copyright (C) 2018-2019 NOKIA
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

*** Settings ***
Library       DcaeAppSimulatorLibrary
Library       ConsulLibrary
Library       VesHvContainersUtilsLibrary

Suite Setup       HV-VES Collector Suites Setup

*** Keywords ***
HV-VES Collector Suites Setup
    Log   Started Suite: HV-VES
    Configure collector
    Configure Dcae App
    Log   Suite setup finished


Configure collector
    ${CONSUL_API_ACCESS}=   Get Consul Api Access Url   ${HTTP_METHOD_URL}   ${CONSUL_CONTAINER_HOST}   ${CONSUL_CONTAINER_PORT}
    ${CONSUL_API_URL}=  Catenate   SEPARATOR=   ${CONSUL_API_ACCESS}   ${CONSUL_HV_VES_CONFIGURATION_KEY_PATH}
    Set Suite Variable    ${CONSUL_API_URL}   children=True
    Publish HV VES Configuration In Consul    ${CONSUL_API_URL}   ${HV_VES_CONFIGURATION_JSON_FILEPATH}

Configure Dcae App
    Wait until keyword succeeds   10 sec   5 sec
    ...    Configure Dcae App Simulator To Consume Messages From Topics   ${DEFAULT_PERF3GPP_TOPIC},${SECOND_PERF3GPP_TOPIC}
    Set Suite Variable   ${DEFAULT_PERF3GPP_TOPIC}   children=True
    Set Suite Variable   ${SECOND_PERF3GPP_TOPIC}    children=True


*** Variables ***
${HTTP_METHOD_URL}                             http://

${CONSUL_CONTAINER_HOST}                       consul-server
${CONSUL_CONTAINER_PORT}                       8500
${CONSUL_HV_VES_CONFIGURATION_KEY_PATH}        /v1/kv/dcae-hv-ves-collector

${DEFAULT_PERF3GPP_TOPIC}                      TEST_HV_VES_PERF3GPP
${SECOND_PERF3GPP_TOPIC}                       TEST_HV_VES_PERF3GPP_BUT_WITH_EXTRA_WORDS

${HV_VES_RESOURCES}                            %{WORKSPACE}/tests/dcaegen2-collectors-hv-ves/testcases/resources
${HV_VES_CONFIGURATION_JSON_FILEPATH}          ${HV_VES_RESOURCES}/hv-ves-configuration.json
