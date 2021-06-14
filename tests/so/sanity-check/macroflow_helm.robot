*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
${SLEEP_INTERVAL_SEC}=   30
${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}=     48     # Represents the maximum number of attempts that will be made before a timeout. It sleeps for SLEEP_INTERVAL_SEC seconds before retry.

*** Test Cases ***
Distribute Service Template
    Create Session   sdc_controller_session  http://${REPO_IP}:8085
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}serviceBasicVfCnfWithHelm.json
    &{headers}=  Create Dictionary    Authorization=Basic bXNvX2FkbWluOnBhc3N3b3JkMSQ=    resource-location=/distribution-test-zip/unzipped/    Content-Type=application/json    Accept=application/json
    ${resp}=    POST On Session    sdc_controller_session    /test/treatNotification/v1    data=${data}    headers=${headers}
    Log To Console     Received status code: ${resp.status_code}
    Should Be Equal As Strings    '${resp.status_code}'    '200'


Macroflow
    Create Session   api_handler_session  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}MacroflowWithHelm.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${service_instantiation_request}=    POST On Session    api_handler_session    /onap/so/infra/serviceInstantiation/v7/serviceInstances    data=${data}    headers=${headers}
    Log To Console     Received status code: ${service_instantiation_request.status_code}
    ${service_instantiation_json_response}=    Evaluate     json.loads(r"""${service_instantiation_request.content}""", strict=False)    json
    ${request_ID}=          Set Variable         ${service_instantiation_json_response}[requestReferences][requestId]
    ${actual_request_state}=    Set Variable    ""

    FOR    ${INDEX}    IN RANGE    ${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}
       ${orchestration_status_request}=   Get On Session  api_handler_session   /onap/so/infra/orchestrationRequests/v7/${request_ID}
       Run Keyword If  '${orchestration_status_request.status_code}' == '200'  log to console   \nexecuted with expected result
       log to console      ${orchestration_status_request.content}
       ${orchestration_json_response}=    Evaluate     json.loads(r"""${orchestration_status_request.content}""", strict=False)    json
       ${actual_request_state}=     SET VARIABLE       ${orchestration_json_response}[request][requestStatus][requestState]
       Log To Console    Received actual repsonse status:${actual_request_state}
       RUN KEYWORD IF   '${actual_request_state}' == 'COMPLETE' or '${actual_request_state}' == 'FAILED'      Exit For Loop
       log to console  Will try again after ${SLEEP_INTERVAL_SEC} seconds
       SLEEP   ${SLEEP_INTERVAL_SEC}s
    END

    Log To Console     final repsonse status received: ${actual_request_state}
    Run Keyword If  '${actual_request_state}' == 'COMPLETE'  log to console   \nexecuted with expected result
    Should Be Equal As Strings    '${actual_request_state}'    'COMPLETE'
