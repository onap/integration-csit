*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
${SLEEP_INTERVAL_SEC}=   5
${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}=     48     # Represents the maximum number of attempts that will be made before a timeout. It sleeps for SLEEP_INTERVAL_SEC seconds before retry.

*** Test Cases ***
Invoke VNF Instantiation
    Create Session    ve-vnfm-adapter-session    http://${REPO_IP}:9098
    ${data}=    Get Binary File    ${CURDIR}${/}data${/}notification.json
    &{headers}=    Create Dictionary    Content-Type=application/json    Accept=application/json    Authorization=Basic YWRtaW46YTRiM2MyZDE=
    ${notification_request}=    Post Request    ve-vnfm-adapter-session    /lcm/v1/vnf/instances/notifications    data=${data}    headers=${headers}
    Log To Console    ${notification_request}
    Run Keyword If    '${notification_request.status_code}' == '200'    Log To Console    \nexecuted with expected result
    Should Be Equal As Strings    '${notification_request.status_code}'    '200'
