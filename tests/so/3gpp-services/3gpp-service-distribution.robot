*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
${SLEEP_INTERVAL_SEC}=   30
${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}=     48     # Represents the maximum number of attempts that will be made before a timeout. It sleeps for SLEEP_INTERVAL_SEC seconds before retry.

*** Test Cases ***
Distribute TnNetworkReq_T Template
    Create Session   sdc_controller_session  http://${REPO_IP}:8085
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}distributeTN_Network_Req_T.json
    &{headers}=  Create Dictionary    Authorization=Basic bXNvX2FkbWluOnBhc3N3b3JkMSQ=    resource-location=/distribution-test-zip/unzipped/    Content-Type=application/json    Accept=application/json
    ${resp}=    POST On Session    sdc_controller_session    /test/treatNotification/v1    data=${data}    headers=${headers}
    Log To Console     Received status code: ${resp.status_code}
    Should Be Equal As Strings    '${resp.status_code}'    '200'

Distribute TnFhNsst Template
    Create Session   sdc_controller_session  http://${REPO_IP}:8085
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}distributeServiceTnFhNsst-csar.json
    &{headers}=  Create Dictionary    Authorization=Basic bXNvX2FkbWluOnBhc3N3b3JkMSQ=    resource-location=/distribution-test-zip/unzipped/    Content-Type=application/json    Accept=application/json
    ${resp}=    POST On Session    sdc_controller_session    /test/treatNotification/v1    data=${data}    headers=${headers}
    Log To Console     Received status code: ${resp.status_code}
    Should Be Equal As Strings    '${resp.status_code}'    '200'

Distribute TnMhNsst Template
    Create Session   sdc_controller_session  http://${REPO_IP}:8085
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}distributeServiceTnMhNsst-csar.json
    &{headers}=  Create Dictionary    Authorization=Basic bXNvX2FkbWluOnBhc3N3b3JkMSQ=    resource-location=/distribution-test-zip/unzipped/    Content-Type=application/json    Accept=application/json
    ${resp}=    POST On Session    sdc_controller_session    /test/treatNotification/v1    data=${data}    headers=${headers}
    Log To Console     Received status code: ${resp.status_code}
    Should Be Equal As Strings    '${resp.status_code}'    '200'
Distribute RanNfNsst_csar Template
    Create Session   sdc_controller_session  http://${REPO_IP}:8085
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}distributeServiceRanNfNsst-csar.json
    &{headers}=  Create Dictionary    Authorization=Basic bXNvX2FkbWluOnBhc3N3b3JkMSQ=    resource-location=/distribution-test-zip/unzipped/    Content-Type=application/json    Accept=application/json
    ${resp}=    POST On Session    sdc_controller_session    /test/treatNotification/v1    data=${data}    headers=${headers}
    Log To Console     Received status code: ${resp.status_code}
    Should Be Equal As Strings    '${resp.status_code}'    '200'

Distribute Testrantopnsst Template
    Create Session   sdc_controller_session  http://${REPO_IP}:8085
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}distributeService-Testrantopnsst-csar.json
    &{headers}=  Create Dictionary    Authorization=Basic bXNvX2FkbWluOnBhc3N3b3JkMSQ=    resource-location=/distribution-test-zip/unzipped/    Content-Type=application/json    Accept=application/json
    ${resp}=    POST On Session    sdc_controller_session    /test/treatNotification/v1    data=${data}    headers=${headers}
    Log To Console     Received status code: ${resp.status_code}
    Should Be Equal As Strings    '${resp.status_code}'    '200'


