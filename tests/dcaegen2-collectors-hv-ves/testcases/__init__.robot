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
    Publish HV VES Configuration In Consul    ${CONSUL_API_URL}   ${HV_VES_CONFIGURATION_JSON_FILEPATH}

Configure Dcae App
    ${DCAE_APP_API_ACCESS}=   Get Dcae App Api Access Url   ${HTTP_METHOD_URL}   ${DCAE_APP_CONTAINER_HOST}   ${DCAE_APP_CONTAINER_PORT}

    ${DCAE_APP_API_MESSAGE_RESET_URL}=   Catenate   SEPARATOR=   ${DCAE_APP_API_ACCESS}   ${DCAE_APP_API_MESSAGES_RESET_PATH}
    Set Suite Variable    ${DCAE_APP_API_MESSAGE_RESET_URL}    children=True

    ${DCAE_APP_API_MESSAGES_COUNT_URL}=  Catenate   SEPARATOR=   ${DCAE_APP_API_ACCESS}   ${DCAE_APP_API_MESSAGES_COUNT_PATH}
    Set Suite Variable    ${DCAE_APP_API_MESSAGES_COUNT_URL}    children=True

    ${DCAE_APP_API_MESSAGES_VALIDATION_URL}=  Catenate   SEPARATOR=   ${DCAE_APP_API_ACCESS}   ${DCAE_APP_API_MESSAGES_VALIDATION_PATH}
    Set Suite Variable    ${DCAE_APP_API_MESSAGES_VALIDATION_URL}    children=True

    ${DCAE_APP_API_TOPIC_CONFIGURATION_URL}=  Catenate   SEPARATOR=   ${DCAE_APP_API_ACCESS}   ${DCAE_APP_API_TOPIC_CONFIGURATION_PATH}
    Wait until keyword succeeds   10 sec   5 sec
    ...    Configure Dcae App Simulator To Consume Messages From Topics   ${DCAE_APP_API_TOPIC_CONFIGURATION_URL}  ${ROUTED_MESSAGES_TOPIC}


*** Variables ***
${HTTP_METHOD_URL}                             http://

${CONSUL_CONTAINER_HOST}                       consul-server
${CONSUL_CONTAINER_PORT}                       8500
${CONSUL_HV_VES_CONFIGURATION_KEY_PATH}        /v1/kv/dcae-hv-ves-collector

${DCAE_APP_CONTAINER_HOST}                     dcae-app-simulator
${DCAE_APP_CONTAINER_PORT}                     6063
${DCAE_APP_API_TOPIC_CONFIGURATION_PATH}       /configuration/topics
${DCAE_APP_API_MESSAGES_RESET_PATH}            /messages
${DCAE_APP_API_MESSAGES_PATH}                  /messages/all
${DCAE_APP_API_MESSAGES_COUNT_PATH}            ${DCAE_APP_API_MESSAGES_PATH}/count
${DCAE_APP_API_MESSAGES_VALIDATION_PATH}       ${DCAE_APP_API_MESSAGES_PATH}/validate

${ROUTED_MESSAGES_TOPIC}                       TEST_HV_VES_PERF3GPP

${HV_VES_RESOURCES}                            %{WORKSPACE}/tests/dcaegen2-collectors-hv-ves/testcases/resources
${HV_VES_CONFIGURATION_JSON_FILEPATH}          ${HV_VES_RESOURCES}/hv-ves-configuration.json
