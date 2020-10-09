*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
${SLEEP_INTERVAL_SEC}=   5
${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}=     48     # Represents the maximum number of attempts that will be made before a timeout. It sleeps for SLEEP_INTERVAL_SEC seconds before retry.

*** Test Cases ***
Distribute Service Template
    Create Session   sdc_controller_session  http://${REPO_IP}:8085
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}distributeServiceTemplate.json
    &{headers}=  Create Dictionary    Authorization=Basic bXNvX2FkbWluOnBhc3N3b3JkMSQ=    resource-location=/distribution-test-zip/unzipped/    Content-Type=application/json    Accept=application/json
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
    ${service_instantiation_json_response}=    Evaluate     json.loads(r"""${service_instantiation_request.content}""", strict=False)    json
    ${request_ID}=          Set Variable         ${service_instantiation_json_response}[requestReferences][requestId]
    ${service_instance_Id}=     Set Variable       ${service_instantiation_json_response}[requestReferences][instanceId]
    SET GLOBAL VARIABLE       ${service_instance_Id}
    ${actual_request_state}=    Set Variable    ""

    FOR    ${INDEX}    IN RANGE    ${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}
       ${orchestration_status_request}=   Get Request  api_handler_session   /onap/so/infra/orchestrationRequests/v7/${request_ID}
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

Invoke VNF Instantiation
    Run Keyword If      "${service_instance_Id}"!="${EMPTY}"      Log to Console    Service Instance ID :${service_instance_Id} received
    ...                ELSE      Fail           Log to Console  Invalid Service Instance ID :${service_instance_Id} recieved

    Create Session   api_handler_session  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}vnfInstantiationRequest.json
    ${vnf_instantiate_request_json}=    evaluate    json.loads(r'''${data}''', strict=False)    json
    set to dictionary    ${vnf_instantiate_request_json}[requestDetails][relatedInstanceList][0][relatedInstance]        instanceId=${service_instance_Id}
    ${vnf_instantiate_request_string}=    evaluate    json.dumps(${vnf_instantiate_request_json})    json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${vnf_instantiate_request}=    Post Request    api_handler_session    /onap/so/infra/serviceInstantiation/v7/serviceInstances/${service_instance_Id}/vnfs   data=${vnf_instantiate_request_string}    headers=${headers}
    Run Keyword If  '${vnf_instantiate_request.status_code}' == '200'  log to console   \nexecuted with expected result
    ${vnf_instantiate_json_response}=    Evaluate     json.loads(r"""${vnf_instantiate_request.content}""")    json
    ${request_ID}=          Set Variable         ${vnf_instantiate_json_response}[requestReferences][requestId]
    ${actual_request_state}=    SET VARIABLE    ""
    ${vnf_instance_Id}=     Set Variable       ${vnf_instantiate_json_response}[requestReferences][instanceId]
    SET GLOBAL VARIABLE       ${vnf_instance_Id}

    FOR    ${INDEX}    IN RANGE    ${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}
       ${orchestration_status_request}=   Get Request  api_handler_session   /onap/so/infra/orchestrationRequests/v7/${request_ID}
       Run Keyword If  '${orchestration_status_request.status_code}' == '200'  log to console   \nexecuted with expected result
       Log To Console      ${orchestration_status_request.content}
       ${orchestration_json_response}=    Evaluate     json.loads(r"""${orchestration_status_request.content}""", strict=False)    json
       ${actual_request_state}=     SET VARIABLE       ${orchestration_json_response}[request][requestStatus][requestState]
       RUN KEYWORD IF   '${actual_request_state}' == 'COMPLETE' or '${actual_request_state}' == 'FAILED'      Exit For Loop
       Log To Console  Will try again after ${SLEEP_INTERVAL_SEC} seconds
       SLEEP   ${SLEEP_INTERVAL_SEC}s
    END

    ${service_instance_Id}=     SET VARIABLE       ${orchestration_json_response}[request][instanceReferences][serviceInstanceId]
    Log To Console     final repsonse status received: ${actual_request_state}
    Run Keyword If  '${actual_request_state}' == 'COMPLETE'  log to console   \nexecuted with expected result
    Should Be Equal As Strings    '${actual_request_state}'    'COMPLETE'

