*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
${MESSAGE}    Hello, world!

*** Test Cases ***

Distribute Service Template
    Create Session   refrepo  http://${REPO_IP}:8085
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}distributeServiceTemplate.json
    &{headers}=  Create Dictionary    Authorization=Basic bXNvX2FkbWluOnBhc3N3b3JkMSQ=    resource-location=/distribution-test-zip/unzipped     Content-Type=application/json    Accept=application/json
    log to console  \nAbout to POST ${REPO_IP}
    ${resp}=    Post Request    refrepo    /test/treatNotification/v1    data=${data}    headers=${headers}
    log to console  \nAFRTE POST
    Run Keyword If  '${resp.status_code}' == '200'  log to console  \nexecuted with expected result

