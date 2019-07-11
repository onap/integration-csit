*** settings ***
Resource    ../../common.robot
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     HttpLibrary.HTTP

*** Variables ***
${catalog_port}            8806
${cataloghealthcheck_url}         /api/catalog/v1/health_check
${vnfpkgmhealthcheck_url}         /api/vnfpkgm/v1/health_check
${nsdhealthcheck_url}         /api/nsd/v1/health_check
${parserhealthcheck_url}         /api/parser/v1/health_check

*** Test Cases ***
Check Health Catalog
    Log   Check Health Catalog
    [Documentation]    check health for catalog by MSB
    Check Health    ${cataloghealthcheck_url}

Check Health Vnfpkgm
    Log   Check Health Vnfpkgm
    [Documentation]    check health for Vnfpkgm by MSB
    Check Health    ${vnfpkgmhealthcheck_url}

Check Health Nsd
    Log   Check Health Nsd
    [Documentation]    check health for Nsd by MSB
    Check Health    ${nsdhealthcheck_url}

Check Health Parser
    Log   Check Health Parser
    [Documentation]    check health for Parser by MSB
    Check Health    ${parserhealthcheck_url}

*** Keywords ***
Check Health
    [Arguments]  ${url}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${CATALOG_IP}:${catalog_port}    headers=${headers}
    ${resp}=  Get Request    web_session    ${url}
    Should Be Equal As Strings    200    ${resp.status_code}
    ${response_json}    json.loads    ${resp.content}    
    Should Be Equal As Strings    active    ${response_json['status']}
