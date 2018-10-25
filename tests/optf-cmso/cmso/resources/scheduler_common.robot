*** Settings ***
Documentation     The private interface for interacting with Openstack. It handles low level stuff like managing the authtoken and Openstack required fields

Library           Collections
Library 	      RequestsLibrary
#Library	          UUID
Library		../attlibs/UID.py
#Library           HTTPUtils
Library		../attlibs/HTTPUtils.py
Library           String
Resource   misc.robot
*** Variables ***
*** Variables ***
${GLOBAL_SCHEDULER_PORT}		8080
${GLOBAL_SCHEDULER_PROTOCOL}		http
#${GLOBAL_SCHEDULER_HOST}		127.0.0.1
${GLOBAL_SCHEDULER_USER}		jf9860@csp.att.com
${GLOBAL_SCHEDULER_PASSWORD}		45=Forty5
${GLOBAL_APPLICATION_ID}		schedulertest
${SCHEDULER_PATH}    /cmso/v1
${CHANGE_MANAGEMENT_PATH}    ${SCHEDULER_PATH}
${valid_status_codes}    200    202    400    404    204    409
#**************** Test Case Variables ******************

*** Keywords ***


Post Change Management
    [Documentation]    Runs a scheduler POST request
    [Arguments]    ${alias}    ${resource}   ${data}={}
    ${data_path}=   Catenate   ${CHANGE_MANAGEMENT_PATH}/${resource}
    ${resp}=    Post Scheduler    ${alias}    ${data_path}   ${data}
    [Return]   ${resp}   

Delete Change Management
    [Documentation]    Runs a scheduler DELETE request (this may need to be changed for 1802 US change Delete schedule to Cancel Schedule)
    [Arguments]    ${alias}    ${resource}
    ${data_path}=   Catenate   ${CHANGE_MANAGEMENT_PATH}/${resource}
    ${resp}=    Delete Scheduler    ${alias}    ${data_path}
    [Return]   ${resp}   

Get Change Management
    [Documentation]    Runs a scheduler GET request
    [Arguments]    ${alias}    ${resource}  
    ${data_path}=   Catenate   ${CHANGE_MANAGEMENT_PATH}/${resource} 
    ${resp}=   Get Scheduler    ${alias}    ${data_path}
    [Return]   ${resp}    

Post Scheduler
    [Documentation]    Runs a scheduler POST request
    [Arguments]    ${alias}   ${data_path}   ${data}={}
    ${url}=   Catenate   ${GLOBAL_SCHEDULER_PROTOCOL}://${GLOBAL_SCHEDULER_HOST}:${GLOBAL_SCHEDULER_PORT}
    ${uuid}=    Generate UUID
    ${proxies}=   Create Dictionary   no=pass
    ${session}=    Create Session 	${alias}   ${url}    
    ${auth_string}=   B64 Encode    ${GLOBAL_SCHEDULER_USER}:${GLOBAL_SCHEDULER_PASSWORD}
    ${headers}=  Create Dictionary   Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}   Authorization=Basic ${auth_string}
    ${resp}= 	Post Request 	${alias} 	${data_path}     headers=${headers}   data=${data}
    Log    Received response from scheduler ${resp.text}
    ${valid}=   Split String   ${valid_status_codes}
    
    Validate Status   ${resp}   ${valid}
    [Return]    ${resp}

Delete Scheduler
    [Documentation]    Runs a scheduler POST request
    [Arguments]    ${alias}   ${data_path} 
    ${url}=   Catenate   ${GLOBAL_SCHEDULER_PROTOCOL}://${GLOBAL_SCHEDULER_HOST}:${GLOBAL_SCHEDULER_PORT}
    ${uuid}=    Generate UUID
    ${proxies}=   Create Dictionary   no=pass
    ${session}=    Create Session 	${alias}   ${url}     
    ${auth_string}=   B64 Encode    ${GLOBAL_SCHEDULER_USER}:${GLOBAL_SCHEDULER_PASSWORD}
    ${headers}=  Create Dictionary   Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}      Authorization=Basic ${auth_string}  
    ${resp}= 	Delete Request 	${alias} 	${data_path}     headers=${headers}
    Log    Received response from scheduler ${resp.text}
    ${valid}=   Split String   ${valid_status_codes}
    Validate Status   ${resp}   ${valid}
    [Return]    ${resp}

Get Scheduler
    [Documentation]    Runs a scheduler GET request
    [Arguments]    ${alias}   ${data_path} 
    ${url}=   Catenate   ${GLOBAL_SCHEDULER_PROTOCOL}://${GLOBAL_SCHEDULER_HOST}:${GLOBAL_SCHEDULER_PORT}
    ${uuid}=    Generate UUID
    ${proxies}=   Create Dictionary   no=pass
    ${session}=    Create Session 	${alias}   ${url}     
    ${auth_string}=   B64 Encode    ${GLOBAL_SCHEDULER_USER}:${GLOBAL_SCHEDULER_PASSWORD}
    ${headers}=  Create Dictionary   Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}      Authorization=Basic ${auth_string}
    ${resp}= 	Get Request 	${alias} 	${data_path}     headers=${headers}
    Log    Received response from scheduler ${resp.json()}
    ${valid}=   Split String   ${valid_status_codes}
    Validate Status   ${resp}   ${valid}
    [Return]    ${resp}
