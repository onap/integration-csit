*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***


*** Test Cases ***

Adapter Healthcheck
    Create Session   refrepo  http://${REPO_IP}:9092
    &{headers}=  Create Dictionary    Authorization=Basic dm5mbTpwYXNzd29yZDEk==    Content-Type=application/json
    ${resp}=    Get Request    refrepo    /manage/health    headers=${headers}
    Log To Console  repsonce code is ${resp.status_code}
    Run Keyword If  ${resp.status_code} == "Anything"   log to console  \nexecuted with expected result

SDC Sim Healthcheck
    Create Session   refrepo  http://${REPO_IP}:9991
    &{headers}=  Create Dictionary   Content-Type=application/json
    ${resp}=    Get Request    refrepo    /sdc/simulator/v1/healthcheck    headers=${headers}
    Run Keyword If  '${resp.status_code}' == 'DOWN'   log to console  \nexecuted with expected result
