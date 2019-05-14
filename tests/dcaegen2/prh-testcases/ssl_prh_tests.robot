*** Settings ***
Documentation     Integration tests for PRH.
...               PRH receive events from DMaaP and produce or not PNF_READY notification depends on required fields in received event. PRH comunicates with AAI and DMaaP through SSL
Suite Setup       Run keywords   Create headers  AND  Create sessions
Test Teardown     Reset Simulators
Library           resources/PrhLibrary.py
Resource          resources/prh_library.robot
Resource          ../../common.robot

*** Variables ***
${TEST_CASES_DIR}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets

${DMAAP_SIMULATOR_SETUP_URL}    http://${DMAAP_SIMULATOR_SETUP}
${AAI_SIMULATOR_SETUP_URL}    http://${AAI_SIMULATOR_SETUP}
${CONSUL_SETUP_URL}    http://${CONSUL_SETUP}

*** Test Cases ***
Valid DMaaP event can be converted to PNF_READY notification with ssl connection to AAI
    [Template]    Verify PNF ready sent
    ${TEST_CASES_DIR}/ves-event-without-additional-fields