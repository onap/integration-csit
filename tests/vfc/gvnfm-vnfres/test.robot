*** settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
@{return_ok_list}=   200  201  202
${queryswagger_url}    /api/vnfres/v1/swagger.json
${healthcheck_url}   /api/vnfres/v1/health_check

*** Test Cases ***
VnfresSwaggerTest
    [Documentation]    query vnfres swagger info rest test
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${VNFRES_IP}:8802    headers=${headers}
    ${resp}=  GET On Session    web_session    ${queryswagger_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${swagger_version}=    Convert To String      ${response_json['swagger']}
    Should Be Equal    ${swagger_version}    2.0

VnfResHealthCheckTest
    [Documentation]    check health for vnfres by MSB
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${VNFRES_IP}:8802    headers=${headers}
    ${resp}=  GET On Session    web_session    ${healthcheck_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${health_status}=    Convert To String      ${response_json['status']}
    Should Be Equal    ${health_status}    active
