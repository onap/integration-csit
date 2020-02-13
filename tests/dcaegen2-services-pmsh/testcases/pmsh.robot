*** Settings ***
Documentation     Testing PMSH functionality
Library           OperatingSystem
Library           RequestsLibrary
Library           String

Test Setup        Create Session  pmsh_session  ${PMSH_BASE_URL}
Test Teardown     Delete All Sessions


*** Variables ***
${PMSH_BASE_URL}                    https://${PMSH_IP}:8443
${HEALTHCHECK_ENDPOINT}             /healthcheck


*** Test Cases ***
Verify Health Check returns 200 when a REST GET request to healthcheck url
    [Tags]                          PMSH_01
    [Documentation]                 Verify Health Check returns 200 when a REST GET request to healthcheck url
    [Timeout]                       1 minute
    ${resp}=                        Get Request                      pmsh_session  ${HEALTHCHECK_ENDPOINT}
    VerifyResponse                  ${resp.status_code}              200

Verify Health Check response includes healthy status
    [Tags]                          PMSH_02
    [Documentation]                 Verify Health Check response includes healthy status
    [Timeout]                       1 minute
    ${resp}=                        Get Request                      pmsh_session  ${HEALTHCHECK_ENDPOINT}
    VerifyResponseContains          ${resp.text}                  healthy

*** Keywords ***
VerifyResponse
    [Arguments]                     ${actual_response_value}         ${expected_response_value}
    Should Be Equal As Strings      ${actual_response_value}         ${expected_response_value}

VerifyResponseContains
    [Arguments]                     ${response_content}             ${string_to_check_for}
    Should Contain                  ${response_content}             ${string_to_check_for}
