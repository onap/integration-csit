# ============LICENSE_START=======================================================
# csit-dcaegen2-collectors-hv-ves
# ================================================================================
# Copyright (C) 2019 NOKIA
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

Resource      resources/common-keywords.robot

Suite Setup       Configuration Changes Suite Setup
Suite Teardown    VES-HV Collector Suite Teardown
Test Teardown     VES-HV Collector Test Shutdown

*** Keywords ***
Configuration Changes Suite Setup
    Log   Started Suite: VES-HV Client Configuration Changes
    Configure Single xNF Simulator
    Log   Suite setup finished

*** Test Cases ***
Configuration change
    [Documentation]   VES-HV Collector should adapt to changing configuration
    # Given perf3gpp topic in configuration
    Publish HV VES Configuration In Consul    ${CONSUL_API_URL}   ${DIFFERENT_TOPIC_CONFIGURATION_JSON_FILEPATH}
    Wait until keyword succeeds   10 sec   5 sec
            ...    Configure Dcae App Simulator To Consume Messages From Topics   ${DCAE_APP_API_TOPIC_CONFIGURATION_URL}  ${CHANGED_MESSAGES_TOPIC}

    # When sending messages
    Send Messages From xNF Simulators   ${XNF_SIMULATOR}   ${XNF_VALID_MESSAGES_REQUEST}

    # Then they are published to this topic
    Wait until keyword succeeds   60 sec   5 sec
    ...     Assert Dcae App Consumed   ${DCAE_APP_API_MESSAGES_COUNT_URL}   ${AMOUNT_5000}
    Log   First configuration change assertion passed

    # CONFIGURATION CHANGE
    # Given different topic in configuration
    Publish HV VES Configuration In Consul    ${CONSUL_API_URL}   ${HV_VES_CONFIGURATION_JSON_FILEPATH}
    Reset DCAE App Simulator  ${DCAE_APP_API_MESSAGE_RESET_URL}
    Wait until keyword succeeds   10 sec   5 sec
    ...    Configure Dcae App Simulator To Consume Messages From Topics   ${DCAE_APP_API_TOPIC_CONFIGURATION_URL}  ${ROUTED_MESSAGES_TOPIC}

    # When sending messages
    Send Messages From xNF Simulators   ${XNF_SIMULATOR}   ${XNF_VALID_MESSAGES_REQUEST}

    # Then they are published to this topic
    Wait until keyword succeeds   60 sec   5 sec
    ...     Assert Dcae App Consumed   ${DCAE_APP_API_MESSAGES_COUNT_URL}   ${AMOUNT_5000}



*** Variables ***
${AMOUNT_5000}                                      5000

${HV_VES_SCENARIOS}                                 %{WORKSPACE}/tests/dcaegen2-collectors-hv-ves/testcases/resources/scenarios
${XNF_VALID_MESSAGES_REQUEST}                       ${HV_VES_SCENARIOS}/configuration-change/xnf-valid-messages-request.json

${HV_VES_RESOURCES}                                 %{WORKSPACE}/tests/dcaegen2-collectors-hv-ves/testcases/resources
${HV_VES_CONFIGURATION_JSON_FILEPATH}               ${HV_VES_RESOURCES}/hv-ves-configuration.json
${DIFFERENT_TOPIC_CONFIGURATION_JSON_FILEPATH}      ${HV_VES_RESOURCES}/hv-ves-configuration-with-different-topic.json

${ROUTED_MESSAGES_TOPIC}                            TEST_HV_VES_PERF3GPP
${CHANGED_MESSAGES_TOPIC}                           TEST_HV_VES_PERF3GPP_BUT_WITH_EXTRA_WORDS
