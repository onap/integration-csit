*** Settings ***
Documentation	  Testing DCAE VES Listener with various event feeds from VoLTE, vDNS, vFW and cCPE use scenarios
Library     RequestsLibrary
Library           OperatingSystem
Library           Collections
Library           DcaeLibrary
Resource          resources/dcae_keywords.robot
Resource          ../../common.robot
Resource          resources/dcae_properties.robot
Test Setup        Cleanup VES Events
Suite Setup       Run keywords  VES Collector Suite Setup DMaaP  Create sessions  Create header
Suite Teardown    VES Collector Suite Shutdown DMaaP    

*** Variables ***
${VESC_URL_HTTPS}                        https://%{VESC_IP}:8443
${VESC_URL}                              http://%{VESC_IP}:8080
${VES_ANY_EVENT_PATH}                    /eventListener/v5
${VES_BATCH_EVENT_PATH}             	 /eventListener/v5/eventBatch
${VES_THROTTLE_STATE_EVENT_PATH}         /eventListener/v5/clientThrottlingState
${VES_ENDPOINT}                          /eventListener/v7
${VES_VALID_JSON_V7}                     %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves7_valid.json
${VES_INVALID_JSON_V7}                   %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves7_invalid.json
${EVENT_DATA_FILE}                       %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves_volte_single_fault_event.json
${EVENT_MEASURE_FILE}                    %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves_vfirewall_measurement.json
${EVENT_DATA_FILE_BAD}                   %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves_volte_single_fault_event_bad.json
${EVENT_BATCH_DATA_FILE}                 %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves_volte_fault_eventlist_batch.json
${EVENT_THROTTLING_STATE_DATA_FILE}      %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves_volte_fault_provide_throttle_state.json
${EVENT_PNF_REGISTRATION}                %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves_pnf_registration_event.json

#DCAE Health Check
${CONFIG_BINDING_URL}                    http://localhost:8443
${CB_HEALTHCHECK_PATH}                   /healthcheck
${CB_SERVICE_COMPONENT_PATH}             /service_component/
${VES_Service_Name1}                     dcae-controller-ves-collector
${VES_Service_Name2}                     ves-collector-not-exist

*** Test Cases ***

#No authorization tests

