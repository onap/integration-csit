*** Settings ***
Library           OperatingSystem
Library           RequestsLibrary
Library           requests
Library           Collections
Library           Process
Library           String

*** Variables ***
${TARGETURL_NAMESPACE}     /ejbca/publicweb/cmp/cmp
${FEED_CONTENT_TYPE}       application/pkixcmp


*** Test Cases ***
Run Feed Creation
    [Documentation]                 Connection with EJBCA
    CreateSession    ejbca    http://0.0.0.0:80
    ${resp}=                        Post Request                        ejbca      ${TARGETURL_NAMESPACE}         ${FEED_CONTENT_TYPE}
    Should Be Equal As Strings      ${resp.status_code}              200
#    log                             'JSON Response Code:'${resp}
