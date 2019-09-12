*** Settings ***
Documentation     The main interface for interacting with A&AI. It handles low level stuff like managing the http request library and A&AI required fields
Library 	      RequestsLibrary
Library	          UUID
Library           HTTPUtils
Resource            ../global_properties.robot

*** Variables ***
${AAI_HEALTH_PATH}  /aai/util/echo?action=long
${VERSIONED_INDEX_PATH}     /aai/v14
${AAI_FRONTEND_ENDPOINT}    ${GLOBAL_AAI_SERVER_PROTOCOL}://${GLOBAL_INJECTED_AAI1_IP_ADDR}:${GLOBAL_AAI_SERVER_PORT}

*** Keywords ***
Run A&AI Health Check
    [Documentation]    Runs an A&AI health check
    :FOR    ${i}    IN RANGE    20
    \    ${resp}=    Run A&AI Get Request    ${AAI_HEALTH_PATH}
    \    Log    Received response from so ${resp.json()}
    \    Log    Received response from so status ${resp.status_code}
    \    ${exit_loop}=    Evaluate    ${resp.status_code} == 200
    \    Exit For Loop If    ${exit_loop}
    \    Sleep    15s

Run A&AI Get Request
    [Documentation]    Runs an A&AI get request
    [Arguments]    ${data_path}
    Disable Warnings
    Create Session    	aai 	${AAI_FRONTEND_ENDPOINT}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Accept=application/json    Content-Type=application/json    X-TransactionId=Test    X-FromAppId=SO
    ${resp}= 	Get Request 	aai 	${data_path}     headers=${headers}
    Log    Received response from aai ${resp.text}
    [Return]    ${resp}

Run A&AI Put Request
    [Documentation]    Runs an A&AI put request
    [Arguments]    ${data_path}    ${data}
    Disable Warnings
    Create Session    	aai 	${AAI_FRONTEND_ENDPOINT}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Accept=application/json    Content-Type=application/json    X-TransactionId=Test    X-FromAppId=SO
    ${resp}= 	Put Request 	aai 	${data_path}     data=${data}    headers=${headers}
    Log    Received response from aai ${resp.text}
    [Return]    ${resp}

Run A&AI Post Request
    [Documentation]    Runs an A&AI Post request
    [Arguments]    ${data_path}    ${data}
    Disable Warnings
    Create Session    	aai 	${AAI_FRONTEND_ENDPOINT}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Post Request 	aai 	${data_path}     data=${data}    headers=${headers}
    Log    Received response from aai ${resp.text}
    [Return]    ${resp}

Run A&AI Patch Request
    [Documentation]    Runs an A&AI Post request
    [Arguments]    ${data_path}    ${data}
    Disable Warnings
    Log    ${data}
    Create Session    	aai 	${AAI_FRONTEND_ENDPOINT}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/merge-patch+json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}    X-HTTP-Method-Override=PATCH
    ${resp}= 	Post Request 	aai 	${data_path}     data=${data}    headers=${headers}
    Log    Received response from aai ${resp.text}
    [Return]    ${resp}

Run A&AI Delete Request
    [Documentation]    Runs an A&AI delete request
    [Arguments]    ${data_path}    ${resource_version}
    Disable Warnings
    Create Session    	aai 	${AAI_FRONTEND_ENDPOINT}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Delete Request 	aai 	${data_path}?resource-version=${resource_version}       headers=${headers}
    Log    Received response from aai ${resp.text}
    [Return]    ${resp}

Delete A&AI Entity
    [Documentation]    Deletes an entity in A&AI
    [Arguments]    ${uri}
    ${get_resp}=    Run A&AI Get Request     ${VERSIONED_INDEX PATH}${uri}
	Run Keyword If    '${get_resp.status_code}' == '200'    Delete A&AI Entity Exists    ${uri}    ${get_resp.json()['resource-version']}

Delete A&AI Entity Exists
    [Documentation]    Deletes an  A&AI	entity
    [Arguments]    ${uri}    ${resource_version_id}
    ${put_resp}=    Run A&AI Delete Request    ${VERSIONED_INDEX PATH}${uri}    ${resource_version_id}
    Should Be Equal As Strings 	${put_resp.status_code} 	204

