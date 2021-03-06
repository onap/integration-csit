*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     String

*** Variables ***
${SDN_APIDOCS_URI}    /apidoc/openapi3/18/apis/single
${SDN_HEALTHCHECK_OPERATION_PATH}    /operations/SLI-API:healthcheck

*** Test Cases ***

Healthcheck API
    Create Session   sdnc  http://localhost:8282/restconf
    ${data}=    Get File     ${CURDIR}${/}data${/}data.json
    &{headers}=  Create Dictionary    Authorization=Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    sdnc    ${SDN_HEALTHCHECK_OPERATION_PATH}    data=${data}    headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['output']['response-code']}   200

Check SLI-API
    Create Session   sdnc  http://localhost:8282
    &{headers}=  Create Dictionary    Authorization=Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==    Content-Type=application/json    Accept=application/json
    ${resp}=    Get Request    sdnc    ${SDN_APIDOCS_URI}    headers=${headers}
    Log    ${resp.text}
    Should Contain    ${resp.text}    SLI-API
