*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Test Cases ***
Healthcheck
    [Documentation]    Runs AAI SIMULATOR Health check
    Create Session   aai_simulator_session  https://${REPO_IP}:9993
    &{headers}=  Create Dictionary    Accept=text/plain
    ${resp}=    Get Request    aai_simulator_session    /aai/v19/healthcheck    headers=${headers}
    log to console    Received response from AAI SIMULATOR ${resp.text}
    Should Be Equal As Strings    '${resp.status_code}'    '200'
    Should Be Equal As Strings    '${resp.text}'    'healthy'
