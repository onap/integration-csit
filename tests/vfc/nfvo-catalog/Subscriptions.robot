*** Settings ***
Resource    ../../common.robot
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     HttpLibrary.HTTP

*** Variables ***
${catalog_port}            8806
${subscriptions_url}         /api/vnfpkgm/v1/subscriptions

#json files
${vnf_subscription_json}    ${SCRIPTS}/../tests/vfc/nfvo-catalog/jsons/vnf_subscription.json

#global variables
${subscriptionId}

*** Test Cases ***
POST Subscription
    Log    Trying to create a new subscription
    [Documentation]    Create Vnf Subscription function test
    ${json_value}=     json_from_file      ${vnf_subscription_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${CATALOG_IP}:${catalog_port}    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${subscriptions_url}    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${callback_uri}=    Convert To String      ${response_json['callbackUri']}
    Should Be Equal    ${callback_uri}    http://127.0.0.1:${catalog_port}/api/catalog/v1/callback_sample
    ${subscriptionId}=    Convert To String      ${response_json['id']}
    Set Global Variable     ${subscriptionId}

DeleteVnfSubscriptionTest
    [Documentation]    Delete Vnf Subscription function test
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${CATALOG_IP}:${catalog_port}    headers=${headers}
    ${resp}=    Delete Request    web_session     ${subscriptions_url}/${subscriptionId}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

