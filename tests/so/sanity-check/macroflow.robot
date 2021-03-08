*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Test Cases ***
Distribute Service Template
    Create Session   sdc_controller_session  http://${REPO_IP}:8085
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}serviceBasicVfCnfnotification.json
    &{headers}=  Create Dictionary    Authorization=Basic bXNvX2FkbWluOnBhc3N3b3JkMSQ=    resource-location=/distribution-test-zip/unzipped/    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    sdc_controller_session    /test/treatNotification/v1    data=${data}    headers=${headers}
    Log To Console     Received status code: ${resp.status_code}
    Run Keyword If  '${resp.status_code}' == '200'  log to console  \nexecuted with expected result
    Should Be Equal As Strings    '${resp.status_code}'    '200'


Macroflow
    Create Session   api_handler_session  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}macroflow.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${service_instantiation_request}=    Post Request    api_handler_session    /onap/so/infra/serviceInstantiation/v7/serviceInstances    data=${data}    headers=${headers}
    Log To Console     Received status code: ${service_instantiation_request.status_code}
    Run Keyword If  '${service_instantiation_request.status_code}' == '202'  log to console   \nexecuted with expected result
    Should Be Equal As Strings    '${service_instantiation_request.status_code}'    '202'
