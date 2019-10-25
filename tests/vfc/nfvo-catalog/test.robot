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
${service_packages_url}         /api/parser/v1/service_packages
${vnfpackages_url}         /api/catalog/v1/vnfpackages
${nspackages_url}         /api/catalog/v1/nspackages
${jobs_url}         /api/catalog/v1/jobs/{job_id}

#json files
${ns_packages_json}    ${SCRIPTS}/../tests/vfc/nfvo-catalog/jsons/ns_packages.json
${vnfpackages_catalog_json}    ${SCRIPTS}/../tests/vfc/nfvo-catalog/jsons/vnf_packages.json
${jobs_json}    ${SCRIPTS}/../tests/vfc/nfvo-catalog/jsons/jobs.json

#global variables
${jobId}

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

Check distribute catalog NS pacakages
    Log    Check distribute catalog NS pacakages
    [Documentation]    check distribute catalog NS pacakages
    Check distribute package    ${ns_packages_json}    ${nspackages_url}

Check query catalog all NS package
    Log    Query catalog all NS package
    [Documentation]     check query catalog all NS package
    Check query all packages    ${nspackages_url}

Check query all Service package
    Log    Query all Service packages
    [Documentation]     check query Service packages by MSB
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Check query all packages    ${service_packages_url}

Check distribute VNF package
    Log    Check distribute VNF packagee
    [Documentation]     check distribute VNF package
    ${json_value}=     json_from_file      ${vnfpackages_catalog_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${CATALOG_IP}:${catalog_port}    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${vnfpackages_url}    ${json_string}
    Should Be Equal As Strings    202   ${resp.status_code}
    ${response_json}    json.loads    ${resp.content}
    ${jobId}=    Convert To String      ${response_json['jobId']}
    Set Global Variable     ${jobId}

Check update job status
    Log    Check update job status
    [Documentation]    check update job status
    ${json_value}=     json_from_file      ${jobs_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${CATALOG_IP}:${catalog_port}    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${jobs_url}/${jobId}    ${json_string}
    Should Be Equal As Strings    202   ${resp.status_code}

Check query job status
    Log    Check query job status
    [Documentation]    check query job status
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${CATALOG_IP}:${catalog_port}    headers=${headers}
    ${resp}=  Get Request    web_session    ${jobs_url}/${jobId}
    Should Be Equal As Strings    200    ${resp.status_code}   

Check query all VNF package
    Log    Query all VNF packages
    [Documentation]     check query VNF packages
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${CATALOG_IP}:${catalog_port}    headers=${headers}
    ${resp}=  Get Request    web_session    ${vnfpackages_url}
    Should Be Equal As Strings    200    ${resp.status_code}
    ${response_json}    json.loads    ${resp.content}

*** Keywords ***
Check Health
    [Arguments]  ${url}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${CATALOG_IP}:${catalog_port}    headers=${headers}
    ${resp}=  Get Request    web_session    ${url}
    Should Be Equal As Strings    200    ${resp.status_code}
    ${response_json}    json.loads    ${resp.content}    
    Should Be Equal As Strings    active    ${response_json['status']}

Check distribute package
    [Arguments]    ${json_file}    ${url}
    ${json_value}=     json_from_file      ${json_file}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${CATALOG_IP}:${catalog_port}    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${url}    ${json_string}
    Should Be Equal As Strings    202   ${resp.status_code} 

Check query all packages
    [Arguments]    ${url}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${CATALOG_IP}:${catalog_port}    headers=${headers}
    ${resp}=  Get Request    web_session    ${url}
    Should Be Equal As Strings    200    ${resp.status_code}