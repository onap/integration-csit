*** Settings ***
Resource    ../../common.robot
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
@{return_ok_list}=         200  201  202  204
${vnflcm_port}            8801
${subscriptions_url}         /api/vnflcm/v1/subscriptions

#json files
${vnf_subscription_json}    ${SCRIPTS}/../tests/vfc/gvnfm-vnflcm/jsoninput/vnf_subscription.json

#global variables
${subscriptionId}

*** Test Cases ***
Create new VNF Package subscription
    Log    Create new VNF Package subscription
    [Documentation]    The objective is to test the creation of a new VNF package subscription
    ${data}=    Get Binary File     ${vnf_subscription_json}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${VNFLCM_IP}:${vnflcm_port}    headers=${headers}
    ${resp}=    POST On Session    web_session    ${subscriptions_url}   data=${data}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${callback_uri}=    Convert To String      ${response_json['callbackUri']}
    Should Be Equal    ${callback_uri}    http://127.0.0.1:${vnflcm_port}/api/vnflcm/v1/callback_sample
    ${subscriptionId}=    Convert To String      ${response_json['id']}
    Set Global Variable     ${subscriptionId}

Create duplicated VNF Package subscription
    Log    Create duplicated VNF Package subscription
    [Documentation]    The objective is to test the attempt of a creation of a duplicated VNF package subscription
    ${data}=    Get Binary File     ${vnf_subscription_json}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${VNFLCM_IP}:${vnflcm_port}    headers=${headers}
    ${resp}=    POST On Session    web_session    ${subscriptions_url}   data=${data}    expected_status=any
    Should Be Equal As Strings    502    ${resp.status_code}

GET All VNF Package Subscriptions
    Log    GET All VNF Package Subscriptions
    [Documentation]    The objective is to test the retrieval of all VNF package subscriptions
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${VNFLCM_IP}:${vnflcm_port}      headers=${headers}
    ${resp}=   GET On Session    web_session    ${subscriptions_url}
    Should Be Equal As Strings    200    ${resp.status_code}

PUT VNF Package Subscriptions - Method not implemented
    Log    PUT VNF Package Subscriptions - Method not implemented
    [Documentation]    The objective is to test that PUT method is not allowed to modify VNF package subscriptions
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${VNFLCM_IP}:${vnflcm_port}      headers=${headers}
    ${resp}=    Put On Session    web_session    ${subscriptions_url}    expected_status=any
    Should Be Equal As Strings    405    ${resp.status_code}

PATCH VNF Package Subscriptions - Method not implemented
    Log    PATCH VNF Package Subscriptions - Method not implemented
    [Documentation]    The objective is to test that PATCH method is not allowed to update VNF package subscriptions
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${VNFLCM_IP}:${vnflcm_port}      headers=${headers}
    ${resp}=    Patch On Session    web_session    ${subscriptions_url}    expected_status=any
    Should Be Equal As Strings    405    ${resp.status_code}

DELETE VNF Package Subscriptions - Method not implemented
    Log    DELETE VNF Package Subscriptions - Method not implemented
    [Documentation]    The objective is to test that DELETE method is not allowed to delete VNF package subscriptions
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${VNFLCM_IP}:${vnflcm_port}      headers=${headers}
    ${resp}=    Delete On Session    web_session    ${subscriptions_url}    expected_status=any
    Should Be Equal As Strings    405    ${resp.status_code}

DELETE VNF Package Subscription
    Log   DELETE VNF Package Subscription
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${VNFLCM_IP}:${vnflcm_port}    headers=${headers}
    ${resp}=    Delete On Session    web_session    ${subscriptions_url}/${subscriptionId}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}