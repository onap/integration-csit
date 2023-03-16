*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     libraries/KubernetesClient.py

Documentation    Test cases for CNF lifecycle management operations
...              Note, relies on:
...                -package being onboarded in cnf_package_onboarding_tests

*** Variables ***
${SLEEP_INTERVAL_SEC}=                     10
${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}=        60     # Represents the maximum number of attempts that will be made before a timeout. It sleeps for SLEEP_INTERVAL_SEC seconds before retry.
${BASIC_AUTH}=                             Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==
${SERVICE_INSTANTIATION_TEMPLATE}=         ${CURDIR}${/}data${/}serviceInstantiationRequest.json
${CNF_RESOURCE_INSTANTIATION_TEMPLATE}=    ${CURDIR}${/}data${/}cnfResourceInstantiationRequest.json
${CNF_RESOURCE_DELETE_TEMPLATE}=           ${CURDIR}${/}data${/}cnfResourceDeleteRequest.json
${SERVICE_DELETE_TEMPLATE}=                ${CURDIR}${/}data${/}serviceDeleteRequest.json

${LABEL_NAME}=                                       app.kubernetes.io/instance
${MARIADB_LABEL_SELECTOR}=                           ${LABEL_NAME}=democnfinstance-mariadb-db-1
${EXPECTED_NUM_OF_RESOURCES_AFTER_INSTANTIATION}=    1

${NGINX_LABEL_SELECTOR}=                             ${LABEL_NAME}=democnfinstance-nginx-services-2
${EXPECTED_NUM_OF_RESOURCES_AFTER_DELETE}=           0


*** Test Cases ***
Invoke Service Instantiation
    Create Session   api_handler_session  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${SERVICE_INSTANTIATION_TEMPLATE}
    &{headers}=  Create Dictionary    Authorization=${BASIC_AUTH}    Content-Type=application/json    Accept=application/json
    ${service_instantiation_request}=    Post On Session    api_handler_session    /onap/so/infra/serviceInstantiation/v7/serviceInstances    data=${data}    headers=${headers}
    Log to Console      \nStatus code received: ${service_instantiation_request.status_code}
    Log to Console      Content received: ${service_instantiation_request.content}
    Should Be Equal As Strings    '${service_instantiation_request.status_code}'    '202'

    ${service_instantiation_json_response}=    Evaluate     json.loads(r"""${service_instantiation_request.content}""", strict=False)    json
    ${request_ID}=          Set Variable         ${service_instantiation_json_response}[requestReferences][requestId]
    ${service_instance_Id}=     Set Variable       ${service_instantiation_json_response}[requestReferences][instanceId]
    ${actual_request_state}=    Set Variable    ""

    FOR    ${INDEX}    IN RANGE    ${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}
       ${orchestration_status_request}=   Get On Session  api_handler_session   /onap/so/infra/orchestrationRequests/v7/${request_ID}
       Log to Console      Orchestration status code received: ${orchestration_status_request.status_code}
       Log to Console      Orchestration Content received: ${orchestration_status_request.content}
       ${orchestration_json_response}=    Evaluate     json.loads(r"""${orchestration_status_request.content}""", strict=False)    json
       ${actual_request_state}=     Set Variable       ${orchestration_json_response}[request][requestStatus][requestState]
       Log To Console    Received actual repsonse status:${actual_request_state}
       Run Keyword If   '${actual_request_state}' == 'COMPLETE' or '${actual_request_state}' == 'FAILED'      Exit For Loop
       Log to Console  Will try again after ${SLEEP_INTERVAL_SEC} seconds
       Sleep   ${SLEEP_INTERVAL_SEC}s
    END

    Log To Console     Final repsonse status received: ${actual_request_state}
    Should Be Equal As Strings    '${actual_request_state}'    'COMPLETE'
    Set Global Variable       ${service_instance_Id}

