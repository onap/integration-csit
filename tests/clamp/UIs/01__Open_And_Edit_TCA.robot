*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     ../../../scripts/clamp/python-lib/CustomSeleniumLibrary.py
Library     XvfbRobot
*** Variables ***
${login}                     admin
${passw}                     password
${SELENIUM_SPEED_FAST}       1 seconds
${SELENIUM_SPEED_SLOW}       2 seconds
${BASE_URL}                  https://localhost:443
*** Keywords ***
Create the sessions
    ${auth}=    Create List     ${login}    ${passw}
    Create Session   clamp  ${BASE_URL}    auth=${auth}   disable_warnings=1
    Set Global Variable     ${clamp_session}      clamp
*** Test Cases ***
Get Requests health check ok
    Create the sessions
    ${resp}=    Get Request    ${clamp_session}   /restservices/clds/v1/healthcheck
    Should Be Equal As Strings  ${resp.status_code}     200