VES Collector HTTP Health Check
    [Tags]    DCAE-VESC-R1
    [Documentation]   Ves Collector Health Check
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=*/*     X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Get Request 	${suite_dcae_vesc_url_session} 	/healthcheck        headers=${headers}
    Should Be Equal As Strings 	${resp.status_code} 	200

Publish Single VES VNF Measurement Event
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event and expect 202 Response
    ${evtdata}=   Get Data From File   ${VES_VALID_JSON_V7}
    ${resp}=  Publish Event To VES Collector No Auth    ${VES_ENDPOINT}  ${evtdata}
    Log    Receive HTTP Status code ${resp.status_code}
    Should Be Equal As Strings 	${resp.status_code} 	202
    ${isEmpty}=   Is Json Empty    ${resp}
    Run Keyword If   '${isEmpty}' == False   Log  ${resp.json()}
    ${ret}=  DMaaP Message Receive    ab305d54-85b4-a31b-7db2-fb6b9e546015
    Should Be Equal As Strings    ${ret}    true


Publish Single VES VNF Measurement Event with wrong JSON
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event and expect 400 Response
    ${evtdata}=   Get Data From File   ${VES_INVALID_JSON_V7}
    ${resp}=  Publish Event To VES Collector No Auth  ${VES_ENDPOINT}  ${evtdata}
    Log    Receive HTTP Status code ${resp.status_code}
    Should Be Equal As Strings 	${resp.status_code} 	400
    ${isEmpty}=   Is Json Empty    ${resp}
    Run Keyword If   '${isEmpty}' == False   Log  ${resp.json()}

Publish Single VES VNF Measurement Event over HTTPS
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event and expect ConnectionError
    ${evtdata}=   Get Data From File   ${VES_VALID_JSON_V7}
    ${err_msg}=  Run Keyword And Expect Error  ConnectionError:*   Publish Event To VES Collector   ${VES_ENDPOINT}  ${evtdata}
    Should Contain  ${err_msg}  Errno 111
    Log  Recieved error message ${err_msg}

Publish Single VES VoLTE Fault Event
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event and expect 202 Response
    ${evtdata}=   Get Data From File   ${EVENT_DATA_FILE}
    ${resp}=  Publish Event To VES Collector No Auth    ${VES_ANY_EVENT_PATH}  ${evtdata}
    Log    Receive HTTP Status code ${resp.status_code}
    Should Be Equal As Strings 	${resp.status_code} 	202
    ${isEmpty}=   Is Json Empty    ${resp}
    Run Keyword If   '${isEmpty}' == False   Log  ${resp.json()}
    ${ret}=  DMaaP Message Receive    ab305d54-85b4-a31b-7db2-fb6b9e546015
    Should Be Equal As Strings    ${ret}    true

Publish Single VES VNF Measurement Event
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event and expect 202 Response
    ${evtdata}=   Get Data From File   ${EVENT_MEASURE_FILE}
    ${resp}=  Publish Event To VES Collector No Auth    ${VES_ANY_EVENT_PATH}  ${evtdata}
    Log    Receive HTTP Status code ${resp.status_code}
    Should Be Equal As Strings 	${resp.status_code} 	202
    ${isEmpty}=   Is Json Empty    ${resp}
    Run Keyword If   '${isEmpty}' == False   Log  ${resp.json()}
    ${ret}=  DMaaP Message Receive    0b2b5790-3673-480a-a4bd-5a00b88e5af6
    Should Be Equal As Strings    ${ret}    true

Publish VES VoLTE Fault Batch Events
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post batched events and expect 202 Response
    ${evtdata}=   Get Data From File   ${EVENT_BATCH_DATA_FILE}
    ${resp}=  Publish Event To VES Collector No Auth    ${VES_BATCH_EVENT_PATH}  ${evtdata}
    Log    Receive HTTP Status code ${resp.status_code}
    Should Be Equal As Strings 	${resp.status_code} 	202
    ${isEmpty}=   Is Json Empty    ${resp}
    Run Keyword If   '${isEmpty}' == False   Log  ${resp.json()}
    ${ret}=  DMaaP Message Receive    ab305d54-85b4-a31b-7db2-fb6b9e546025
    Should Be Equal As Strings    ${ret}    true


Publish VES Event With Invalid Method
    [Tags]    DCAE-VESC-R1
    [Documentation]    Use invalid Put instead of Post method to expect 405 response
    ${evtdata}=   Get Data From File   ${EVENT_DATA_FILE}
    Log   Send HTTP Request with invalid method Put instead of Post
    ${resp}=  Publish Event To VES Collector With Put Method No Auth  ${VES_ANY_EVENT_PATH}  ${evtdata}
    Log    Receive HTTP Status code ${resp.status_code}
    Should Be Equal As Strings 	${resp.status_code} 	405
    ${isEmpty}=   Is Json Empty    ${resp}
    Run Keyword If   '${isEmpty}' == False   Log  ${resp.json()}

Publish VES Event With Invalid URL Path
    [Tags]    DCAE-VESC-R1
    [Documentation]    Use invalid url path to expect 404 response
    ${evtdata}=   Get Data From File   ${EVENT_DATA_FILE}
    Log   Send HTTP Request with invalid /listener/v5/ instead of /eventListener/v5 path
    ${resp}=  Publish Event To VES Collector No Auth    /listener/v5/  ${evtdata}
    Log    Receive HTTP Status code ${resp.status_code}
    Should Be Equal As Strings 	${resp.status_code} 	404
    ${isEmpty}=   Is Json Empty    ${resp}
    Run Keyword If   '${isEmpty}' == False   Log  ${resp.json()}

Publish PNF Registration Event
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post PNF registration event and expect 200 Response
    ${evtdata}=   Get Data From File   ${EVENT_PNF_REGISTRATION}
    ${resp}=  Publish Event To VES Collector No Auth    ${VES_ANY_EVENT_PATH}  ${evtdata}
    Log    Receive HTTP Status code ${resp.status_code}
    Should Be Equal As Strings 	${resp.status_code} 	202
    ${isEmpty}=   Is Json Empty    ${resp}
    Run Keyword If   '${isEmpty}' == False   Log  ${resp.json()}
    ${ret}=  DMaaP Message Receive    QTFCOC540002E-reg
    Should Be Equal As Strings    ${ret}    true


# Auth by certificate and basic auth username / password

Enable VESC HTTPS with certBasicAuth
    [Tags]    DCAE-VESC-R1
    [Documentation]  Enable VESC Https and Authentication and Run Health Check
    Enable VESC with certBasicAuth
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=*/*     X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Get Request 	${suite_dcae_vesc_url_session} 	/healthcheck        headers=${headers}
    Should Be Equal As Strings 	${resp.status_code} 	200


