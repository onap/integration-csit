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

Resource      resources/common-keywords.robot

Suite Setup       Multiple Clients Handling Suite Setup
Suite Teardown    VES-HV Collector Suite Teardown
Test Teardown     VES-HV Collector Test Shutdown

*** Keywords ***
Multiple Clients Handling Suite Setup
    Log   Started Suite: VES-HV Multiple Clients Handling
    ${XNF_PORTS_LIST}=    Create List    7000   7001   7002
    Configure xNF Simulators Using Valid Certificates On Ports    ${XNF_PORTS_LIST}
    Log   Suite setup finished

*** Test Cases ***
Handle Multiple Connections
    [Documentation]   VES-HV Collector should handle multiple incoming transmissions

    ${SIMULATORS_LIST}=   Get xNF Simulators Using Valid Certificates   3
    Send Messages From xNF Simulators   ${SIMULATORS_LIST}   ${XNF_SMALLER_PAYLOAD_REQUEST}

    Wait until keyword succeeds   60 sec   5 sec
    ...     Assert Dcae App Consumed   ${DEFAULT_PERF3GPP_TOPIC}   ${AMOUNT_15000}
    Assert Dcae App Consumed Proper Messages   ${DEFAULT_PERF3GPP_TOPIC}   ${DCAE_SMALLER_PAYLOAD_REQUEST}


*** Variables ***
${HV_VES_SCENARIOS}                            %{WORKSPACE}/tests/dcaegen2-collectors-hv-ves/testcases/resources/scenarios

${XNF_SMALLER_PAYLOAD_REQUEST}                 ${HV_VES_SCENARIOS}/multiple-simulators-payload/xnf-simulator-smaller-valid-request.json
${DCAE_SMALLER_PAYLOAD_REQUEST}                ${HV_VES_SCENARIOS}/multiple-simulators-payload/dcae-smaller-valid-request.json

${AMOUNT_15000}                                15000
