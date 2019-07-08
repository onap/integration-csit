*** Settings ***
Library           JSONSchemaLibrary    schemas/
Library           OperatingSystem
Library           JSONLibrary
Library           REST    http://${CATALOG_IP}:8806
Library           MockServerLibrary
Library           Process
Suite Setup       Create Sessions

*** Variables ***
${ACCEPT_JSON}    application/json
${CONTENT_TYPE_JSON}    application/json
${apiRoot}        api
${apiName}        vnfpkgm
${apiVersion}     v1

*** Test Cases ***
GET Subscription
    Log    Trying to get the list of subscriptions
    Set Headers    {"Accept": "${ACCEPT_JSON}"}
    GET    ${apiRoot}/${apiName}/${apiVersion}/subscriptions
    Integer    response status    200
    Log    Received a 200 OK as expected
    ${contentType}=    Output    response headers Content-Type
    Should Contain    ${contentType}    ${CONTENT_TYPE_JSON}
    ${result}=    Output    response body
    Validate Json    PkgmSubscriptions.schema.json    ${result}
    Log    Validated PkgmSubscription schema
