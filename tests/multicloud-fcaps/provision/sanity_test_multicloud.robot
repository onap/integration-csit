*** settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
@{return_ok_list}=   200  201  202
${querysample_fcaps_url}    /api/multicloud-fcaps/v0/samples

*** Test Cases ***
FcapsSampleTest
    [Documentation]    query sample info rest test
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${SERVICE_IP}:${SERVICE_PORT}    headers=${headers}
    ${resp}=  Get Request    web_session    ${querysample_fcaps_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${sample_status}=    Convert To String      ${response_json['status']}
    Should Be Equal    ${sample_status}    "active"
