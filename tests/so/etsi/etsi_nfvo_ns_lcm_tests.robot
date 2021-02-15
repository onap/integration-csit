*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     ArchiveLibrary

*** Variables ***
${SLEEP_INTERVAL_SEC}=   5
${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}=     48     # Represents the maximum number of attempts that will be made before a timeout. It sleeps for SLEEP_INTERVAL_SEC seconds before retry.
${NFVO_NS_LCM_BASE_URL}=    /so/so-etsi-nfvo-ns-lcm/v1/api/nslcm/v1
${BASIC_AUTH}=    Basic c28tZXRzaS1uZnZvLW5zLWxjbTpwYXNzd29yZDEk

*** Test Cases ***

Invoke Create Network Service
    Create Session   etsi_nfvo_ns_lcm_session  http://${REPO_IP}:9095
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}createNetworkServiceRequest.json
    &{headers}=  Create Dictionary    Authorization=${BASIC_AUTH}    Content-Type=application/json    Accept=application/json    HTTP_GLOBALCUSTOMERID=DemoCustomer
    ${create_network_service_request}=    POST On Session    etsi_nfvo_ns_lcm_session    ${NFVO_NS_LCM_BASE_URL}/ns_instances    data=${data}    headers=${headers}
    log to console      ${create_network_service_request.content}
    ${create_network_service_json_response}=    Evaluate     json.loads(r"""${create_network_service_request.content}""", strict=False)    json
    ${request_Id}=          Set Variable         ${create_network_service_json_response}[id]
    SET GLOBAL VARIABLE       ${request_Id}

    Run Keyword If  '${create_network_service_request.status_code}' == '201'  log to console  \nexecuted with expected result
    Should Be Equal As Strings    '${create_network_service_request.status_code}'    '201'

Invoke Instantiate Network Service
    Run Keyword If      "${request_Id}"!="${EMPTY}"      Log to Console    Network Service ID :${request_Id} received
    ...                ELSE      Fail           Log to Console  Network Service ID :${request_Id} recieved
    Create Session   etsi_nfvo_ns_lcm_session  http://${REPO_IP}:9095
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}instantiateNetworkServiceRequest.json
    &{headers}=  Create Dictionary    Authorization=${BASIC_AUTH}    Content-Type=application/json    Accept=application/json
    ${instantiate_network_service_request}=    POST On Session    etsi_nfvo_ns_lcm_session    ${NFVO_NS_LCM_BASE_URL}/ns_instances/${request_Id}/instantiate    data=${data}    headers=${headers}
    Run Keyword If  '${instantiate_network_service_request.status_code}' == '202'  log to console   \nexecuted with expected result
    log to console      ${instantiate_network_service_request.content}
    ${actual_request_state}=    Set Variable    ""

    FOR    ${INDEX}    IN RANGE    ${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}
       ${ns_lcm_status_request}=   GET On Session  etsi_nfvo_ns_lcm_session   ${NFVO_NS_LCM_BASE_URL}/ns_lcm_op_occs/${request_Id}
       Run Keyword If  '${ns_lcm_status_request.status_code}' == '200'  log to console   \nexecuted with expected result
       log to console      ${ns_lcm_status_request.content}
       ${ns_lcm_request_json_response}=    Evaluate     json.loads(r"""${ns_lcm_status_request.content}""", strict=False)    json
       ${actual_request_lcmOperationType}=     SET VARIABLE       ${ns_lcm_request_json_response}[lcmOperationType]
       ${actual_request_state}=     SET VARIABLE       ${ns_lcm_request_json_response}[operationState]
       Log To Console    Received actual response lcmOperationType:${actual_request_lcmOperationType}
       Log To Console    Received actual response status:${actual_request_state}
       RUN KEYWORD IF   '${actual_request_state}' == 'COMPLETED' or '${actual_request_state}' == 'FAILED'      Exit For Loop
       log to console  Will try again after ${SLEEP_INTERVAL_SEC} seconds
       SLEEP   ${SLEEP_INTERVAL_SEC}s
    END

    Log To Console     final response status received: ${actual_request_state}
    Run Keyword If  '${actual_request_state}' == 'COMPLETE'  log to console   \nexecuted with expected result
    Should Be Equal As Strings    '${actual_request_state}'    'COMPLETED'

