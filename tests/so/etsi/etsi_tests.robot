*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***


*** Test Cases ***
Distribute Service Template
    Create Session   sdc_controller_session  http://${REPO_IP}:8085
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}distributeServiceTemplate.json
    &{headers}=  Create Dictionary    Authorization=Basic bXNvX2FkbWluOnBhc3N3b3JkMSQ=    resource-location=/distribution-test-zip/unzipped     Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    sdc_controller_session    /test/treatNotification/v1    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '200'  log to console  \nexecuted with expected result
    Should Be Equal As Strings    '${resp.status_code}'    '200'

Invoke Service Instantiation
    Create Session   api_handler_session  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}serviceInstantiationRequest.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${service_instantiation_request}=    Post Request    api_handler_session    /onap/so/infra/serviceInstantiation/v7/serviceInstances    data=${data}    headers=${headers}
    Run Keyword If  '${service_instantiation_request.status_code}' == '200'  log to console   \nexecuted with expected result
    log to console      ${service_instantiation_request.content}
    ${service_instantiation_json_responce}=    Evaluate     json.loads("""${service_instantiation_request.content}""")    json

    ${actual_request_state}=    SET VARIABLE    ""

    : FOR    ${INDEX}    IN RANGE    48
    \   ${orchestration_status_request}=   Get Request  api_handler_session   /onap/so/infra/orchestrationRequests/v7/${service_instantiation_json_responce}[requestReferences][requestId]
    \   Run Keyword If  '${orchestration_status_request.status_code}' == '200'  log to console   \nexecuted with expected result
    \   log to console      ${orchestration_status_request.content}
    \   ${orchestration_json_responce}=    Evaluate     json.loads("""${orchestration_status_request.content}""")    json
    \   ${actual_request_state}=     SET VARIABLE       ${orchestration_json_responce}[request][requestStatus][requestState]
    \   Log To Console    Received actual repsonse status:${actual_request_state}
    \   RUN KEYWORD IF   '${actual_request_state}' == 'COMPLETE' or '${actual_request_state}' == 'FAILED'      Exit For Loop
    \   log to console  Will try again after 5 seconds
    \   SLEEP   5s
    Log To Console     final repsonse status received: ${actual_request_state}
    Run Keyword If  '${actual_request_state}' == 'COMPLETE'  log to console   \nexecuted with expected result
    Should Be Equal As Strings    '${actual_request_state}'    'COMPLETE'
