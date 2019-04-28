*** settings ***
Resource    ../../common.robot
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     HttpLibrary.HTTP

*** Variables ***
@{return_ok_list}=         200  201  202
${queryswagger_url}        /api/catalog/v1/swagger.json
${queryVNFPackage_url}     /api/catalog/v1/vnfpackages
${queryNSPackages_url}     /api/catalog/v1/nspackages
${healthcheck_url}         /api/catalog/v1/health_check
${create_subs_url}         /api/vnfpkgm/v1/subscriptions

#json files
${vnf_subscription_json}    ${SCRIPTS}/../tests/vfc/nfvo-catalog/jsons/vnf_subscription.json

*** Test Cases ***
GetVNFPackages
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:8806             headers=${headers}
    ${resp}=              Get Request          web_session                      ${queryVNFPackage_url}
    ${responese_code}=    Convert To String    ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

CatalogHealthCheckTest
    [Documentation]    check health for catalog by MSB
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${CATALOG_IP}:8806    headers=${headers}
    ${resp}=  Get Request    web_session    ${healthcheck_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${health_status}=    Convert To String      ${response_json['status']}
    Should Be Equal    ${health_status}    active

CreateVnfSubscriptionTest
    [Documentation]    Create Vnf Subscription function test
    ${json_value}=     json_from_file      ${vnf_subscription_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${CATALOG_IP}:8806    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${create_subs_url}    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${callback_uri}=    Convert To String      ${response_json['callbackUri']}
    Should Be Equal    ${callback_uri}    http://127.0.0.1:8806/api/catalog/v1/callback_sample
