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
Library       XnfSimulatorLibrary
Library       VesHvContainersUtilsLibrary
Library       Collections

Resource      resources/common-keywords.robot

Suite Setup       Message Routing Suite Setup
Suite Teardown    VES-HV Collector Suite Teardown
Test Teardown     VES-HV Collector Test Shutdown

*** Keywords ***
Message Routing Suite Setup
    Log   Started Suite: VES-HV Message Routing
    Configure Single xNF Simulator
    Log   Suite setup finished

*** Test Cases ***
Correct Messages Routing
    [Documentation]   VES-HV Collector should route all valid messages to topics specified in configuration
    ...               and do not change message payload generated in XNF simulator

    Send Messages From xNF Simulators   ${XNF_SIMULATOR}   ${XNF_FIXED_PAYLOAD_REQUEST}

    Wait until keyword succeeds   60 sec   5 sec
    ...    Assert Dcae App Consumed   ${DCAE_APP_API_MESSAGES_COUNT_URL}   ${AMOUNT_25000}
    Assert Dcae App Consumed Proper Messages   ${DCAE_APP_API_MESSAGES_VALIDATION_URL}   ${DCAE_FIXED_PAYLOAD_REQUEST}


Too big payload message handling
    [Documentation]   VES-HV Collector should interrupt the stream when encountered message with too big payload

    Send Messages From xNF Simulators   ${XNF_SIMULATOR}   ${XNF_TOO_BIG_PAYLOAD_REQUEST}

    Wait until keyword succeeds   60 sec   5 sec
    ...    Assert Dcae App Consumed   ${DCAE_APP_API_MESSAGES_COUNT_URL}   ${AMOUNT_25000}
    Assert Dcae App Consumed Proper Messages   ${DCAE_APP_API_MESSAGES_VALIDATION_URL}   ${DCAE_TOO_BIG_PAYLOAD_REQUEST}


Invalid wire frame message handling
    [Documentation]  VES-HV Collector should skip messages with invalid wire frame

    Send Messages From xNF Simulators   ${XNF_SIMULATOR}   ${XNF_INVALID_WIRE_FRAME_REQUEST}

    Wait until keyword succeeds   60 sec   5 sec
    ...    Assert Dcae App Consumed   ${DCAE_APP_API_MESSAGES_COUNT_URL}   ${AMOUNT_50000}
    Assert Dcae App Consumed Proper Messages   ${DCAE_APP_API_MESSAGES_VALIDATION_URL}   ${DCAE_INVALID_WIRE_FRAME_REQUEST}


Invalid GPB data message handling
    [Documentation]   VES-HV Collector should skip messages with invalid GPB data

    Send Messages From xNF Simulators   ${XNF_SIMULATOR}   ${XNF_INVALID_GPB_DATA_REQUEST}

    Wait until keyword succeeds   60 sec   5 sec
    ...    Assert Dcae App Consumed   ${DCAE_APP_API_MESSAGES_COUNT_URL}  ${AMOUNT_50000}
    Assert Dcae App Consumed Proper Messages   ${DCAE_APP_API_MESSAGES_VALIDATION_URL}   ${DCAE_INVALID_GPB_DATA_REQUEST}


Unsupported domain message handling
    [Documentation]   VES-HV Collector should skip messages with unsupported domain

    Send Messages From xNF Simulators   ${XNF_SIMULATOR}   ${XNF_UNSUPPORTED_DOMAIN_REQUEST}

    Wait until keyword succeeds   60 sec   5 sec
    ...    Assert Dcae App Consumed  ${DCAE_APP_API_MESSAGES_COUNT_URL}   ${AMOUNT_50000}
    Assert Dcae App Consumed Proper Messages   ${DCAE_APP_API_MESSAGES_VALIDATION_URL}   ${DCAE_UNSUPPORTED_DOMAIN_REQUEST}

*** Variables ***
${HTTP_METHOD_URL}                             http://

${XNF_SIM_API_PATH}                            /simulator/async

${HV_VES_SCENARIOS}                            %{WORKSPACE}/tests/dcaegen2-collectors-hv-ves/testcases/resources/scenarios
${XNF_FIXED_PAYLOAD_REQUEST}                   ${HV_VES_SCENARIOS}/fixed-payload/xnf-fixed-payload-request.json
${XNF_TOO_BIG_PAYLOAD_REQUEST}                 ${HV_VES_SCENARIOS}/too-big-payload/xnf-too-big-payload-request.json
${XNF_INVALID_WIRE_FRAME_REQUEST}              ${HV_VES_SCENARIOS}/invalid-wire-frame/xnf-invalid-wire-frame-request.json
${XNF_INVALID_GPB_DATA_REQUEST}                ${HV_VES_SCENARIOS}/invalid-gpb-data/xnf-invalid-gpb-data-request.json
${XNF_UNSUPPORTED_DOMAIN_REQUEST}              ${HV_VES_SCENARIOS}/unsupported-domain/xnf-unsupported-domain-request.json

${DCAE_FIXED_PAYLOAD_REQUEST}                  ${HV_VES_SCENARIOS}/fixed-payload/dcae-fixed-payload-request.json
${DCAE_TOO_BIG_PAYLOAD_REQUEST}                ${HV_VES_SCENARIOS}/too-big-payload/dcae-too-big-payload-request.json
${DCAE_INVALID_WIRE_FRAME_REQUEST}             ${HV_VES_SCENARIOS}/invalid-wire-frame/dcae-invalid-wire-frame-request.json
${DCAE_INVALID_GPB_DATA_REQUEST}               ${HV_VES_SCENARIOS}/invalid-gpb-data/dcae-invalid-gpb-data-request.json
${DCAE_UNSUPPORTED_DOMAIN_REQUEST}             ${HV_VES_SCENARIOS}/unsupported-domain/dcae-unsupported-domain-request.json

${AMOUNT_25000}                                25000
${AMOUNT_50000}                                50000