Invoke Terminate Network Service
    Run Keyword If      "${request_Id}"!="${EMPTY}"      Log to Console    Network Service ID :${request_Id} received
    ...                ELSE      Fail           Log to Console  Invalid Network Service ID :${request_Id} recieved
    Create Session   etsi_nfvo_ns_lcm_session  http://${REPO_IP}:9095
    &{headers}=  Create Dictionary    Authorization=${BASIC_AUTH}    Content-Type=application/json    Accept=application/json
    ${terminate_network_service_request}=    POST On Session    etsi_nfvo_ns_lcm_session    ${NFVO_NS_LCM_BASE_URL}/ns_instances/${request_Id}/terminate    headers=${headers}
    Run Keyword If  '${terminate_network_service_request.status_code}' == '202'  log to console   \nexecuted with expected result
    log to console      ${terminate_network_service_request.content}
    ${actual_request_state}=    Set Variable    ""

    FOR    ${INDEX}    IN RANGE    ${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}
       ${ns_lcm_status_request}=   GET On Session  etsi_nfvo_ns_lcm_session   ${NFVO_NS_LCM_BASE_URL}/ns_lcm_op_occs/${request_Id}
       Run Keyword If  '${ns_lcm_status_request.status_code}' == '200'  log to console   \nexecuted with expected result
       log to console      ${ns_lcm_status_request.content}
       ${ns_lcm_request_json_response}=    Evaluate     json.loads(r"""${ns_lcm_status_request.content}""", strict=False)    json
       ${actual_request_lcmOperationType}=     SET VARIABLE       ${ns_lcm_request_json_response}[lcmOperationType]
       ${actual_request_state}=     SET VARIABLE       ${ns_lcm_request_json_response}[operationState]
       Log To Console    Received actual response lcmOperationType:${actual_request_lcmOperationType}
       Log To Console    Received actual response status:${actual_request_state}
       RUN KEYWORD IF   '${actual_request_state}' == 'COMPLETED' or '${actual_request_state}' == 'FAILED'      Exit For Loop
       log to console  Will try again after ${SLEEP_INTERVAL_SEC} seconds
       SLEEP   ${SLEEP_INTERVAL_SEC}s
    END

    Log To Console     final response status received: ${actual_request_state}
    Run Keyword If  '${actual_request_state}' == 'COMPLETE'  log to console   \nexecuted with expected result
    Should Be Equal As Strings    '${actual_request_state}'    'COMPLETED'

Invoke Delete Network Service
    Run Keyword If      "${request_Id}"!="${EMPTY}"      Log to Console    Network Service ID :${request_Id} received
    ...                ELSE      Fail           Log to Console  Invalid Network Service ID :${request_Id} recieved
    Create Session   etsi_nfvo_ns_lcm_session  http://${REPO_IP}:9095
    &{headers}=  Create Dictionary    Authorization=${BASIC_AUTH}    Content-Type=application/json    Accept=application/json
    ${delete_network_service_request}=    DELETE On Session    etsi_nfvo_ns_lcm_session    ${NFVO_NS_LCM_BASE_URL}/ns_instances/${request_Id}    headers=${headers}
    Log To Console     DELETE Request sent to /so/so-etsi-nfvo-ns-lcm/v1/api/nslcm/v1/ns_instances/${request_Id}
    Run Keyword If  '${delete_network_service_request.status_code}' == '204'  log to console   \nexecuted with expected result

    Log To Console     final response status received: ${delete_network_service_request.status_code}
    Should Be Equal As Strings    '${delete_network_service_request.status_code}'    '204'
