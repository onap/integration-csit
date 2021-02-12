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
${VNF_PACKAGE_ID}=    73522444-e8e9-49c1-be29-d355800aa349

*** Test Cases ***
VNF Package Onboarding Notification Received By Subscriber
    &{headers}=    Create Dictionary    Authorization=Bearer ${ACCESS_TOKEN}    Content-Type=application/json    Accept=application/json
    Log To Console    \nChecking If VNF Package Notification was received for vnfPkgId: ${VNF_PACKAGE_ID}
    ${response}=    Get On Session    vnfm_simulator_session    /vnfpkgm/v1/notification-cache-test/${VNF_PACKAGE_ID}    headers=${headers}
    Log To Console    \nResponse:${response}
    Run Keyword If    '${response.status_code}' == '200'    Log To Console    \nexecuted with expected result
    Should Be Equal As Strings    '${response.status_code}'    '200'
    Log To Console    \nResponse Content:\n${response.content}
    ${json_response}=    Evaluate    json.loads(r"""${response.content}""", strict=False)    json
    Dictionary Should Contain Key        ${json_response}    id
    Dictionary Should Contain Key        ${json_response}    notificationType
    Should be Equal As Strings    VnfPackageOnboardingNotification    ${json_response}[notificationType]
    Dictionary Should Contain Key        ${json_response}    subscriptionId
    Dictionary Should Contain Key        ${json_response}    timeStamp
    Dictionary Should Contain Key        ${json_response}    vnfPkgId
    Should Be Equal As Strings    ${VNF_PACKAGE_ID}    ${json_response}[vnfPkgId]
    Dictionary Should Contain Key        ${json_response}    vnfdId
    Dictionary Should Contain Key        ${json_response}    _links
    Log To Console    \nexecuted with expected result

Delete Subscription By SubscriptionId
    Create Session    so_vnfm_adapter_session    http://${REPO_IP}:9092
    &{headers}=    Create Dictionary    Authorization=${BASIC_AUTH}    Content-Type=application/json    Accept=application/json
    Log To Console    \nDeleting Subscription with subscriptionId: ${SUBSCRIPTION_ID} from so-vnfm-adapter
    ${response}=    Delete On Session    so_vnfm_adapter_session    ${PACKAGE_MANAGEMENT_BASE_URL}/subscriptions/${SUBSCRIPTION_ID}    headers=${headers}
    Log To Console    \nResponse:${response}
    Run Keyword If    '${response.status_code}' == '204'    Log To Console    \nexecuted with expected result
    Should Be Equal As Strings    '${response.status_code}'    '204'