Invoke VNF Notification for SOL002
    Create Session    ve-vnfm-adapter-session    http://${REPO_IP}:9098
    ${data}=    Get Binary File    ${CURDIR}${/}data${/}notification.json
    &{headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json    Authorization=Basic YWRtaW46YTRiM2MyZDE=
    ${notification_request}=    Post Request    ve-vnfm-adapter-session    /lcm/v1/vnf/instances/notifications    data=${data}    headers=${headers}
    Log To Console    ${notification_request}
    Run Keyword If    '${notification_request.status_code}' == '200'    Log To Console    \nexecuted with expected result
    Should Be Equal As Strings    '${notification_request.status_code}'    '200'

Delete VNF Instance
    Run Keyword If      "${vnf_instance_Id}" != "${EMPTY}"      Log to Console    VNF Instance ID :${vnf_instance_Id} received
    ...                ELSE      Fail           Log to Console  Invalid VNF Instance ID :${vnf_instance_Id} recieved
    Run Keyword If      "${service_instance_Id}" != "${EMPTY}"      Log to Console    VNF Instance ID :${service_instance_Id} received
    ...                ELSE      Fail           Log to Console  Invalid VNF Instance ID :${service_instance_Id} recieved

    Create Session   api_handler_session  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}vnfDeleteRequest.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${vnf_delete_request}=    Delete Request    api_handler_session    /onap/so/infra/serviceInstantiation/v7/serviceInstances/${service_instance_Id}/vnfs/${vnf_instance_Id}     data=${data}     headers=${headers}
    ${vnf_delete_json_response}=    Evaluate     json.loads(r"""${vnf_delete_request.content}""")    json
    Log to Console      ${vnf_delete_json_response}
    ${request_ID}=          Set Variable         ${vnf_delete_json_response}[requestReferences][requestId]
    ${actual_request_state}=    Set Variable    ""

    FOR    ${INDEX}    IN RANGE    ${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}
       ${orchestration_status_request}=   Get Request  api_handler_session   /onap/so/infra/orchestrationRequests/v7/${request_ID}
       Run Keyword If  '${orchestration_status_request.status_code}' == '200'  log to console   \nexecuted with expected result
       Log To Console      ${orchestration_status_request.content}
       ${orchestration_json_response}=    Evaluate     json.loads(r"""${orchestration_status_request.content}""")    json
       ${actual_request_state}=     SET VARIABLE       ${orchestration_json_response}[request][requestStatus][requestState]
       RUN KEYWORD IF   '${actual_request_state}' == 'COMPLETE' or '${actual_request_state}' == 'FAILED'      Exit For Loop
       Log To Console  Will try again after ${SLEEP_INTERVAL_SEC} seconds
       SLEEP   ${SLEEP_INTERVAL_SEC}s
    END

    Log To Console     final repsonse status received: ${actual_request_state}
    Run Keyword If  '${actual_request_state}' == 'COMPLETE'  log to console   \nexecuted with expected result
    Should Be Equal As Strings    '${actual_request_state}'    'COMPLETE'


Delete Service Instance
    Run Keyword If      "${service_instance_Id}" != "${EMPTY}"      Log to Console    VNF Instance ID :${service_instance_Id} received
    ...                ELSE      Fail           Log to Console  Invalid Service Instance ID :${service_instance_Id} recieved

    Create Session   api_handler_session  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}serviceDeleteRequest.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${service_delete_request}=    Delete Request    api_handler_session    /onap/so/infra/serviceInstantiation/v7/serviceInstances/${service_instance_Id}     data=${data}     headers=${headers}
    ${service_delete_json_response}=    Evaluate     json.loads(r"""${service_delete_request.content}""")    json
    Log to Console      ${service_delete_json_response}
    ${request_ID}=          Set Variable         ${service_delete_json_response}[requestReferences][requestId]
    ${actual_request_state}=    Set Variable    ""

    FOR    ${INDEX}    IN RANGE    ${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}
       ${orchestration_status_request}=   Get Request  api_handler_session   /onap/so/infra/orchestrationRequests/v7/${request_ID}
       Run Keyword If  '${orchestration_status_request.status_code}' == '200'  log to console   \nexecuted with expected result
       Log To Console      ${orchestration_status_request.content}
       ${orchestration_json_response}=    Evaluate     json.loads(r"""${orchestration_status_request.content}""")    json
       ${actual_request_state}=     SET VARIABLE       ${orchestration_json_response}[request][requestStatus][requestState]
       RUN KEYWORD IF   '${actual_request_state}' == 'COMPLETE' or '${actual_request_state}' == 'FAILED'      Exit For Loop
       Log To Console  Will try again after ${SLEEP_INTERVAL_SEC} seconds
       SLEEP   ${SLEEP_INTERVAL_SEC}s
    END

    Log To Console     final repsonse status received: ${actual_request_state}
    Run Keyword If  '${actual_request_state}' == 'COMPLETE'  log to console   \nexecuted with expected result
    Should Be Equal As Strings    '${actual_request_state}'    'COMPLETE'