Publish Single VES Fault Event Over HTTPS
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event and expect 202 Response
    ${evtdata}=   Get Data From File   ${EVENT_DATA_FILE}
    Log  Login User=${VESC_HTTPS_USER}, Pd=${VESC_HTTPS_PD}
    ${resp}=  Publish Event To VES Collector    ${VES_ANY_EVENT_PATH}  ${evtdata}
    Log    Receive HTTPS Status code ${resp.status_code}
    Should Be Equal As Strings 	${resp.status_code} 	202
    ${isEmpty}=   Is Json Empty    ${resp}
    Run Keyword If   '${isEmpty}' == False   Log  ${resp.json()}
    ${ret}=  DMaaP Message Receive    ab305d54-85b4-a31b-7db2-fb6b9e546015
    Should Be Equal As Strings    ${ret}    true

Publish Single VES Measurement Event Over HTTPS
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event and expect 202 Response
    ${evtdata}=   Get Data From File   ${EVENT_MEASURE_FILE}
    ${resp}=  Publish Event To VES Collector  ${VES_ANY_EVENT_PATH}  ${evtdata}
    Log    Receive HTTPS Status code ${resp.status_code}
    Should Be Equal As Strings 	${resp.status_code} 	202
    ${isEmpty}=   Is Json Empty    ${resp}
    Run Keyword If   '${isEmpty}' == False   Log  ${resp.json()}
    ${ret}=  DMaaP Message Receive    0b2b5790-3673-480a-a4bd-5a00b88e5af6
    Should Be Equal As Strings    ${ret}    true

Publish VES Fault Batch Events Over HTTPS
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post batched events and expect 202 Response
    ${evtdata}=   Get Data From File   ${EVENT_BATCH_DATA_FILE}
    ${resp}=  Publish Event To VES Collector  ${VES_BATCH_EVENT_PATH}  ${evtdata}
    Should Be Equal As Strings 	${resp.status_code} 	202
    ${isEmpty}=   Is Json Empty    ${resp}
    Run Keyword If   '${isEmpty}' == False   Log  ${resp.json()}
    ${ret}=  DMaaP Message Receive    ab305d54-85b4-a31b-7db2-fb6b9e546025
    Should Be Equal As Strings    ${ret}    true


Publish VES Event With Invalid URL Path HTTPS
    [Tags]    DCAE-VESC-R1
    [Documentation]    Use invalid url path to expect 404 response
    ${evtdata}=   Get Data From File   ${EVENT_DATA_FILE}
    Log   Send HTTP Request with invalid /eventlistener/v5/ instead of /eventListener/v5 path
    ${resp}=  Publish Event To VES Collector  /eventlistener/v5  ${evtdata}
    Log    Receive HTTPS Status code ${resp.status_code}
    Should Be Equal As Strings 	${resp.status_code} 	404
    ${isEmpty}=   Is Json Empty    ${resp}
    Run Keyword If   '${isEmpty}' == False   Log  ${resp.json()}

Publish Single VES VNF Measurement Event over HTTP
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event over HTTP and expect 400 Response
    ${evtdata}=   Get Data From File   ${VES_VALID_JSON_V7}
    ${resp}=  Publish Event To VES Collector No Auth    ${VES_ENDPOINT}  ${evtdata}
    Log    Receive HTTP Status code ${resp.status_code}
    Should Be Equal As Strings 	${resp.status_code} 	400
    ${isEmpty}=   Is Json Empty    ${resp}
    Run Keyword If   '${isEmpty}' == False   Log  ${resp.json()}


