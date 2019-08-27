*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
${login}                     admin
${passw}                     password

*** Keywords ***
Create the sessions
    ${auth}=    Create List     ${login}    ${passw}
    Create Session   clamp  https://localhost:8443   auth=${auth}   disable_warnings=1
    Set Global Variable     ${clamp_session}      clamp

*** Test Cases ***
Get Requests health check ok
    Create the sessions
    ${resp}=    Get Request    ${clamp_session}   /restservices/clds/v1/healthcheck
    Should Be Equal As Strings  ${resp.status_code}     200

Open TCA1
    ${resp}=    Get Request    ${clamp_session}   /restservices/clds/v2/loop/LOOP_ejh5S_v1_0_ResourceInstanceName1_tca
    Should Contain Match    ${resp}   *Name1_tca*
    Should Contain Match    ${resp}   *Operational Policy*
    Should Contain Match    ${resp}   *Micro Service policies UPDATED*
    Should Contain Match    ${resp}   *POLICY SUBMIT request*
