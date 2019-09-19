*** settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
@{return_ok_list}=         200  201  202
${queryswagger_url}        /api/catalog/v1/swagger.json
${queryVNFPackage_url}     /api/catalog/v1/vnfpackages
${queryNSPackages_url}     /api/catalog/v1/nspackages
${healthcheck_url}         /api/catalog/v1/health_check

*** Test Cases ***
GetVNFPackages
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${EtsiCatalog_IP}:8806             headers=${headers}
    ${resp}=              Get Request          web_session                      ${queryVNFPackage_url}
    ${responese_code}=    Convert To String    ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

HealthCheckTest
    [Documentation]    check health for catalog by MSB
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${EtsiCatalog_IP}:8806    headers=${headers}
    ${resp}=  Get Request    web_session    ${healthcheck_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${health_status}=    Convert To String      ${response_json['status']}
    Should Be Equal    ${health_status}    active
