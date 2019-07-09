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
${subscriptions_url}         /api/vnfpkgm/v1/subscriptions

#json files
${vnf_subscription_json}    ${SCRIPTS}/../tests/vfc/nfvo-catalog/jsons/vnf_subscription.json

#global variables
${subscriptionId}

*** Test Cases ***
Create new VNF Package subscription for pre-condition
    Log    Create new VNF Package subscription for pre-condition
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

GET Individual VNF Package Subscription
    Log    GET Individual VNF Package Subscription
    [Documentation]    The objective is to test the retrieval of individual VNF package subscription
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Get Request          web_session     ${subscriptions_url}/${subscriptionId}
    Should Be Equal As Strings    200    ${resp.status_code}
    ${response_json}    json.loads    ${resp.content}
    ${callback_uri}=    Convert To String      ${response_json['callbackUri']}
    Should Be Equal    ${callback_uri}    http://127.0.0.1:${catalog_port}/api/catalog/v1/callback_sample
    Should Be Equal As Strings    ${subscriptionId}    ${response_json['id']}

POST Individual VNF Package Subscription - Method not implemented
    Log    POST Individual VNF Package Subscription - Method not implemented
    [Documentation]    The objective is to test that POST method is not allowed to create a new VNF Package Subscription
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Post Request          web_session     ${subscriptions_url}/${subscriptionId}
    Should Be Equal As Strings    405    ${resp.status_code}

PUT Individual VNF Package Subscription - Method not implemented
    Log    PUT Individual VNF Package Subscription - Method not implemented
    [Documentation]    The objective is to test that PUT method is not allowed to update an existing VNF Package subscription
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Put Request          web_session     ${subscriptions_url}/${subscriptionId}
    Should Be Equal As Strings    405    ${resp.status_code}

PATCH Individual VNF Package Subscription - Method not implemented
    Log    PATCH Individual VNF Package Subscription - Method not implemented
    [Documentation]    The objective is to test that PATCH method is not allowed to modify an existing VNF Package subscription
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Patch Request          web_session     ${subscriptions_url}/${subscriptionId}
    Should Be Equal As Strings    405    ${resp.status_code}

DELETE Individual VNF Package Subscription
    Log   DELETE Individual VNF Package Subscription
    [Documentation]    The objective is to test the deletion of an individual VNF package subscription
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${CATALOG_IP}:${catalog_port}    headers=${headers}
    ${resp}=    Delete Request    web_session     ${subscriptions_url}/${subscriptionId}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
