*** Settings ***
Library           Collections
Library           Process
Library           RequestsLibrary
Library           String
Library           OperatingSystem

Suite Teardown  Delete All Sessions

*** Variables ***
${SLICE_ANALYSIS_MS_BASE_URL}             http://${SLICE_ANALYSIS_MS_IP}:8080
${HEALTHCHECK_ENDPOINT}                   /healthcheck
${DMAAP_URL}                              http://${DMAAP_IP}:3904/events
${unauthenticated.DCAE_CL_OUTPUT}         /unauthenticated.DCAE_CL_OUTPUT/23/23
${POST_DMAAP_EVENT_FOR_ML_NOTIF_URL}      http://${DMAAP_IP}:3904/events/unauthenticated.ML_RESPONSE_TOPIC
${POST_DMAAP_EVENT_FOR_PM_NOTIF_URL}      http://${DMAAP_IP}:3904/events/unauthenticated.PERFORMANCE_MEASUREMENTS


*** Test Cases ***

HealthCheck

        Create Session  sliceanalysisms  ${SLICE_ANALYSIS_MS_BASE_URL}
        ${resp}=  Get Request   sliceanalysisms   ${HEALTHCHECK_ENDPOINT}
        Should Be Equal As Strings  ${resp.status_code}  200


Post ml notification to dmaap
	Create Session  dmaap  ${DMAAP_URL}
	${headers}=    Create Dictionary    Content-Type    application/json
        ${data}=   Get File      ${TEST_ROBOT_DIR}/data/ml_response.json
        ${response}=    Evaluate    requests.post('${POST_DMAAP_EVENT_FOR_ML_NOTIF_URL}', data=$data)
	Should Be Equal As Strings  ${response.status_code}  200


Verify ml notification trigger
	Create Session  dmaap  ${DMAAP_URL}
        FOR    ${i}    IN RANGE   30
		${result}=  Get Request  dmaap   ${unauthenticated.DCAE_CL_OUTPUT}
		Exit For Loop If    ${result.json()} != @{EMPTY}
		Log     Waiting for slice-analysis-ms to handle trigger...         console=${True}
		Sleep   5s
	END
        ${expected_string}=   Get File            ${TEST_ROBOT_DIR}/data/expected_ml_response.json
        ${result}=  Convert To String  ${result.content}
        ${result_string}=    Get Substring    ${result}    2    -2
        ${actual_data}=	     Evaluate     json.loads("""${result_string}""")    json
        ${expected_data}=	Evaluate     json.loads("""${expected_string}""")    json
        set to dictionary    ${expected_data}   requestID=${actual_data['requestID']}
        set to dictionary    ${expected_data}   closedLoopAlarmStart=${actual_data['closedLoopAlarmStart']}
        set to dictionary    ${expected_data['payload']['additionalProperties']['nsiInfo']}   nsiId=${actual_data['payload']['additionalProperties']['nsiInfo']['nsiId']}
        Should Be True   """${actual_data}""".strip() == """${expected_data}""".strip()


Post pm notification-1 to dmaap
	${data}=   Get File      ${TEST_ROBOT_DIR}/data/performance_notification1.json
        FOR    ${i}    IN RANGE   6
		${response}=    Evaluate    requests.post('${POST_DMAAP_EVENT_FOR_PM_NOTIF_URL}', data=$data)
        END
        Should Be Equal As Strings  ${response.status_code}  200


