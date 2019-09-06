*** Settings ***
Documentation     The main interface for interacting with SO. It handles low level stuff like managing the http request library and SO required fields
Library 	      RequestsLibrary
Library	          UUID
Library           OperatingSystem
Library           Collections
Library           HTTPUtils
Resource          global_properties.robot
Resource          json_templater.robot
*** Variables ***
${SO_ENDPOINT}     ${GLOBAL_SO_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SO_IP_ADDR}:${GLOBAL_SO_SERVER_PORT}
${CATALOG_DB_ENDPOINT}   ${GLOBAL_SO_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SO_IP_ADDR}:${GLOBAL_SO_CATALOG_PORT}
${CAMUNDA_DB_ENDPOINT}    ${GLOBAL_SO_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SO_IP_ADDR}:${GLOBAL_SO_CAMUNDA_PORT}
${SIMULATOR_ENDPOINT}    ${GLOBAL_SO_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SO_IP_ADDR}:${GLOBAL_SO_SIMULATOR_PORT}

*** Keywords ***
  
Run SO Get Request
    [Documentation]    Runs an SO get request
    [Arguments]    ${full_path}    ${accept}=application/json    ${endPoint}=${SO_ENDPOINT}
    Disable Warnings
    Log    Creating session ${SO_ENDPOINT}
    ${session}=    Create Session 	so 	${SO_ENDPOINT}
    ${uuid}=    Generate UUID
    ${uuidstring}=    Convert To String    ${uuid}
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}= 	Get Request 	so 	${full_path}     headers=${headers}
    Log    Received response from so ${resp.text}
    [Return]    ${resp}

Poll SO Get Request
    [Documentation]    Runs an SO get request until a certain status is received. valid values are COMPLETE
    [Arguments]    ${data_path}     ${status}
    Disable Warnings
    Log    Creating session ${SO_ENDPOINT}
    ${session}=    Create Session 	so 	${SO_ENDPOINT}
    ${uuid}=    Generate UUID
    ${uuidstring}=    Convert To String    ${uuid}
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    #do this until it is done
    :FOR    ${i}    IN RANGE    20
    \    ${resp}= 	Get Request 	so 	${data_path}     headers=${headers}
    \    Should Not Contain    ${resp.text}    FAILED
    \    Log    ${resp.json()['request']['requestStatus']['requestState']}
    \    ${exit_loop}=    Evaluate    "${resp.json()['request']['requestStatus']['requestState']}" == "${status}"
    \    Exit For Loop If  ${exit_loop}
    \    Sleep    15s
    Log    Received response from so ${resp.text}
    [Return]    ${resp}

Run SO Post request
    [Documentation]    Runs an SO post request
    [Arguments]  ${data_path}  ${data}
    Disable Warnings
    Log    Creating session ${SO_ENDPOINT}
    ${session}=    Create Session 	so 	${SO_ENDPOINT}
    ${uuid}=    Generate UUID
    ${uuidstring}=    Convert To String    ${uuid}
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
	${resp}= 	Post Request 	so 	${data_path}     data=${data}   headers=${headers}
	Log    Received response from so ${resp.text}
	[Return]  ${resp}
	

Run SO Delete request
    [Documentation]    Runs an SO Delete request
    [Arguments]  ${data_path}  ${data}
    Disable Warnings
    Log    Creating session ${SO_ENDPOINT}
    ${session}=    Create Session 	so 	${SO_ENDPOINT}
    ${uuid}=    Generate UUID
    ${uuidstring}=    Convert To String    ${uuid}
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Delete Request    so    ${data_path}    ${data}    headers=${headers}
    Log    Received response from so ${resp.text}
    [Return]    ${resp}
