*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem

*** Variables ***
${BASIC_AUTH}=                     Basic bXNvX2FkbWluOnBhc3N3b3JkMSQ=
${DISTRIBUTE_SERVICE_TEMPLATE}=    ${CURDIR}${/}data${/}distributeCnfServiceTemplate.json
${RESOURCE_LOCATION}=              /distribution-test-zip/unzipped/
*** Test Cases ***

Distribute Service Template Containing ASD
    Create Session   sdc_controller_session  http://${REPO_IP}:8085
    ${data}=    Get Binary File     ${DISTRIBUTE_SERVICE_TEMPLATE}
    &{headers}=  Create Dictionary    Authorization=${BASIC_AUTH}    resource-location=${RESOURCE_LOCATION}    Content-Type=application/json    Accept=application/json
    ${resp}=    Post On Session    sdc_controller_session    /test/treatNotification/v1    data=${data}    headers=${headers}
    Should Be Equal As Strings    '${resp.status_code}'    '200'
