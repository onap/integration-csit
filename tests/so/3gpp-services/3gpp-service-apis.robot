*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
${SLEEP_INTERVAL_SEC}=   10
${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}=     10     # Represents the maximum number of attempts that will be made before a timeout. It sleeps for SLEEP_INTERVAL_SEC seconds before retry.

*** Test Cases ***
Allocate NSSI
        Create Session   api_handler_session  http://${REPO_IP}:8080
        ${data}=    Get Binary File     ${CURDIR}${/}data${/}3gppservices_allocate_api.json
        &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
        ${nssi_allocation_request}=      POST On Session    api_handler_session    /onap/so/infra/3gppservices/v1/allocate    data=${data}    headers=${headers}
        Log To Console      Received status code: ${nssi_allocation_request.status_code}
	${nssi_allocation_request_json_response}=      Evaluate     json.loads(r"""${nssi_allocation_request.content}""", strict=False)    json
	${jobId}=          Set Variable         ${nssi_allocation_request_json_response}[jobId]

	Create Session   nssmf_adapter_session  http://${REPO_IP}:8075
	${nssmf_data}=    Get Binary File	${CURDIR}${/}data${/}nssmf_adapter_allocate_request.json
	&{headers}=  Create Dictionary    Authorization=Basic bXNvX2FkbWluOnBhc3N3b3JkMSQ=    Content-Type=application/json    Accept=application/json
		
        FOR    ${INDEX}    IN RANGE    ${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}
	   ${nssmf_allocation_request}=      POST On Session    nssmf_adapter_session    /api/rest/provMns/v1/NSS/jobs/${jobId}    data=${nssmf_data}    headers=${headers}
       	   Run Keyword If  '${nssmf_allocation_request.status_code}' == '200'  log to console   \nexecuted with expected result
           log to console      ${nssmf_allocation_request.content}
           ${nssmf_allocation_response}=    Evaluate     json.loads(r"""${nssmf_allocation_request.content}""", strict=False)    json
           ${actual_request_state}=     SET VARIABLE       ${nssmf_allocation_response}[responseDescriptor][status]
           Log To Console    Received actual repsonse status:${actual_request_state}
           RUN KEYWORD IF   '${actual_request_state}' == 'finished'      Exit For Loop
           log to console  Will try again after ${SLEEP_INTERVAL_SEC} seconds
           SLEEP   ${SLEEP_INTERVAL_SEC}s
        END
	${nssiId}=     SET VARIABLE       ${nssmf_allocation_response}[responseDescriptor][nssiId]
	Set Global Variable      ${nssiId}
        Log To Console     final repsonse status received: ${actual_request_state}
        Run Keyword If  '${actual_request_state}' == 'finished'  log to console   \nexecuted with expected result
        Should Be Equal As Strings    '${actual_request_state}'    'finished'
	

Deallocate NSSI	
	Create Session   api_handler_session  http://${REPO_IP}:8080
        ${data}=    Get Binary File     ${CURDIR}${/}data${/}3gppservices_deallocate_api.json
        ${json}=        evaluate       json.loads('''${data}''')      json
        set to dictionary      ${json}     serviceInstanceID=${nssiId}
        ${data}=      evaluate       json.dumps(${json})       json
        &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
        ${nssi_deallocation_request}=      DELETE On Session    api_handler_session    /onap/so/infra/3gppservices/v1/deAllocate    data=${data}    headers=${headers}
        Log To Console      Received status code: ${nssi_deallocation_request.status_code}
        ${nssi_deallocation_request_json_response}=      Evaluate     json.loads(r"""${nssi_deallocation_request.content}""", strict=False)    json
        ${jobId}=          Set Variable         ${nssi_deallocation_request_json_response}[jobId]

        Create Session   nssmf_adapter_session  http://${REPO_IP}:8075
        ${nssmf_data}=    Get Binary File       ${CURDIR}${/}data${/}nssmf_adapter_deallocate_request.json
        &{headers}=  Create Dictionary    Authorization=Basic bXNvX2FkbWluOnBhc3N3b3JkMSQ=    Content-Type=application/json    Accept=application/json

        FOR    ${INDEX}    IN RANGE    ${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}
           ${nssmf_deallocation_request}=      POST On Session    nssmf_adapter_session    /api/rest/provMns/v1/NSS/jobs/${jobId}    data=${nssmf_data}    headers=${headers}
           Run Keyword If  '${nssmf_deallocation_request.status_code}' == '200'  log to console   \nexecuted with expected result
           log to console      ${nssmf_deallocation_request.content}
           ${nssmf_deallocation_response}=    Evaluate     json.loads(r"""${nssmf_deallocation_request.content}""", strict=False)    json
           ${actual_request_state}=     SET VARIABLE       ${nssmf_deallocation_response}[responseDescriptor][status]
           Log To Console    Received actual repsonse status:${actual_request_state}
           RUN KEYWORD IF   '${actual_request_state}' == 'finished'      Exit For Loop
           log to console  Will try again after ${SLEEP_INTERVAL_SEC} seconds
           SLEEP   ${SLEEP_INTERVAL_SEC}s
        END
      
        Log To Console     final repsonse status received: ${actual_request_state}
        Run Keyword If  '${actual_request_state}' == 'finished'  log to console   \nexecuted with expected result
        Should Be Equal As Strings    '${actual_request_state}'    'finished'

	
