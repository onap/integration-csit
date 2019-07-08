*** Settings ***
Documentation     Integration tests for PRH when cert auth for dmaap and aai is disabled.
Suite Setup       Run keywords   Create Headers  AND  Create sessions   AND
...               Set PRH CBS config from file    ${CONFIGS_DIR}/prh-no-auth-config.json
Test Teardown     Reset Simulators
Test Timeout      2 minutes

Resource          resources/prh_sessions.robot
Resource          resources/prh_library.robot
Resource          resources/prh_config_library.robot

*** Variables ***
${TEST_CASES_DIR}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets

*** Test Cases ***
Simple registration event
    [Documentation]    simple registration scenario when AAI and dmaap cert atuh is disabled
    [Tags]    PRH    Valid event
    [Template]    Verify PNF ready sent
    ${TEST_CASES_DIR}/ves-event-without-additional-fields