*** Settings ***
Resource    ../../common.robot
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     HttpLibrary.HTTP

*** Variables ***
@{return_ok_list}=         200  201  202  204
${catalog_port}            8806
${subscriptions_url}         /api/nsd/v1/subscriptions

#json files
${nsdm_subscription_json}    ${SCRIPTS}/../tests/vfc/nfvo-catalog/jsons/nsdm_subscription.json

#global variables
${subscriptionId}

*** Test Cases ***
Create new NSD management subscription
    Log    Create new NSD management subscription
    [Documentation]    The objective is to test the creation of a new NSD management subscription
    ${json_value}=     json_from_file      ${nsdm_subscription_json}
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

Create duplicated NSD management subscription
    Log    Create duplicated NSD management subscription
    [Documentation]    The objective is to test the attempt of a creation of a duplicated NSD management subscription
    ${json_value}=     json_from_file      ${nsdm_subscription_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${CATALOG_IP}:${catalog_port}    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${subscriptions_url}    ${json_string}
    Should Be Equal As Strings    303    ${resp.status_code}

GET All NSD management Subscriptions
    Log    GET All NSD management Subscriptions
    [Documentation]    The objective is to test the retrieval of all NSD management subscriptions
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Get Request          web_session     ${subscriptions_url}
    Should Be Equal As Strings    200    ${resp.status_code}

PUT NSD management Subscriptions - Method not implemented
    Log    PUT NSD management Subscriptions - Method not implemented
    [Documentation]    The objective is to test that PUT method is not allowed to modify NSD management subscriptions
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Put Request          web_session     ${subscriptions_url}
    Should Be Equal As Strings    405    ${resp.status_code}

PATCH NSD management Subscriptions - Method not implemented
    Log    PATCH NSD management Subscriptions - Method not implemented
    [Documentation]    The objective is to test that PATCH method is not allowed to update NSD management subscriptions
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Patch Request          web_session     ${subscriptions_url}
    Should Be Equal As Strings    405    ${resp.status_code}

DELETE NSD management Subscriptions - Method not implemented
    Log    DELETE NSD management Subscriptions - Method not implemented
    [Documentation]    The objective is to test that DELETE method is not allowed to delete NSD management subscriptions
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Delete Request          web_session     ${subscriptions_url}
    Should Be Equal As Strings    405    ${resp.status_code}

DELETE NSD management Subscription
    Log   DELETE NSD management Subscription
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${CATALOG_IP}:${catalog_port}    headers=${headers}
    ${resp}=    Delete Request    web_session     ${subscriptions_url}/${subscriptionId}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