Publish Single VES VNF Measurement Event over HTTPS
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event and expect 202 Response
    ${evtdata}=   Get Data From File   ${VES_VALID_JSON_V7}
    ${resp}=  Publish Event To VES Collector   ${VES_ENDPOINT}  ${evtdata}
    Log    Receive HTTPS Status code ${resp.status_code}
    Should Be Equal As Strings 	${resp.status_code} 	202
    ${isEmpty}=   Is Json Empty    ${resp}
    Run Keyword If   '${isEmpty}' == False   Log  ${resp.json()}
    ${ret}=  DMaaP Message Receive    ab305d54-85b4-a31b-7db2-fb6b9e546015
    Should Be Equal As Strings    ${ret}    true

Publish Single VES VNF Measurement Event over HTTPS with wrong JSON
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event and expect 400 Response
    ${evtdata}=   Get Data From File   ${VES_INVALID_JSON_V7}
    ${resp}=  Publish Event To VES Collector   ${VES_ENDPOINT}  ${evtdata}
    Log    Receive HTTPS Status code ${resp.status_code}
    Should Be Equal As Strings 	${resp.status_code} 	400
    ${isEmpty}=   Is Json Empty    ${resp}
    Run Keyword If   '${isEmpty}' == False   Log  ${resp.json()}

Publish Single VES VNF Measurement Event Wrong Auth
    [Tags]  DCAE-VESC-R1
    [Documentation]  Post single event and expect 401 response
    ${evtdata}=  Get Data From File  ${VES_VALID_JSON_V7}
    ${resp}=  Publish Event To VES Collector With Wrong Auth   ${VES_ENDPOINT}  ${evtdata}
    Log    Receive HTTPS Status code ${resp.status_code}
    Should Be Equal As Strings  ${resp.status_code}  401
    ${isEmpty}=   Is Json Empty    ${resp}
    Run Keyword If   '${isEmpty}' == False   Log  ${resp.json()}

Publish Single VES VNF Measurement Event Cert
    [Tags]  DCAE-VESC-R1
    [Documentation]  Post single event and expect 202 response
    ${evtdata}=  Get Data From File  ${VES_VALID_JSON_V7}
    ${resp}=  Publish Event To VES Collector With Cert  ${VES_ENDPOINT}  ${evtdata}
    Log    Receive HTTPS Status code ${resp.status_code}
    Should Be Equal As Strings 	${resp.status_code} 	202
    ${isEmpty}=   Is Json Empty    ${resp}
    Run Keyword If   '${isEmpty}' == False   Log  ${resp.json()}
    ${ret}=  DMaaP Message Receive    ab305d54-85b4-a31b-7db2-fb6b9e546015
    Should Be Equal As Strings    ${ret}    true

Publish Single VES VNF Measurement Event Wrong Cert
    [Tags]  DCAE-VESC-R1
    [Documentation]  Post single event and expect SSLError with bad handshake
    ${evtdata}=  Get Data From File  ${VES_VALID_JSON_V7}
    ${err_msg}=  Run Keyword And Expect Error  SSLError:*  Publish Event To VES Collector With Wrong Cert  ${VES_ENDPOINT}  ${evtdata}
    Should Contain  ${err_msg}  bad handshake
    Should Contain  ${err_msg}  certificate unknown
    Log  Recieved error message ${err_msg}

Publish Single VES VNF Measurement Event Without Auth And Cert
    [Tags]  DCAE-VESC-R1
    [Documentation]  Post single event and expect 401 response
    ${evtdata}=  Get Data From File  ${VES_VALID_JSON_V7}
    ${resp}=  Publish Event To VES Collector Without Auth And Cert  ${VES_ENDPOINT}  ${evtdata}
    Log    Receive HTTPS Status code ${resp.status_code}
    Should Be Equal As Strings  ${resp.status_code}  401
    ${isEmpty}=   Is Json Empty    ${resp}
    Run Keyword If   '${isEmpty}' == False   Log  ${resp.json()}