Invoke CNF Instantiation
    Run Keyword If      "${service_instance_Id}"!="${EMPTY}"      Log to Console    Service Instance ID :${service_instance_Id} received
    ...                ELSE      Fail           Log to Console  Invalid Service Instance ID :${service_instance_Id} recieved

    ${data}=    Get Binary File     ${CNF_RESOURCE_INSTANTIATION_TEMPLATE}
    ${cnf_instantiate_request_json}=    Evaluate    json.loads(r'''${data}''', strict=False)    json
    Set To Dictionary    ${cnf_instantiate_request_json}[requestDetails][relatedInstanceList][0][relatedInstance]        instanceId=${service_instance_Id}
    ${cnf_instantiate_request_string}=    Evaluate    json.dumps(${cnf_instantiate_request_json})    json

    Create Session   api_handler_session  http://${REPO_IP}:8080
    &{headers}=  Create Dictionary    Authorization=${BASIC_AUTH}    Content-Type=application/json    Accept=application/json
    ${cnf_instantiate_request}=    Post On Session    api_handler_session    /onap/so/infra/serviceInstantiation/v7/serviceInstances/${service_instance_Id}/cnfs   data=${cnf_instantiate_request_string}    headers=${headers}
    Log to Console      \nStatus code received: ${cnf_instantiate_request.status_code}
    Log to Console      Content received: ${cnf_instantiate_request.content}
    Should Be Equal As Strings    '${cnf_instantiate_request.status_code}'    '202'

    ${cnf_instantiate_json_response}=    Evaluate     json.loads(r"""${cnf_instantiate_request.content}""")    json
    ${request_ID}=          Set Variable         ${cnf_instantiate_json_response}[requestReferences][requestId]
    ${actual_request_state}=    Set Variable    ""
    ${cnf_instance_Id}=     Set Variable       ${cnf_instantiate_json_response}[requestReferences][instanceId]

    FOR    ${INDEX}    IN RANGE    ${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}
       ${orchestration_status_request}=   Get On Session  api_handler_session   /onap/so/infra/orchestrationRequests/v7/${request_ID}
       Run Keyword If  '${orchestration_status_request.status_code}' == '200'  log to console   \nexecuted with expected result
       Log To Console      ${orchestration_status_request.content}
       ${orchestration_json_response}=    Evaluate     json.loads(r"""${orchestration_status_request.content}""", strict=False)    json
       ${actual_request_state}=     Set Variable       ${orchestration_json_response}[request][requestStatus][requestState]
       Run Keyword If   '${actual_request_state}' == 'COMPLETE' or '${actual_request_state}' == 'FAILED'      Exit For Loop
       Log To Console  Will try again after ${SLEEP_INTERVAL_SEC} seconds
       SLEEP   ${SLEEP_INTERVAL_SEC}s
    END

    ${service_instance_Id}=     Set Variable       ${orchestration_json_response}[request][instanceReferences][serviceInstanceId]
    Log To Console     Final repsonse status received: ${actual_request_state}
    Should Be Equal As Strings    '${actual_request_state}'    'COMPLETE'

    Verify Kubernetes Resources    ${EXPECTED_NUM_OF_RESOURCES_AFTER_INSTANTIATION}
    Set Global Variable       ${cnf_instance_Id}

Invoke CNF Delete
    Run Keyword If      "${cnf_instance_Id}" != "${EMPTY}"      Log to Console    CNF Instance ID :${cnf_instance_Id} received
    ...                ELSE      Fail           Log to Console  Invalid CNF Instance ID :${cnf_instance_Id} recieved
    Run Keyword If      "${service_instance_Id}" != "${EMPTY}"      Log to Console    CNF Instance ID :${service_instance_Id} received
    ...                ELSE      Fail           Log to Console  Invalid CNF Instance ID :${service_instance_Id} recieved

    Create Session   api_handler_session  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CNF_RESOURCE_DELETE_TEMPLATE}
    &{headers}=  Create Dictionary    Authorization=${BASIC_AUTH}    Content-Type=application/json    Accept=application/json
    ${cnf_delete_request}=    Delete On Session    api_handler_session    /onap/so/infra/serviceInstantiation/v7/serviceInstances/${service_instance_Id}/cnfs/${cnf_instance_Id}     data=${data}     headers=${headers}
    Log to Console      \nStatus code received: ${cnf_delete_request.status_code}
    Log to Console      Content received: ${cnf_delete_request.content}
    Should Be Equal As Strings    '${cnf_delete_request.status_code}'    '202'

    ${cnf_delete_json_response}=    Evaluate     json.loads(r"""${cnf_delete_request.content}""")    json
    ${request_ID}=          Set Variable         ${cnf_delete_json_response}[requestReferences][requestId]
    ${actual_request_state}=    Set Variable    ""

    FOR    ${INDEX}    IN RANGE    ${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}
       ${orchestration_status_request}=   Get On Session  api_handler_session   /onap/so/infra/orchestrationRequests/v7/${request_ID}
       Run Keyword If  '${orchestration_status_request.status_code}' == '200'  log to console   \nexecuted with expected result
       Log To Console      ${orchestration_status_request.content}
       ${orchestration_json_response}=    Evaluate     json.loads(r"""${orchestration_status_request.content}""")    json
       ${actual_request_state}=     Set Variable       ${orchestration_json_response}[request][requestStatus][requestState]
       Run Keyword If   '${actual_request_state}' == 'COMPLETE' or '${actual_request_state}' == 'FAILED'      Exit For Loop
       Log To Console  Will try again after ${SLEEP_INTERVAL_SEC} seconds
       SLEEP   ${SLEEP_INTERVAL_SEC}s
    END

    Log To Console     Final repsonse status received: ${actual_request_state}
    Should Be Equal As Strings    '${actual_request_state}'    'COMPLETE'

    Verify Kubernetes Resources    ${EXPECTED_NUM_OF_RESOURCES_AFTER_DELETE}

