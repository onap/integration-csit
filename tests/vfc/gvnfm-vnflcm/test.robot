*** settings ***
Resource    ../../common.robot
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     HttpLibrary.HTTP

*** Variables ***
@{return_ok_list}=   200  201  202  204
${queryswagger_url}    /api/vnflcm/v1/swagger.json
${query_vnfs_url}    /api/vnflcm/v1/vnf_instances
${healthcheck_url}   /api/vnflcm/v1/health_check

#json files
${create_vnf_json}    ${SCRIPTS}/../tests/vfc/gvnfm-vnflcm/jsoninput/create_vnf.json

#global variables
${vnfInstId}

*** Test Cases ***
VnflcmSwaggerTest
    [Documentation]    query swagger info vnflcm by MSB
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${VNFLCM_IP}:8801    headers=${headers}
    ${resp}=  Get Request    web_session    ${queryswagger_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${swagger_version}=    Convert To String      ${response_json['swagger']}
    Should Be Equal    ${swagger_version}    2.0

VnflcmHealthCheckTest
    [Documentation]    check health for vnflcm by MSB
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${VNFLCM_IP}:8801    headers=${headers}
    ${resp}=  Get Request    web_session    ${healthcheck_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${health_status}=    Convert To String      ${response_json['status']}
    Should Be Equal    ${health_status}    active

VnflcmQueryVnfsTest
    [Documentation]    check health for vnflcm by MSB
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${VNFLCM_IP}:8801    headers=${headers}
    ${resp}=  Get Request    web_session    ${query_vnfs_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
