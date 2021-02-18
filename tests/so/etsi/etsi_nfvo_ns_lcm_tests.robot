*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     ArchiveLibrary

*** Variables ***
${NFVO_NS_LCM_BASE_URL}=    /so/so-etsi-nfvo-ns-lcm/v1/api/nslcm/v1
${BASIC_AUTH}=    Basic c28tZXRzaS1uZnZvLW5zLWxjbTpwYXNzd29yZDEk

Documentation    Test cases for ETSI NFVO NS Lifecycle Management Operations
...    Create and Delete tests are synchronous
...    Instantiate and Terminate tests are asynchronous, test status checked through request to NS_LCM_OP_OCCs endpoint
...    Note, relies on:
...      -Network Service package being onboarded in etsi_package_onboarding_tests

*** Test Cases ***

Invoke Create Network Service
    Create Session   etsi_nfvo_ns_lcm_session  http://${REPO_IP}:9095
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}createNetworkServiceRequest.json
    &{headers}=  Create Dictionary    Authorization=${BASIC_AUTH}    Content-Type=application/json    Accept=application/json    HTTP_GLOBALCUSTOMERID=DemoCustomer
    ${create_network_service_request}=    POST On Session    etsi_nfvo_ns_lcm_session    ${NFVO_NS_LCM_BASE_URL}/ns_instances    data=${data}    headers=${headers}
    log to console    ${create_network_service_request.content}
    ${create_network_service_json_response}=    Evaluate    json.loads(r"""${create_network_service_request.content}""", strict=False)    json
    ${request_Id}=    Set Variable   ${create_network_service_json_response}[id]
    SET GLOBAL VARIABLE    ${request_Id}

    Should Be Equal As Strings    '${create_network_service_request.status_code}'    '201'

Invoke Instantiate Network Service
    Run Keyword If    "${request_Id}"!="${EMPTY}"   Log to Console    Network Service ID :${request_Id}
    ...    ELSE    Fail    \nInvalid Network Service ID :${request_Id} received
    Create Session   etsi_nfvo_ns_lcm_session  http://${REPO_IP}:9095
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}instantiateNetworkServiceRequest.json
    &{headers}=  Create Dictionary    Authorization=${BASIC_AUTH}    Content-Type=application/json    Accept=application/json
    ${instantiate_network_service_request}=    POST On Session    etsi_nfvo_ns_lcm_session    ${NFVO_NS_LCM_BASE_URL}/ns_instances/${request_Id}/instantiate    data=${data}    headers=${headers}
    Run Keyword If  '${instantiate_network_service_request.status_code}' == '202'  log to console   \nexecuted with expected result
    ...    ELSE    Fail    \nInstantiate Network Service Request Received Response: ${instantiate_network_service_request.status_code}
    log to console    \n${instantiate_network_service_request.content}

    Wait Until Keyword Succeeds    3 min    5 secs    Get NS LCM OP OCCs

Invoke Terminate Network Service
    Run Keyword If    "${actual_request_state}"=="COMPLETED"    Log to Console    NS LCM OP OCCs State: ${actual_request_state}
    ...    ELSE    Fail    \nTerminate Network Service Failed to Start. Instantiate Network Service Request State: ${actual_request_state}
    Create Session   etsi_nfvo_ns_lcm_session  http://${REPO_IP}:9095
    &{headers}=  Create Dictionary    Authorization=${BASIC_AUTH}    Content-Type=application/json    Accept=application/json
    ${terminate_network_service_request}=    POST On Session    etsi_nfvo_ns_lcm_session    ${NFVO_NS_LCM_BASE_URL}/ns_instances/${request_Id}/terminate    headers=${headers}
    Run Keyword If  '${terminate_network_service_request.status_code}' == '202'  log to console   \nexecuted with expected result
    ...    ELSE    Fail    \nTerminate Network Service Request Received Response: ${terminate_network_service_request.status_code}
    log to console    \n${terminate_network_service_request.content}

    Wait Until Keyword Succeeds    3 min    5 secs    Get NS LCM OP OCCs

Invoke Delete Network Service
    Run Keyword If    "${actual_request_state}"=="COMPLETED"    Log to Console    NS LCM OP OCCs State: ${actual_request_state}
    ...    ELSE    Fail    \nDelete Network Service Failed to Start. Invalid Previous Request State Received: ${actual_request_state}
    Create Session   etsi_nfvo_ns_lcm_session  http://${REPO_IP}:9095
    &{headers}=  Create Dictionary    Authorization=${BASIC_AUTH}    Content-Type=application/json    Accept=application/json
    ${delete_network_service_request}=    DELETE On Session    etsi_nfvo_ns_lcm_session    ${NFVO_NS_LCM_BASE_URL}/ns_instances/${request_Id}    headers=${headers}
    log to console    \n${delete_network_service_request.content}

    Should Be Equal As Strings    '${delete_network_service_request.status_code}'    '204'

*** Keywords ***

Get NS LCM OP OCCs
    ${ns_lcm_status_request}=   GET On Session  etsi_nfvo_ns_lcm_session   ${NFVO_NS_LCM_BASE_URL}/ns_lcm_op_occs/${request_Id}
    log to console      \n${ns_lcm_status_request.content}
    ${ns_lcm_request_json_response}=    Evaluate     json.loads(r"""${ns_lcm_status_request.content}""", strict=False)    json
    ${actual_request_state}=     SET VARIABLE       ${ns_lcm_request_json_response}[operationState]
    SET GLOBAL VARIABLE    ${actual_request_state}
    Should Be Equal As Strings    ${ns_lcm_status_request.status_code}    200
    Should Be Equal As Strings    ${actual_request_state}    COMPLETED
