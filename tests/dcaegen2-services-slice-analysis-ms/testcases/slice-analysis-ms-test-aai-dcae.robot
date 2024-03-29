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
${unauthenticated.DCAE_CL_OUTPUT}         /unauthenticated.DCAE_CL_OUTPUT/24/24
${AAI_EVENT_OUTPUT}                       /AAI-EVENT/24/24
${POST_DMAAP_EVENT_FOR_AAI_EVENT_URL}     http://${DMAAP_IP}:3904/events/AAI-EVENT
${VESCOLLECTOR_URL}                       https://${VESCOLLECTOR_IP}:8443/eventListener/v7
${AAI_NETWORK_POLICY_URL}                 https://${AAI_RESOURCES_IP}:8447/aai/v24/network/network-policies/network-policy/933dacc1-56e0-4b94-8808-4d099ebc4de5
*** Test Cases ***

HealthCheck

        Create Session  sliceanalysisms  ${SLICE_ANALYSIS_MS_BASE_URL}
        ${resp}=  Get Request   sliceanalysisms   ${HEALTHCHECK_ENDPOINT}
        Should Be Equal As Strings  ${resp.status_code}  200

Post pm ves notification to vescollector

        Log     posting 6 VES_Notification         console=${True}
        Create Session  ves  ${VESCOLLECTOR_URL}
        ${headers}=    Create Dictionary    Content-Type=application/json
        ${user_pass}=    Evaluate   ('sample1', 'sample1')
        ${data}=   Get File      ${TEST_ROBOT_DIR}/data/ves_notification_pmdata.json
        FOR    ${i}    IN RANGE   6
                ${response}=    Evaluate    requests.post('${VESCOLLECTOR_URL}', headers=${headers}, data=$data, auth=${user_pass}, verify=False)
                Should Be Equal As Strings  ${response.status_code}  202
                Sleep   2s
        END

Verify periodic checking from dmaap

        Create Session  dmaap  ${DMAAP_URL}
        FOR    ${i}    IN RANGE   30
                ${result}=  Get Request  dmaap   ${unauthenticated.DCAE_CL_OUTPUT}
                Exit For Loop If    ${result.json()} != @{EMPTY}
                Log     Waiting for slice-analysis-ms to handle periodic checking...         console=${True}
                Sleep   5s
        END
        ${expected_string}=   Get File            ${TEST_ROBOT_DIR}/data/expected_payload_ccvpn1.json
        ${expected_payload}=    Evaluate     json.loads("""${expected_string}""")     json
        ${result}=  Convert To String  ${result.content}
        ${result_string}=    Get Substring    ${result}  2    -2
        ${result_string}=    RemoveExtraByte    ${result_string}
        ${actual_data}=      Evaluate     json.loads("""${result_string}""")     json
        ${actual_payload_str}=    Set Variable     ${actual_data['payload']}
        ${actual_payload}=       Evaluate     json.loads("""${actual_payload_str}""")     json
        Should Be True   """${actual_payload}""".strip() == """${expected_payload}""".strip()


Post ccvpn modification to dmaap

        ${headers}=    Create Dictionary    Content-Type=application/merge-patch+json    X-HTTP-Method-Override=PATCH    Accept=application/json    X-FromAppId=AAI    X-TransactionId=808b54e3-e563-4144-a1b9-e24e2ed93d4f
        ${user_pass}=    Evaluate   ('AAI', 'AAI')
        ${data}=   Get File      ${TEST_ROBOT_DIR}/data/network_policy_after.json
        ${response}=    Evaluate    requests.post('${AAI_NETWORK_POLICY_URL}', headers=${headers}, data=$data, auth=${user_pass}, verify=False)
        Should Be Equal As Strings  ${response.status_code}  200
        Log     Wait 20s before posting AAI-EVENT         console=${True}
        Sleep   20s
        Log     posting AAI-EVENT         console=${True}
        Create Session  dmaap  ${DMAAP_URL}
        ${headers}=    Create Dictionary    Content-Type    application/json
        ${data}=   Get File      ${TEST_ROBOT_DIR}/data/aai_event_svc_modification_bw.json
        ${response}=    Evaluate    requests.post('${POST_DMAAP_EVENT_FOR_AAI_EVENT_URL}', data=$data)
        Should Be Equal As Strings  ${response.status_code}  200


Verify ccvpn modification from dmaap

        Create Session  dmaap  ${DMAAP_URL}
        FOR    ${i}    IN RANGE   30
                ${result}=  Get Request  dmaap   ${unauthenticated.DCAE_CL_OUTPUT}
                Exit For Loop If    ${result.json()} != @{EMPTY}
                Log     Waiting for slice-analysis-ms to handle trigger...         console=${True}
                Sleep   5s
        END
        ${expected_string}=   Get File            ${TEST_ROBOT_DIR}/data/expected_payload_ccvpn0.json
        ${expected_payload}=    Evaluate     json.loads("""${expected_string}""")     json
        ${result}=  Convert To String  ${result.content}
        ${result_string}=    Get Substring    ${result}  2    -2
        ${result_string}=    RemoveExtraByte    ${result_string}
        ${actual_data}=      Evaluate     json.loads("""${result_string}""")     json
        ${actual_payload_str}=    Set Variable     ${actual_data['payload']}
        ${actual_payload}=       Evaluate     json.loads("""${actual_payload_str}""")     json
        Should Be True   """${actual_payload}""".strip() == """${expected_payload}""".strip()

*** Keywords ***
Provided precondition
    Setup system under test

RemoveExtraByte	
    [Arguments]     ${result_string}
    ${result_string}=    Get Substring     ${result_string}    2       -2
    ${result_string}=    Replace String    ${result_string}    \\\"    \"
    ${result_string}=    Replace String    ${result_string}    \\\\    \\
    [Return]        ${result_string}

