*** Settings ***
Documentation     The private interface for interacting with Openstack. It handles low level stuff like managing the authtoken and Openstack required fields

Library           Collections
Library 	      RequestsLibrary
Library		../attlibs/UUID.py
Library           HTTPUtils
Library           DateTime

Resource   misc.robot
*** Variables ***
*** Variables ***
# http://zld03290.vci.att.com:9018
#
${CLOSE_PATH}    /vtm/manageChangeRecord/v1/closeCancelChangeRecord
${CLOSE_PORT}    31127


#**************** Test Case Variables ******************

*** Keywords ***

vTM Query Template
    [Documentation]    
    [Arguments]    ${alias}    ${offset}=0  ${numOfrows}=100   ${display}=[]   ${filter}={}
    ${request}=   Create Dictionary   offset=${offset}   numOfRows=${numOfRows}   displayTuple=${display}   filterTuple=${filter}
    Log   ${request}
    ${resp}=   vTM Query   ${alias}   ${request}
    [Return]   ${resp}


vTM Query
    [Documentation]    
    [Arguments]    ${alias}    ${request}
    ${url}=   Catenate   ${GLOBAL_VTM_URL}
    ${data_path}=   Catenate   ${GLOBAL_LISTCHANGE_PATH}
    ${uuid}=    Generate UUID
    ${proxies}=   Create Dictionary   no=pass
    ${session}=    Create Session 	${alias}   ${url}   verify=True      
    ${auth_string}=   B64 Encode    ${GLOBAL_VTM_USER}:${GLOBAL_VTM_PASSWORD}
    #Authorization=Basic ${GLOBAL_POLICY_AUTH}   ClientAuth=${GLOBAL_POLICY_CLIENTAUTH}   
    ${headers}=  Create Dictionary  Authorization=Basic ${auth_string}   Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Post Request 	${alias} 	${data_path}     headers=${headers}   data=${request}
    Log    Received response from vTM ${resp.text}
    ${valid}=   Create List   200    404
    Validate Status   ${resp}   ${valid}
    [Return]    ${resp}


vTM Close Ticket
    [Documentation]    
    [Arguments]    ${alias}    ${ticket}   ${changeClosedBy}=jf9860
    ${url}=   Catenate   ${GLOBAL_VTM_PROTO}://${GLOBAL_VTM_HOST}:${CLOSE_PORT}
    ${data_path}=   Catenate   ${CLOSE_PATH}
    ${uuid}=    Generate UUID
    ${proxies}=   Create Dictionary   no=pass
    ${session}=    Create Session 	${alias}   ${url}   verify=True      
    ${auth_string}=   B64 Encode    ${GLOBAL_VTM_USER}:${GLOBAL_VTM_PASSWORD}
    ${end}=   Get Current Date   result_format=epoch    exclude_millis=True
    ${end}=   Convert To Integer   ${end}
    ${start}=   Evaluate   ${end}-60
    ${request}=   Create Dictionary   changeId=${ticket}   status=Closed   changeClosedBy=${changeClosedBy}   closureCode=Successful As Scheduled    
   	Set To Dictionary   ${request}   customerImpacted=Unknown    actualStartDate=${start}   actualEndDate=${end}
    
    #Authorization=Basic ${GLOBAL_POLICY_AUTH}   ClientAuth=${GLOBAL_POLICY_CLIENTAUTH}   
    ${headers}=  Create Dictionary  Authorization=Basic ${auth_string}   Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Post Request 	${alias} 	${data_path}     headers=${headers}   data=${request}
    Log    Received response from vTM ${resp.json()}
    ${valid}=   Create List   200    404
    Validate Status   ${resp}   ${valid}
    [Return]    ${resp}


vTM Cancel Ticket
    [Documentation]    
    [Arguments]    ${alias}    ${ticket}
    ${url}=   Catenate   ${GLOBAL_VTM_PROTO}://${GLOBAL_VTM_HOST}:${CLOSE_PORT}
    ${data_path}=   Catenate   ${CLOSE_PATH}
    ${uuid}=    Generate UUID
    ${proxies}=   Create Dictionary   no=pass
    ${session}=    Create Session 	${alias}   ${url}   verify=True      
    ${auth_string}=   B64 Encode    ${GLOBAL_VTM_USER}:${GLOBAL_VTM_PASSWORD}
    ${end}=   Get Current Date   result_format=epoch    exclude_millis=True
    ${end}=   Convert To Integer   ${end}
    ${start}=   Evaluate   ${end}-60
    ${request}=   Create Dictionary   changeId=${ticket}   status=Closed   changeClosedBy=${GLOBAL_VID_USERID}   closureCode=Cancelled    closingComments=Cancel requested by user    
   	Set To Dictionary   ${request}      customerImpacted=No
    ${headers}=  Create Dictionary  Authorization=Basic ${auth_string}   Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Post Request 	${alias} 	${data_path}     headers=${headers}   data=${request}
    Log    Received response from vTM ${resp.json()}
    ${valid}=   Create List   200    404
    Validate Status   ${resp}   ${valid}
    [Return]    ${resp}
