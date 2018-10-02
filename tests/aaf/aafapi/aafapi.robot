*** Settings ***
Suite Setup       Run keywords    Created header    Created session
Library           RequestsLibrary
Library           Collections

*** Variables ***

*** Test Cases ***
View information from app
    [Template]  Get template
    /authz/nss/org.openecomp
    authz/perms/user/dgl@openecomp.org
    authz/roles/user/dgl@openecomp.org

Cleanup Namespace ( 424 Response - Delete dependencies and try again )
    [Tags]    delete
    ${resp}=    Delete Request    ${suite_aaf_session}    authz/ns/org.openecomp.dmaapBC   headers=${suite_headers}
    Should Be Equal As Strings    ${resp.status_code}    424
    log    		                  	'JSON Response Code :'${resp.text}	

Add information to app
    [Template]  Post template
    authz/ns/org.openecomp.dmaapBC/admin/alexD@openecomp.org    403
    authz/perms/user/m99751@dmaapBC.openecomp.org       406

*** Keywords ***
Created session
    Create Session      aaf_session     http://${AAF_IP}:8101
    Set Suite Variable    ${suite_aaf_session}    aaf_session

Created header
    ${headers}=  Create Dictionary    Authorization=Basic ZGdsQG9wZW5lY29tcC5vcmc6ZWNvbXBfYWRtaW4=    Content-Type=application/json    Accept=application/json
    Set Suite Variable    ${suite_headers}    ${headers}

Get template
    [Arguments]  ${topic}
    ${resp}=    Get Request    ${suite_aaf_session}    ${topic}    headers=${suite_headers}
    Should Be Equal As Strings    ${resp.status_code}    200
    log    		                  	'JSON Response Code :'${resp.text}

Post template
    [Arguments]  ${topic}   ${response_status_code}
    ${resp}=    Post Request    ${suite_aaf_session}    ${topic}   headers=${suite_headers}
    Should Be Equal As Strings    ${resp.status_code}    ${response_status_code}
    log    		                  	'JSON Response Code :'${resp.text}
