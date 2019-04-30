*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
@{return_ok_list}=   200  201  202

*** Test Cases ***

Create ServiceInstance for vFW
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}createService.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    refrepo    /onap/so/infra/serviceInstances/v5    data=${data}    headers=${headers}
    ${response_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${response_code}

#Send request to OOF
#    Create Session   refrepo  http://${MOCK_IP}:1080
#    ${data}=    Get Binary File     ${CURDIR}${/}data${/}oofRequest.json
#    ${resp}=    Post Request    refrepo    /api/oof/v1/placement    data=${data}
#    Run Keyword If  '${resp.status_code}' == '200' or '${resp.status_code}' == '201' or '${resp.status_code}' == '202'  log to console  \nexecuted with expected result
#
#Send mock OOF response to SO
#    Create Session   refrepo  http://${REPO_IP}:8081
#    ${data}=    Get Binary File     ${CURDIR}${/}data${/}oofResponse.json
#    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
#    ${resp}=    Post Request    refrepo    /mso/WorkflowMessage/oofResponse/    data=${data}    headers=${headers}
#    Run Keyword If  '${resp.status_code}' == '200' or '${resp.status_code}' == '202'  log to console  \nexecuted with expected result
