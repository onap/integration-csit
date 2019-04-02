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
Library       XnfSimulatorLibrary
Library       VesHvContainersUtilsLibrary
Library       KafkaLibrary
Library       Collections

*** Keywords ***
Configure Single xNF Simulator
    ${XNF_PORTS_LIST}=    Create List    7000
    ${XNF_SIMULATORS_ADDRESSES}=   Configure xNF Simulators   ${XNF_PORTS_LIST}
    ${XNF_SIMULATOR}=   Get Slice From List   ${XNF_SIMULATORS_ADDRESSES}   0   1
    Set Suite Variable   ${XNF_SIMULATOR}

Configure xNF Simulators Using Valid Certificates On Ports
    [Arguments]    ${XNF_PORTS_LIST}
    ${VALID_XNF_SIMULATORS_ADDRESSES}=   Configure xNF Simulators   ${XNF_PORTS_LIST}
    Set Suite Variable    ${VALID_XNF_SIMULATORS_ADDRESSES}

Configure xNF Simulators
    [Arguments]    ${XNF_PORTS_LIST}
    ...            ${should_use_valid_certs}=${true}
    ...            ${should_disable_ssl}=${false}
    ...            ${should_connect_to_unencrypted_hv_ves}=${false}
    ${XNF_SIMULATORS_ADDRESSES}=   Start Xnf Simulators   ${XNF_PORTS_LIST}
    ...                                                           ${should_use_valid_certs}
    ...                                                           ${should_disable_ssl}
    ...                                                           ${should_connect_to_unencrypted_hv_ves}
    [Return]   ${XNF_SIMULATORS_ADDRESSES}

Get xNF Simulators Using Valid Certificates
    [Arguments]  ${AMOUNT}=1
    ${SIMULATORS}=   Get Slice From List   ${VALID_XNF_SIMULATORS_ADDRESSES}   0   ${AMOUNT}
    [Return]   ${SIMULATORS}


Send Messages From xNF Simulators
    [Arguments]    ${XNF_HOSTS_LIST}   ${MESSAGE_FILEPATH}
    :FOR   ${HOST}   IN    @{XNF_HOSTS_LIST}
    \    ${XNF_SIM_API_ACCESS}=   Get xNF Sim Api Access Url   ${HTTP_METHOD_URL}   ${HOST}
    \    ${XNF_SIM_API_URL}=  Catenate   SEPARATOR=   ${XNF_SIM_API_ACCESS}   ${XNF_SIM_API_PATH}
    \    Send messages   ${XNF_SIM_API_URL}   ${MESSAGE_FILEPATH}


VES-HV Collector Test Shutdown
    Reset DCAE App Simulator  ${DEFAULT_PERF3GPP_TOPIC}
    Reset DCAE App Simulator  ${SECOND_PERF3GPP_TOPIC}


VES-HV Collector Suite Teardown
    Log Kafka Status
    Stop And Remove All Xnf Simulators   ${SUITE NAME}

*** Variables ***
${HTTP_METHOD_URL}                             http://

${XNF_SIM_API_PATH}                            /simulator/async