Delete Service Instance
    Run Keyword If      "${service_instance_Id}" != "${EMPTY}"      Log to Console    CNF Instance ID :${service_instance_Id} received
    ...                ELSE      Fail           Log to Console  Invalid Service Instance ID :${service_instance_Id} recieved

    Create Session   api_handler_session  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${SERVICE_DELETE_TEMPLATE}
    &{headers}=  Create Dictionary    Authorization=${BASIC_AUTH}    Content-Type=application/json    Accept=application/json
    ${service_delete_request}=    Delete On Session    api_handler_session    /onap/so/infra/serviceInstantiation/v7/serviceInstances/${service_instance_Id}     data=${data}     headers=${headers}
    ${service_delete_json_response}=    Evaluate     json.loads(r"""${service_delete_request.content}""")    json
    Log to Console      \nStatus code received: ${service_delete_request.status_code}
    Log to Console      Content received: ${service_delete_request.content}
    Should Be Equal As Strings    '${service_delete_request.status_code}'    '202'

    ${request_ID}=          Set Variable         ${service_delete_json_response}[requestReferences][requestId]
    ${actual_request_state}=    Set Variable    ""

    FOR    ${INDEX}    IN RANGE    ${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}
       ${orchestration_status_request}=   Get On Session  api_handler_session   /onap/so/infra/orchestrationRequests/v7/${request_ID}
       Run Keyword If  '${orchestration_status_request.status_code}' == '200'  log to console   \nexecuted with expected result
       Log To Console      ${orchestration_status_request.content}
       ${orchestration_json_response}=    Evaluate     json.loads(r"""${orchestration_status_request.content}""")    json
       ${actual_request_state}=     Set Variable       ${orchestration_json_response}[request][requestStatus][requestState]
       Run Keyword If   '${actual_request_state}' == 'COMPLETE' or '${actual_request_state}' == 'FAILED'      Exit For Loop
       Log To Console  Will try again after ${SLEEP_INTERVAL_SEC} seconds
       SLEEP   ${SLEEP_INTERVAL_SEC}s
    END

    Log To Console     Final repsonse status received: ${actual_request_state}
    Should Be Equal As Strings    '${actual_request_state}'    'COMPLETE'

*** Keywords ***
Verify Kubernetes Resources
    [Arguments]    ${expected_number_resources}

    Create Api Client    ${KIND_CLUSTER_KUBE_CONFIG_FILE}

    Log To Console    Retrieving number of services using selector '${MARIADB_LABEL_SELECTOR}'
    ${no_of_mariadb_services}=    Get Number Of Services In Namespace    label_selector=${MARIADB_LABEL_SELECTOR}
    Should Be Equal As Integers      ${no_of_mariadb_services}    ${expected_number_resources}    Unexpected number of services received for ${MARIADB_LABEL_SELECTOR}

    Log To Console    Retrieving number of stateful set using selector '${MARIADB_LABEL_SELECTOR}'
    ${no_of_mariadb_stateful_set}=    Get Number Of Stateful Set In Namespace    label_selector=${MARIADB_LABEL_SELECTOR}
    Should Be Equal As Integers      ${no_of_mariadb_stateful_set}    ${expected_number_resources}    Unexpected number of stateful sets received for ${MARIADB_LABEL_SELECTOR}

    Log To Console    Retrieving number of services using selector '${NGINX_LABEL_SELECTOR}'
    ${no_of_nginx_services}=    Get Number Of Services In Namespace    label_selector=${NGINX_LABEL_SELECTOR}
    Should Be Equal As Integers      ${no_of_nginx_services}    ${expected_number_resources}    Unexpected number of services received for ${NGINX_LABEL_SELECTOR}

    Log To Console    Retrieving number of deployments using selector '${NGINX_LABEL_SELECTOR}'
    ${no_of_nginx_deployments}=    Get Number Of Deployments In Namespace    label_selector=${NGINX_LABEL_SELECTOR}
    Should Be Equal As Integers      ${no_of_nginx_deployments}    ${expected_number_resources}    Unexpected number of deployments received for ${NGINX_LABEL_SELECTOR}