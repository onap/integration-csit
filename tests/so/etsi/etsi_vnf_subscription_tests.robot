*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
${SLEEP_INTERVAL_SEC}=   5
${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}=     48     # Represents the maximum number of attempts that will be made before a timeout. It sleeps for SLEEP_INTERVAL_SEC seconds before retry.
${PACKAGE_MANAGEMENT_BASE_URL}=    /so/vnfm-adapter/v1/vnfpkgm/v1
${BASIC_AUTH}=    Basic dm5mbTpwYXNzd29yZDEk
${ACCESS_TOKEN}=    ""
${SUBSCRIPTION_ID}=    ""

*** Test Cases ***
Subscribe for Notifications
    Create Session    vnfm_simulator_session    http://${REPO_IP}:9093
    &{headers1}=    Create Dictionary    Authorization=${BASIC_AUTH}    Content-Type=application/json    Accept=application/json
    Log To Console    \nGetting Access Token
    ${response}=    Post On Session    vnfm_simulator_session    url=/oauth/token?grant_type=client_credentials    headers=${headers1}
    Log To Console    \nResponse:${response}
    Run Keyword If    '${response.status_code}' == '200'    Log To Console    \nexecuted with expected result
    Should Be Equal As Strings    '${response.status_code}'    '200'
    Log To Console    \nResponse Content:\n${response.content}
    ${json_response}    Evaluate    json.loads(r"""${response.content}""", strict=False)    json
    Set Global Variable    ${ACCESS_TOKEN}    ${json_response}[access_token]
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}subscriptionRequest.json
    &{headers2}=    Create Dictionary    Authorization=Bearer ${ACCESS_TOKEN}    Content-Type=application/json    Accept=application/json
    Log To Console    \nSubscribing For VNF Package Notifications
    ${response2}=    Post On Session    vnfm_simulator_session    /vnfpkgm/v1/subscribe    data=${data}    headers=${headers2}
    Log To Console    \nResponse:\n${response2}
    Log To Console    \nResponse Content:\n${response2.content}
    Run Keyword If    '${response2.status_code}' == '200'    Log To Console    \nexecuted with expected result
    Should Be Equal As Strings    '${response2.status_code}'    '200'
    ${json_response2}=    Evaluate    json.loads(r"""${response2.content}""", strict=False)    json
    Dictionary Should Contain Key    ${json_response2}    id
    Set Global Variable    ${SUBSCRIPTION_ID}    ${json_response2}[id]
    Log To Console    \nid: ${SUBSCRIPTION_ID}
    Dictionary Should Contain Key    ${json_response2}    filter
    ${filter}=    Set Variable    ${json_response2}[filter]
    Dictionary Should Contain Key    ${filter}    notificationTypes
    Dictionary Should Contain Key    ${filter}    vnfdId
    Dictionary Should Contain Key    ${filter}    operationalState
    Dictionary Should Contain Key    ${json_response2}    callbackUri
    Dictionary Should Contain Key    ${json_response2}    _links
    Log To Console    \nexecuted with expected result

Get Subscriptions
    Create Session    so_vnfm_adapter_session    http://${REPO_IP}:9092
    &{headers}=    Create Dictionary    Authorization=${BASIC_AUTH}    Content-Type=application/json    Accept=application/json
    Log To Console    \nGetting Subscriptions from so-vnfm-adapter
    ${response}=    Get On Session    so_vnfm_adapter_session    ${PACKAGE_MANAGEMENT_BASE_URL}/subscriptions    headers=${headers}
    Log To Console    \nResponse:${response}
    Run Keyword If    '${response.status_code}' == '200'    Log To Console    \nexecuted with expected result
    Should Be Equal As Strings    '${response.status_code}'    '200'
    Log To Console    \nResponse Content:\n${response.content}
    ${json_response}    Evaluate    json.loads(r"""${response.content}""", strict=False)    json
    ${subscription}=    Set Variable    ${json_response}[0]
    Dictionary Should Contain Key    ${subscription}    id
    ${sub_id}=    Set Variable    ${subscription}[id]
    Should Be Equal As Strings    '${sub_id}'    '${SUBSCRIPTION_ID}'
    Dictionary Should Contain Key    ${subscription}    filter
    ${filter}=    Set Variable    ${subscription}[filter]
    Dictionary Should Contain Key    ${filter}    notificationTypes
    Dictionary Should Contain Key    ${filter}    vnfdId
    Dictionary Should Contain Key    ${filter}    operationalState
    Dictionary Should Contain Key    ${subscription}    callbackUri
    Log To Console    \nexecuted with expected result

Get Subscription By Subscription Id
    Create Session    so_vnfm_adapter_session    http://${REPO_IP}:9092
    &{headers}=    Create Dictionary    Authorization=${BASIC_AUTH}    Content-Type=application/json    Accept=application/json
    Log To Console    \nGetting Subscription with id ${SUBSCRIPTION_ID} from so-vnfm-adapter
    ${response}=    Get On Session    so_vnfm_adapter_session    ${PACKAGE_MANAGEMENT_BASE_URL}/subscriptions/${SUBSCRIPTION_ID}    headers=${headers}
    Log To Console    \nResponse:${response}
    Run Keyword If    '${response.status_code}' == '200'    Log To Console    \nexecuted with expected result
    Should Be Equal As Strings    '${response.status_code}'    '200'
    Log To Console    \nResponse Content:\n${response.content}
    ${json_response}    Evaluate    json.loads(r"""${response.content}""", strict=False)    json
    Dictionary Should Contain Key    ${json_response}    id
    ${sub_id}=    Set Variable    ${json_response}[id]
    Should Be Equal As Strings    '${sub_id}'    '${SUBSCRIPTION_ID}'
    Dictionary Should Contain Key    ${json_response}    filter
    ${filter}=    Set Variable    ${json_response}[filter]
    Dictionary Should Contain Key    ${filter}    notificationTypes
    Dictionary Should Contain Key    ${filter}    vnfdId
    Dictionary Should Contain Key    ${filter}    operationalState
    Dictionary Should Contain Key    ${json_response}    callbackUri
    Log To Console    \nexecuted with expected result
