*** Settings ***
Library           Collections
Library           Process
Library           RequestsLibrary
Library           String
Library           OperatingSystem

Suite Teardown  Delete All Sessions

*** Variables ***
${SLICE_ANALYSIS_MS_BASE_URL}             http://${SLICE_ANALYSIS_MS_IP}:8080
${SLICE_CONFIG_ENDPOINT}                  ${SLICE_ANALYSIS_MS_BASE_URL}/api/v1/slices-config
${HEALTHCHECK_ENDPOINT}                   /healthcheck
${DMAAP_URL}                              http://${DMAAP_IP}:3904/events
${unauthenticated.DCAE_CL_OUTPUT}         /unauthenticated.DCAE_CL_OUTPUT/23/23
${POST_DMAAP_EVENT_FOR_ML_NOTIF_URL}      http://${DMAAP_IP}:3904/events/unauthenticated.ML_RESPONSE_TOPIC
${POST_DMAAP_EVENT_FOR_PM_NOTIF_URL}      http://${DMAAP_IP}:3904/events/unauthenticated.PERFORMANCE_MEASUREMENTS
&{headers}                                Content-Type=application/json


*** Test Cases ***

HealthCheck

        Create Session  sliceanalysisms  ${SLICE_ANALYSIS_MS_BASE_URL}
        ${resp}=  Get On Session  sliceanalysisms   ${HEALTHCHECK_ENDPOINT}
        Should Be Equal As Strings  ${resp.status_code}  200


Post ml notification to dmaap
        Create Session  dmaap  ${DMAAP_URL}
        ${headers}=    Create Dictionary    Content-Type    application/json
        ${data}=   Get File      ${TEST_ROBOT_DIR}/data/ml_response0.json
        ${response}=    Evaluate    requests.post('${POST_DMAAP_EVENT_FOR_ML_NOTIF_URL}', data=$data)
        Should Be Equal As Strings  ${response.status_code}  200


Verify ml notification trigger
        Create Session  dmaap  ${DMAAP_URL}
        FOR    ${i}    IN RANGE   30
                ${result}=  Get On Session  dmaap   ${unauthenticated.DCAE_CL_OUTPUT}
                Exit For Loop If    ${result.json()} != @{EMPTY}
                Log     Waiting for slice-analysis-ms to handle trigger...         console=${True}
                Sleep   20s
        END
        ${expected_string}=   Get File            ${TEST_ROBOT_DIR}/data/expected_ml_payload0.json
        ${expected_payload}=    Evaluate     json.loads("""${expected_string}""")     json
        ${result}=  Convert To String  ${result.content}
        ${result_string}=    Get Substring    ${result}  2    -2
        ${actual_data}=      Evaluate     json.loads("""${result_string}""")     json
        ${actual_payload_str}=    Set Variable     ${actual_data['payload']}
        ${actual_payload}=       Evaluate     json.loads("""${actual_payload_str}""")     json
        set to dictionary    ${expected_payload['additionalProperties']['nsiInfo']}   nsiId=${actual_payload['additionalProperties']['nsiInfo']['nsiId']}
        Should Be True   """${actual_payload}""".strip() == """${expected_payload}""".strip()

Post pm notification-1 to dmaap
        ${data1}=   Get File      ${TEST_ROBOT_DIR}/data/performance_notification_1.json
        ${data2}=   Get File      ${TEST_ROBOT_DIR}/data/performance_notification_3.json
        ${data3}=   Get File      ${TEST_ROBOT_DIR}/data/performance_notification_2.json
        ${data4}=   Get File      ${TEST_ROBOT_DIR}/data/performance_notification_4.json
        ${data5}=   Get File      ${TEST_ROBOT_DIR}/data/performance_notification_5.json
        ${data6}=   Get File      ${TEST_ROBOT_DIR}/data/performance_notification_6.json
        FOR    ${j}    IN RANGE   4
                ${response1}=    Evaluate    requests.post('${POST_DMAAP_EVENT_FOR_PM_NOTIF_URL}', data=$data1)
                ${response2}=    Evaluate    requests.post('${POST_DMAAP_EVENT_FOR_PM_NOTIF_URL}', data=$data2)
                ${response3}=    Evaluate    requests.post('${POST_DMAAP_EVENT_FOR_PM_NOTIF_URL}', data=$data3)
                ${response4}=    Evaluate    requests.post('${POST_DMAAP_EVENT_FOR_PM_NOTIF_URL}', data=$data4)
                ${response5}=    Evaluate    requests.post('${POST_DMAAP_EVENT_FOR_PM_NOTIF_URL}', data=$data5)
                ${response6}=    Evaluate    requests.post('${POST_DMAAP_EVENT_FOR_PM_NOTIF_URL}', data=$data6)
                Sleep   20s
        END
        Should Be Equal As Strings  ${response1.status_code}  200
        Should Be Equal As Strings  ${response2.status_code}  200
        Should Be Equal As Strings  ${response3.status_code}  200
        Should Be Equal As Strings  ${response4.status_code}  200
        Should Be Equal As Strings  ${response5.status_code}  200
        Should Be Equal As Strings  ${response6.status_code}  200

Verify pm notification-1 trigger
        Create Session  dmaap  ${DMAAP_URL}
        FOR    ${i}    IN RANGE   20
                ${result}=  Get On Session  dmaap   ${unauthenticated.DCAE_CL_OUTPUT}
                Exit For Loop If    ${result.json()} != @{EMPTY}
                Log     Waiting for sliceanalysisms to handle trigger...         console=${True}
                Sleep   30s
        END
        ${expected_string}=   Get File            ${TEST_ROBOT_DIR}/data/expected_payload_pm0.json
        ${expected_payload}=    Evaluate     json.loads("""${expected_string}""")     json
        ${result}=  Convert To String  ${result.content}
        ${result_string}=    Get Substring    ${result}  2    -2
        ${actual_data}=      Evaluate     json.loads("""${result_string}""")     json
        ${actual_payload_str}=    Set Variable     ${actual_data['payload']}
        ${actual_payload}=       Evaluate     json.loads("""${actual_payload_str}""")     json
        set to dictionary    ${expected_payload['additionalProperties']['nsiInfo']}   nsiId=${actual_payload['additionalProperties']['nsiInfo']['nsiId']}
        set to dictionary    ${expected_payload['additionalProperties']['resourceConfig']}   data=${actual_payload['additionalProperties']['resourceConfig']['data']}
        Should Be True   """${actual_payload}""".strip() == """${expected_payload}""".strip()


Verify slice utilization respose
        ${data}=      Get File       ${TEST_ROBOT_DIR}/data/slice_config_request.json
        ${result}=    Evaluate       requests.get('${SLICE_CONFIG_ENDPOINT}', data=$data, headers=${headers})
        ${expected_slice_config}=    Get File            ${TEST_ROBOT_DIR}/data/slice_config_response.json
        ${actual_slice_config}=  Convert To String  ${result.content}
        Should Be True   """${actual_slice_config}""".strip() == """${expected_slice_config}""".strip()
