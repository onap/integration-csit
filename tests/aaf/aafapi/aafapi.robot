*** Settings ***
Library           OperatingSystem
Library           RequestsLibrary
Library           requests
Library           Collections
Library           String

*** Variables ***
${TARGETURL_NAMESPACE}     https://${AAF_IP}:8100/authz/nss/org.osaaf.people
${TARGETURL_PERMS}         https://${AAF_IP}:8100/authz/perms/user/aaf_admin@people.osaaf.org
${TARGETURL_ROLES}         https://${AAF_IP}:8100/authz/roles/user/aaf_admin@people.osaaf.org
${username}               aaf_admin@people.osaaf.org
${password}               demo123456!


*** Test Cases ***
View Namesapce
    [Tags]    get
    CreateSession    aaf    http://${AAF_IP}:8100
    &{headers}=  Create Dictionary    Authorization=Basic YWFmX2FkbWluQHBlb3BsZS5vc2FhZi5vcmc6ZGVtbzEyMzQ1NiE=    Content-Type=application/json    Accept=application/json
    ${resp}=    Get Request    aaf    /authz/nss/org.osaaf.people    headers=&{headers}
    Should Be Equal As Strings    ${resp.status_code}    200
    log    		                  	'JSON Response Code :'${resp.text}	
	
View by User Permission 
    [Tags]    get
    CreateSession    aaf    http://${AAF_IP}:8100
    &{headers}=  Create Dictionary    Authorization=Basic YWFmX2FkbWluQHBlb3BsZS5vc2FhZi5vcmc6ZGVtbzEyMzQ1NiE=    Content-Type=application/json    Accept=application/json
    ${resp}=    Get Request    aaf    authz/perms/user/aaf_admin@people.osaaf.org    headers=&{headers}
    Should Be Equal As Strings    ${resp.status_code}    200
    log    		                  	'JSON Response Code :'${resp.text}	
	
View by User Role 
    [Tags]    get
    CreateSession    aaf    http://${AAF_IP}:8100
    &{headers}=  Create Dictionary    Authorization=Basic YWFmX2FkbWluQHBlb3BsZS5vc2FhZi5vcmc6ZGVtbzEyMzQ1NiE=    Content-Type=application/json    Accept=application/json
    ${resp}=    Get Request    aaf    authz/roles/user/aaf_admin@people.osaaf.org    headers=&{headers}
    Should Be Equal As Strings    ${resp.status_code}    200
    log    		                  	'JSON Response Code :'${resp.text}