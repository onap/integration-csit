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
Create new NSD management subscription for pre-condition
    Log    Create new NSD management subscription for pre-condition
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

GET Individual NSD management Subscription
    Log    GET Individual NSD management Subscription
    [Documentation]    The objective is to test the retrieval of individual VNF package subscription
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Get Request          web_session     ${subscriptions_url}/${subscriptionId}
    Should Be Equal As Strings    200    ${resp.status_code}
    ${response_json}    json.loads    ${resp.content}
    ${callback_uri}=    Convert To String      ${response_json['callbackUri']}
    Should Be Equal    ${callback_uri}    http://127.0.0.1:${catalog_port}/api/catalog/v1/callback_sample
    Should Be Equal As Strings    ${subscriptionId}    ${response_json['id']}

POST Individual NSD management Subscription - Method not implemented
    Log    POST Individual NSD management Subscription - Method not implemented
    [Documentation]    The objective is to test that POST method is not allowed to create a new NSD management Subscription
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Post Request          web_session     ${subscriptions_url}/${subscriptionId}
    Should Be Equal As Strings    405    ${resp.status_code}

PUT Individual NSD management Subscription - Method not implemented
    Log    PUT Individual NSD management Subscription - Method not implemented
    [Documentation]    The objective is to test that PUT method is not allowed to update an existing NSD management subscription
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Put Request          web_session     ${subscriptions_url}/${subscriptionId}
    Should Be Equal As Strings    405    ${resp.status_code}

PATCH Individual NSD management Subscription - Method not implemented
    Log    PATCH Individual NSD management Subscription - Method not implemented
    [Documentation]    The objective is to test that PATCH method is not allowed to modify an existing NSD management subscription
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Patch Request          web_session     ${subscriptions_url}/${subscriptionId}
    Should Be Equal As Strings    405    ${resp.status_code}

DELETE Individual NSD management Subscription
    Log   DELETE Individual NSD management Subscription
    [Documentation]    The objective is to test the deletion of an individual VNF package subscription
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${CATALOG_IP}:${catalog_port}    headers=${headers}
    ${resp}=    Delete Request    web_session     ${subscriptions_url}/${subscriptionId}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
