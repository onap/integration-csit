*** Settings ***
Library           Collections
Library           OperatingSystem
Library           RequestsLibrary
Library           json

*** Test Cases ***
Get Requests health check ok
    [Tags]    get
    CreateSession    sdc-fe    ${SDC_FE_PROTOCOL}://localhost:${SDC_FE_PORT}
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    ${resp}=    Get Request    sdc-fe    /sdc1/rest/healthCheck    headers=&{headers}
    Should Be Equal As Strings    ${resp.status_code}    200
    @{ITEMS}=    Copy List    ${resp.json()['componentsInfo']}
    : FOR    ${ELEMENT}    IN    @{ITEMS}
    \    Log    ${ELEMENT['healthCheckComponent']} ${ELEMENT['healthCheckStatus']}
