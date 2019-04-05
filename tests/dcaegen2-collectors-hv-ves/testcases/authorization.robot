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

Suite Setup       Client Authorization Suite Setup
Suite Teardown    VES-HV Collector Suite Teardown
Test Teardown     VES-HV Collector Test Shutdown

*** Keywords ***
Client Authorization Suite Setup
    Log   Started Suite: VES-HV Client Authorization
    ${XNF_PORTS_LIST}=    Create List    7000
    ${XNF_WITH_INVALID_CERTIFICATES}=   Configure xNF Simulators    ${XNF_PORTS_LIST}
    ...                                               should_use_valid_certs=${false}
    Set Suite Variable   ${XNF_WITH_INVALID_CERTIFICATES}
    ${XNF_PORTS_LIST}=    Create List    7001
    ${XNF_WITHOUT_SSL}=   Configure xNF Simulators    ${XNF_PORTS_LIST}
    ...                                               should_disable_ssl=${true}
    Set Suite Variable   ${XNF_WITHOUT_SSL}
    ${XNF_PORTS_LIST}=    Create List    7002
    ${XNF_WITHOUT_SSL_CONNECTING_TO_UNENCRYPTED_HV_VES}=   Configure xNF Simulators    ${XNF_PORTS_LIST}
    ...                                                                                should_disable_ssl=${true}
    ...                                                                                should_connect_to_unencrypted_hv_ves=${true}
    Set Suite Variable   ${XNF_WITHOUT_SSL_CONNECTING_TO_UNENCRYPTED_HV_VES}
    Log   Suite setup finished

*** Test Cases ***
Authorization
    [Documentation]   VES-HV Collector should not authorize XNF with invalid certificate and not route any message
    ...               to topics

    Send Messages From xNF Simulators   ${XNF_WITH_INVALID_CERTIFICATES}   ${XNF_VALID_MESSAGES_REQUEST}

    Wait until keyword succeeds   60 sec   5 sec
    ...     Assert Dcae App Consumed   ${DEFAULT_PERF3GPP_TOPIC}   ${AMOUNT_0}

Unencrypted connection from client
    [Documentation]   VES-HV Collector should not authorize XNF trying to connect through unencrypted connection

    Send Messages From xNF Simulators   ${XNF_WITHOUT_SSL}   ${XNF_VALID_MESSAGES_REQUEST}

    Wait until keyword succeeds   60 sec   5 sec
    ...     Assert Dcae App Consumed   ${DEFAULT_PERF3GPP_TOPIC}   ${AMOUNT_0}

Unencrypted connection on both ends
    [Documentation]   When run without SSL turned on, VES-HV Collector should route all valid messages
    ...               from xNF trying to connect through unencrypted connection

    Send Messages From xNF Simulators   ${XNF_WITHOUT_SSL_CONNECTING_TO_UNENCRYPTED_HV_VES}   ${XNF_VALID_MESSAGES_REQUEST}

    Wait until keyword succeeds   60 sec   5 sec
    ...     Assert Dcae App Consumed   ${DEFAULT_PERF3GPP_TOPIC}   ${AMOUNT_5000}


*** Variables ***
${HV_VES_SCENARIOS}                            %{WORKSPACE}/tests/dcaegen2-collectors-hv-ves/testcases/resources/scenarios

${XNF_VALID_MESSAGES_REQUEST}                  ${HV_VES_SCENARIOS}/authorization/xnf-valid-messages-request.json

${AMOUNT_0}                                    0
${AMOUNT_5000}                                 5000
