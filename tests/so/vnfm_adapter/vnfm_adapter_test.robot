*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***


*** Test Cases ***

Healthcheck
    Create Session   refrepo  http://${REPO_IP}:9092
    &{headers}=  Create Dictionary    Authorization=Basic dm5mbTpwYXNzd29yZDEk==    Content-Type=application/json
    ${resp}=    Get Request    refrepo    /manage/health    headers=${headers}
    Run Keyword If  '${resp.status_code}' == 'UP'   log to console  \nexecuted with expected result
