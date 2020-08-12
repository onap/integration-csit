*** Settings ***
Library           Collections
Library           Process
Library           RequestsLibrary
Library           String
Library           OperatingSystem

Suite Teardown  Delete All Sessions

*** Variables ***
${SON_HANDLER_BASE_URL}                   http://${SONHMS_IP}:8080
${HEALTHCHECK_ENDPOINT}                   /healthcheck
${DMAAP_URL}                              http://${DMAAP_IP}:3904/events
${unauthenticated.DCAE_CL_OUTPUT}         /unauthenticated.DCAE_CL_OUTPUT/23/23
${POST_DMAAP_EVENT_FOR_FM_NOTIF_URL}      http://${DMAAP_IP}:3904/events/unauthenticated.SEC_FAULT_OUTPUT
${POST_DMAAP_EVENT_FOR_PM_NOTIF_URL}      http://${DMAAP_IP}:3904/events/unauthenticated.VES_MEASUREMENT_OUTPUT
${POST_DMAAP_EVENT_FOR_POLICY_RESPONSE}   http://${DMAAP_IP}:3904/events/DCAE_CL_RSP

*** Test Cases ***

HealthCheck

        Create Session  sonhms  ${SON_HANDLER_BASE_URL}
        ${resp}=  Get Request   sonhms  ${HEALTHCHECK_ENDPOINT}
        Should Be Equal As Strings  ${resp.status_code}  200


Post fm notification to dmaap
	Create Session  dmaap  ${DMAAP_URL}
	${headers}=    Create Dictionary    Content-Type    application/json
        ${data}=   Get File      ${TEST_ROBOT_DIR}/data/fault_notification.json
        ${response}=    Evaluate    requests.post('${POST_DMAAP_EVENT_FOR_FM_NOTIF_URL}', data=$data)
	Should Be Equal As Strings  ${response.status_code}  200


Verify fm notification trigger in sonhms
	Create Session  dmaap  ${DMAAP_URL}
        FOR    ${i}    IN RANGE   10
		${result}=  Get Request  dmaap   ${unauthenticated.DCAE_CL_OUTPUT}
		Exit For Loop If    ${result.json()} != @{EMPTY}
		Log     Waiting for sonhms to handle trigger...         console=${True}
		Sleep   30s
	END
        ${expected_payload}=   Get File            ${TEST_ROBOT_DIR}/data/expected_payload_fm.json
        ${result}=  Convert To String  ${result.content}
        ${result_string}=    Get Substring    ${result}    2    -2
        ${actual_data}=    Evaluate     json.loads("""${result_string}""")    json
        ${actual_payload}=    Set Variable     ${actual_data['payload']}
        Should Be True   """${actual_payload}""".strip() == """${expected_payload}""".strip()


Post pm notification to dmaap
	${data}=   Get File      ${TEST_ROBOT_DIR}/data/performance_notification.json
	${response}=    Evaluate    requests.post('${POST_DMAAP_EVENT_FOR_PM_NOTIF_URL}', data=$data)
        Should Be Equal As Strings  ${response.status_code}  200


Verify pm notification trigger in sonhms
	Create Session  dmaap  ${DMAAP_URL}
	FOR    ${i}    IN RANGE   5
		${result}=  Get Request  dmaap   ${unauthenticated.DCAE_CL_OUTPUT}
		Exit For Loop If    ${result.json()} != @{EMPTY}
		Log     Waiting for sonhms to handle trigger...         console=${True}
		Sleep   30s
	END
	${expected_payload}=   Get File            ${TEST_ROBOT_DIR}/data/expected_payload_pm.json
	${result}=  Convert To String  ${result.content}
	${result_string}=    Get Substring    ${result}    2    -2
	${actual_data}=    Evaluate     json.loads("""${result_string}""")    json
	${actual_payload}=    Set Variable     ${actual_data['payload']}
	Should Be True   """${actual_payload}""".strip() == """${expected_payload}""".strip()


Post policy negative acknowledgement to dmaap
	${data}=   Get File      ${TEST_ROBOT_DIR}/data/negative_ack_from_policy.json
        FOR    ${i}    IN RANGE   3
           ${response}=    Evaluate    requests.post('${POST_DMAAP_EVENT_FOR_POLICY_RESPONSE}', data=$data)
        END
        Should Be Equal As Strings  ${response.status_code}  200


Oof trigger for fixed Pci cells
        Create Session  dmaap  ${DMAAP_URL}
        FOR    ${i}    IN RANGE   15
                ${result}=  Get Request  dmaap   ${unauthenticated.DCAE_CL_OUTPUT}
                Exit For Loop If    ${result.json()} != @{EMPTY}
                Log	Waiting for sonhms to handle trigger...		console=${True}
                Sleep   30s
        END
        ${expected_payload}=   Get File    ${TEST_ROBOT_DIR}/data/expected_payload_fm.json
        ${result}=  Convert To String  ${result.content}
        ${result_string}=    Get Substring    ${result}    2    -2
        ${actual_data}=    Evaluate     json.loads("""${result_string}""")    json
        ${actual_payload}=    Set Variable     ${actual_data['payload']}
        Should Be True   """${actual_payload}""".strip() == """${expected_payload}""".strip()
