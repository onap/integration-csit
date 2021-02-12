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

