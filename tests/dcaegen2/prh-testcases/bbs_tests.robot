*** Settings ***
Documentation     Integration tests for PRH.
...               PRH receive events from DMaaP and produce or not PNF_READY notification depends on required fields in received event.
Suite Setup       Run keywords   Create headers  AND  Create sessions  AND  Ensure Container Is Running  prh  AND  Ensure Container Is Exited  ssl_prh
Suite Teardown    Run keywords   Ensure Container Is Running  ssl_prh  AND  Ensure Container Is Exited  prh  AND  Reset Simulators
Test Teardown     Reset Simulators
Library           resources/PrhLibrary.py
Resource          resources/prh_library2.robot
Resource          ../../common.robot

*** Variables ***
${TEST_CASE_DIR}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets

${DMAAP_SIMULATOR_SETUP_URL}    http://${DMAAP_SIMULATOR_SETUP}
${AAI_SIMULATOR_SETUP_URL}    http://${AAI_SIMULATOR_SETUP}

*** Test Cases ***

Correct VES event with additional fields
    [Tags]    PRH
    [Template]    VES event with additional fields
    ${TEST_CASE_DIR}/bbs_registration
