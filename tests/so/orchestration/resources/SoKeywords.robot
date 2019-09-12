*** Settings ***
Library	StringTemplater
Library	Collections
Library	RequestsLibrary
Library	HttpLibrary.HTTP
Library	OperatingSystem
Library	BuiltIn
Library	String
Library	XML
Resource    common/Variables.robot
Resource	SoVariables.robot
Resource    global_properties.robot
Resource    so_interface.robot

***Variables***
${SO_REST_URL}    ${GLOBAL_SO_SERVER_PROTOCOL}://${GLOBAL_INJECTED_SO_IP_ADDR}:${GLOBAL_SO_SERVER_PORT}

*** Keywords ***
Wait To Poll
	[Documentation]	Sleep the execution for the specified time (in seconds).
	Sleep	${POLL_WAIT_TIME}

Poll Orchestration Request
	[Documentation]	Poll the service orchestration request for the completion. Uses MAX_POLL_COUNT to specify the maximum number of polling attempts.
	[Arguments]	${request_id}
	: FOR	${INDEX}	IN RANGE	1	${MAX_POLL_COUNT}
	\	Log	    'Poll Count :'
	\	Log	${INDEX}
	\	${orchestration_request_response}=	Get Orchestration Request Status	${request_id}

	#	First check request status code
	\	${orch_request_status_code}=	Set Variable	${orchestration_request_response.status_code}
	\	${orchestration_failure_message}=	Run Keyword If	${orch_request_status_code} != ${HTTP_OK}	Catenate	Error Code	${orch_request_status_code}
	\	${request_completion_status}=	Run Keyword If	${orch_request_status_code} != ${HTTP_OK}	Set Variable	'${ORCH_REQUEST_FAILED}'
	\	Exit For Loop If	${orch_request_status_code} != ${HTTP_OK}

	#	Get Status of Orchestration request
	\	Log	${orchestration_request_response.content}
	\	${request_completion_status}	Get Json Value	${orchestration_request_response.content}	/request/requestStatus/requestState
	\	${orchestration_status_message}=	Run Keyword If	${request_completion_status} != '${ORCH_REQUEST_IN_PROGRESS}'	Get Json Value	${orchestration_request_response.content}	/request/requestStatus/statusMessage
	\	Log	${request_completion_status}

	#	Check for FAILED status
	\	${orchestration_failure_message}=	Run Keyword If	${request_completion_status} == '${ORCH_REQUEST_FAILED}'	Set Variable	${orchestration_status_message}
	\	Exit For Loop If	${request_completion_status} == '${ORCH_REQUEST_FAILED}'

	#	Check for COMPLETE status
	\	Exit For Loop If	${request_completion_status} == '${ORCH_REQUEST_COMPLETE}'

	#	Check for MAX NO OF POLL count, and exit if it has reached the maximum poll count
	\	${orchestration_failure_message}=	Run Keyword If	${INDEX} == ${MaxPollCount}-1	Set Variable	${TIME_OUT_MESSAGE}
	\	Exit For Loop If	${INDEX} == ${MaxPollCount}-1
	\	Wait To Poll
	LOG	${orchestration_failure_message}
	${request_completion_status}	Get Substring	${request_completion_status}	1	-1
	[Return]	${request_completion_status}	${orchestration_failure_message}

Get Orchestration Request Status
	[Documentation]	Get the status of the orchestrated service request.
	[Arguments]	${request_id}
	
	${url}=	Catenate	SEPARATOR=/	${SO_ORCHESTRATION_REQUESTS_URI}	${request_id}
	${orchestration_request_response}	Run SO Get Request    ${url}
	[Return]	${orchestration_request_response}
	
Get Orchestration Request Status with parameters
	[Documentation]	Get the status of the orchestrated service request.
	[Arguments]	${request_id}    ${parameter}
	
	${url}=	Catenate	${SO_ORCHESTRATION_REQUESTS_URI}/${request_id}?${parameter}
	${orchestration_request_response}	Run SO Get Request    ${url}
	[Return]	${orchestration_request_response}
	
Get ExtSystemErrorSource
    [Documentation]         Return ExtSystemErrorSource from Get Orchestration Request
    [Arguments]             ${request_id}
    
    ${orchestration_request_response}    Get Orchestration Request Status with parameters    ${request_id}    format=statusdetail
    ${orchestration_request_response_json}    Parse Json    ${orchestration_request_response.content}
    ${extSystemErrorSource}    Convert to String    ${orchestration_request_response_json['request']['requestStatus']['extSystemErrorSource']}
        
    [Return]    ${extSystemErrorSource}
    
Get RollbackExtSystemErrorSource
    [Documentation]         Return ExtSystemErrorSource from Get Orchestration Request
    [Arguments]             ${request_id}
    
    ${orchestration_request_response}    Get Orchestration Request Status with parameters    ${request_id}    format=statusdetail
    ${orchestration_request_response_json}    Parse Json    ${orchestration_request_response.content}
    ${rollbackExtSystemErrorSource}    Convert to String    ${orchestration_request_response_json['request']['requestStatus']['rollbackExtSystemErrorSource']}
        
    [Return]    ${rollbackExtSystemErrorSource}
    
Get FlowStatus
    [Documentation]         Return Flow Status from Get Orchestration Request
    [Arguments]             ${request_id}
    
    ${orchestration_request_response}    Get Orchestration Request Status with parameters    ${request_id}    format=statusdetail
    ${orchestration_request_response_json}    Parse Json    ${orchestration_request_response.content}
    Log    ${orchestration_request_response_json} 
    ${flow_status}    Convert to String    ${orchestration_request_response_json['request']['requestStatus']['flowStatus']}
        
    [Return]    ${flow_status}