Verify pm notification-1 trigger 
	Create Session  dmaap  ${DMAAP_URL}
	FOR    ${i}    IN RANGE   20
		${result}=  Get Request  dmaap   ${unauthenticated.DCAE_CL_OUTPUT}
		Exit For Loop If    ${result.json()} != @{EMPTY}
		Log     Waiting for sliceanalysisms to handle trigger...         console=${True}
		Sleep   30s
	END
	${expected_string}=   Get File            ${TEST_ROBOT_DIR}/data/expected_pm1.json
	${result}=  Convert To String  ${result.content}
	${result_string}=    Get Substring    ${result}    2    -2
	${actual_data}=    Evaluate     json.loads("""${result_string}""")    json
        ${expected_data}=	Evaluate     json.loads("""${expected_string}""")    json
        set to dictionary    ${expected_data}   requestID=${actual_data['requestID']}
        set to dictionary    ${expected_data}   closedLoopAlarmStart=${actual_data['closedLoopAlarmStart']}
        set to dictionary    ${expected_data['payload']['additionalProperties']['nsiInfo']}   nsiId=${actual_data['payload']['additionalProperties']['nsiInfo']['nsiId']}
	Should Be True   """${actual_data}""".strip() == """${expected_data}""".strip()



Post pm notification-2 to dmaap
        ${data}=   Get File      ${TEST_ROBOT_DIR}/data/performance_notification3.json
	${data1}=   Get File      ${TEST_ROBOT_DIR}/data/performance_notification4.json
	${data2}=   Get File      ${TEST_ROBOT_DIR}/data/performance_notification5.json
	${data3}=   Get File      ${TEST_ROBOT_DIR}/data/performance_notification6.json
	${data4}=   Get File      ${TEST_ROBOT_DIR}/data/performance_notification7.json
	${data5}=   Get File      ${TEST_ROBOT_DIR}/data/performance_notification8.json
        FOR    ${i}    IN RANGE   6
                ${response}=    Evaluate    requests.post('${POST_DMAAP_EVENT_FOR_PM_NOTIF_URL}', data=$data)
		${response1}=    Evaluate    requests.post('${POST_DMAAP_EVENT_FOR_PM_NOTIF_URL}', data=$data1)
		${response2}=    Evaluate    requests.post('${POST_DMAAP_EVENT_FOR_PM_NOTIF_URL}', data=$data2)
		${response3}=    Evaluate    requests.post('${POST_DMAAP_EVENT_FOR_PM_NOTIF_URL}', data=$data3)
		${response4}=    Evaluate    requests.post('${POST_DMAAP_EVENT_FOR_PM_NOTIF_URL}', data=$data4)
		${response5}=    Evaluate    requests.post('${POST_DMAAP_EVENT_FOR_PM_NOTIF_URL}', data=$data5)
        END
        Should Be Equal As Strings  ${response.status_code}  200
	Should Be Equal As Strings  ${response1.status_code}  200
	Should Be Equal As Strings  ${response2.status_code}  200
	Should Be Equal As Strings  ${response3.status_code}  200
	Should Be Equal As Strings  ${response4.status_code}  200
	Should Be Equal As Strings  ${response5.status_code}  200


Verify pm notification-2 trigger
        Create Session  dmaap  ${DMAAP_URL}
        FOR    ${i}    IN RANGE   20
                ${result}=  Get Request  dmaap   ${unauthenticated.DCAE_CL_OUTPUT}
                Exit For Loop If    ${result.json()} != @{EMPTY}
                Log     Waiting for sliceanalysisms to handle trigger...         console=${True}
                Sleep   30s
        END
	${expected_string}=   Get File            ${TEST_ROBOT_DIR}/data/expected_pm.json
        ${result}=  Convert To String  ${result.content}
        ${result_string}=    Get Substring    ${result}    2    -2
        ${actual_data}=    Evaluate     json.loads("""${result_string}""")    json
        ${expected_data}=       Evaluate     json.loads("""${expected_string}""")    json
        set to dictionary    ${expected_data}   requestID=${actual_data['requestID']}
        set to dictionary    ${expected_data}   closedLoopAlarmStart=${actual_data['closedLoopAlarmStart']}
        set to dictionary    ${expected_data['payload']['additionalProperties']['nsiInfo']}   nsiId=${actual_data['payload']['additionalProperties']['nsiInfo']['nsiId']}
        Should Be True   """${actual_data}""".strip() == """${expected_data}""".strip()
