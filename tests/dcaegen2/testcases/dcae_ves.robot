*** Settings ***
Documentation	  Testing DCAE VES Listener with various event feeds from VoLTE, vDNS, vFW and cCPE use scenarios
Library     RequestsLibrary
Library           OperatingSystem
Library           Collections
Library           DcaeLibrary
Resource          ./resources/dcae_keywords.robot
Test Setup        Cleanup VES Events
Suite Setup       Run keywords  VES Collector Suite Setup DMaaP  Create sessions  Create header
Suite Teardown    VES Collector Suite Shutdown DMaaP

*** Variables ***
${VESC_URL_HTTPS}                        https://%{VESC_IP}:8443
${VESC_URL}                              http://%{VESC_IP}:8080
${VES_ANY_EVENT_PATH}                    /eventListener/v5
${VES_BATCH_EVENT_PATH}             	 /eventListener/v5/eventBatch
${VES_THROTTLE_STATE_EVENT_PATH}         /eventListener/v5/clientThrottlingState
${VES_ENDPOINT_V7}                       /eventListener/v7
${VES_BATCH_EVENT_ENDPOINT_V7}           /eventListener/v7/eventBatch
${VES_VALID_JSON_V7}                     %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves7_valid.json
${VES_INVALID_JSON_V7}                   %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves7_invalid.json
${VES_VALID_BATCH_JSON_V7}               %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves7_batch_valid.json
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

#No authentication tests

VES Collector HTTP Health Check
    [Tags]    DCAE-VESC-R1
    [Documentation]   Run healthcheck
    Run Healthcheck

Publish Single VES VNF Measurement Event API V7
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with valid data to /eventListener/v7 endpoint and expect 202 Response
    Send Request And Validate Response  Publish Event To VES Collector No Auth  ${VES_ENDPOINT_V7}  ${VES_VALID_JSON_V7}  202  ab305d54-85b4-a31b-7db2-fb6b9e546015

Publish Single VES VNF Measurement Event with wrong JSON
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with invalid data to /eventListener/v7 endpoint and expect 400 Response
    Send Request And Validate Response  Publish Event To VES Collector No Auth  ${VES_ENDPOINT_V7}  ${VES_INVALID_JSON_V7}  400

Publish Single VES VNF Measurement Event with No Auth over HTTPS
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event over HTTPS with authentication disabled and expect ConnectionError
    @{err_content}  Create List  Errno 111
    Send Request And Expect Error  Publish Event To VES Collector  ${VES_ENDPOINT_V7}  ${VES_VALID_JSON_V7}  ConnectionError:*  @{err_content}

Publish Single VES VoLTE Fault Event
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with valid data to /eventListener/v5 endpoint and expect 202 Response
    Send Request And Validate Response  Publish Event To VES Collector No Auth  ${VES_ANY_EVENT_PATH}  ${EVENT_DATA_FILE}  202  ab305d54-85b4-a31b-7db2-fb6b9e546015

Publish Single VES VNF Measurement Event API V5
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single measurement event with valid data to /eventListener/v5 endpoint and expect 202 Response
    Send Request And Validate Response  Publish Event To VES Collector No Auth  ${VES_ANY_EVENT_PATH}  ${EVENT_MEASURE_FILE}  202  0b2b5790-3673-480a-a4bd-5a00b88e5af6

Publish VES VoLTE Fault Batch Events
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with valid data to /eventListener/v5/eventBatch endpoint and expect 202 Response
    Send Request And Validate Response  Publish Event To VES Collector No Auth  ${VES_BATCH_EVENT_PATH}  ${EVENT_BATCH_DATA_FILE}  202  ab305d54-85b4-a31b-7db2-fb6b9e546025

Publish VES Event With Invalid Method
    [Tags]    DCAE-VESC-R1
    [Documentation]    Use invalid Put instead of Post method to expect 405 response
    Log   Send HTTP Request with invalid method Put instead of Post
    Send Request And Validate Response  Publish Event To VES Collector With Put Method No Auth  ${VES_ANY_EVENT_PATH}  ${EVENT_DATA_FILE}  405

Publish VES Event With Invalid URL Path
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event to invalid url path and expect 404 response
    Log   Send HTTP Request with invalid /listener/v5/ instead of /eventListener/v5 path
    Send Request And Validate Response  Publish Event To VES Collector No Auth  /listener/v5/  ${EVENT_DATA_FILE}  404

Publish PNF Registration Event
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post PNF registration event and expect 200 Response
    Send Request And Validate Response  Publish Event To VES Collector No Auth  ${VES_ANY_EVENT_PATH}  ${EVENT_PNF_REGISTRATION}  202  QTFCOC540002E-reg

# Auth by certificate and basic auth username / password

Enable VESC HTTPS with certBasicAuth
    [Tags]    DCAE-VESC-R1
    [Documentation]  Enable VESC Https and Authentication and Run Health Check
    Enable VESC with certBasicAuth
    Run Healthcheck

Healthcheck with Outdated Cert
    [Tags]    DCAE-VESC-R1
    [Documentation]  Run healthcheck with outdated cert
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=*/*     X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${err_msg}=  Run Keyword And Expect Error  SSLError:*  Get Request 	${suite_dcae_vesc_url_https_outdated_cert_session} 	/healthcheck  headers=${headers}
    Should Contain  ${err_msg}  bad handshake
    Should Contain  ${err_msg}  certificate unknown
    Log  Recieved error message ${err_msg}

Publish Single VES Fault Event Over HTTPS
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with valid data to /eventListener/v5 endpoint over HTTPS and expect 202 Response
    Log  Login User=${VESC_HTTPS_USER}, Pd=${VESC_HTTPS_PD}
    Send Request And Validate Response  Publish Event To VES Collector  ${VES_ANY_EVENT_PATH}  ${EVENT_DATA_FILE}  202  ab305d54-85b4-a31b-7db2-fb6b9e546015

Publish Single VES Measurement Event Over HTTPS
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single measurement event with valid data to /eventListener/v5 endpoint over HTTPS and expect 202 Response
    Send Request And Validate Response  Publish Event To VES Collector  ${VES_ANY_EVENT_PATH}  ${EVENT_MEASURE_FILE}  202  0b2b5790-3673-480a-a4bd-5a00b88e5af6

Publish VES Fault Batch Events Over HTTPS
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with valid data to /eventListener/v5/eventBatch endpoint over HTTPS and expect 202 Response
    Send Request And Validate Response  Publish Event To VES Collector  ${VES_BATCH_EVENT_PATH}  ${EVENT_BATCH_DATA_FILE}  202  ab305d54-85b4-a31b-7db2-fb6b9e546025

Publish VES Event With Invalid URL Path HTTPS
    [Tags]    DCAE-VESC-R1
    [Documentation]    Post single event to invalid url path over HTTPS and expect 404 response
    Log   Send HTTP Request with invalid /eventlistener/v5/ instead of /eventListener/v5 path
    Send Request And Validate Response  Publish Event To VES Collector  /eventlistener/v5  ${EVENT_DATA_FILE}  404

Publish Single VES VNF Measurement Event over HTTP
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event over HTTP with authentication enabled and expect 400 Response
    Send Request And Validate Response  Publish Event To VES Collector No Auth  ${VES_ENDPOINT_V7}  ${VES_VALID_JSON_V7}  400

Publish Single VES VNF Measurement Event with certBasicAuth over HTTPS
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with valid data and valid username/password to /eventListener/v7 endpoint over HTTPS and expect 202 Response
    Send Request And Validate Response  Publish Event To VES Collector  ${VES_ENDPOINT_V7}  ${VES_VALID_JSON_V7}  202  ab305d54-85b4-a31b-7db2-fb6b9e546015

Publish Single VES VNF Measurement Event over HTTPS with wrong JSON
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with invalid data and valid username/password to /eventListener/v7 endpoint over HTTPS and expect 400 Response
    Send Request And Validate Response  Publish Event To VES Collector  ${VES_ENDPOINT_V7}  ${VES_INVALID_JSON_V7}  400

Publish Single VES VNF Measurement Event With Wrong Auth
    [Tags]  DCAE-VESC-R1
    [Documentation]  Post single event with valid data and invalid username/password to /eventListener/v7 endpoint over HTTPS and expect 401 Response
    Send Request And Validate Response  Publish Event To VES Collector With Wrong Auth   ${VES_ENDPOINT_V7}  ${VES_VALID_JSON_V7}  401

Publish Single VES VNF Measurement Event With Cert
    [Tags]  DCAE-VESC-R1
    [Documentation]  Post single event with valid data and valid certificate to /eventListener/v7 endpoint over HTTPS and expect 202 Response
    Send Request And Validate Response  Publish Event To VES Collector With Cert  ${VES_ENDPOINT_V7}  ${VES_VALID_JSON_V7}  202  ab305d54-85b4-a31b-7db2-fb6b9e546015

Publish Single VES VNF Measurement Event With Wrong Cert
    [Tags]  DCAE-VESC-R1
    [Documentation]  Post single event with valid data and invalid certificate to /eventListener/v7 endpoint over HTTPS and expect SSLError with bad handshake
    @{err_content}  Create List  bad handshake  certificate unknown
    Send Request And Expect Error  Publish Event To VES Collector With Wrong Cert  ${VES_ENDPOINT_V7}  ${VES_VALID_JSON_V7}  SSLError:*  @{err_content}

Publish Single VES VNF Measurement Event With Outdated Cert
    [Tags]  DCAE-VESC-R1
    [Documentation]  Post single event with valid data and outdated certificate to /eventListener/v7 endpoint over HTTPS and expect SSLError with bad handshake
    @{err_content}  Create List  bad handshake  certificate unknown
    Send Request And Expect Error  Publish Event To VES Collector With Outdated Cert  ${VES_ENDPOINT_V7}  ${VES_VALID_JSON_V7}  SSLError:*  @{err_content}

Publish Single VES VNF Measurement Event Without Auth And Cert
    [Tags]  DCAE-VESC-R1
    [Documentation]  Post single event with valid data and without certificate or username/password to /eventListener/v7 endpoint over HTTPS and expect 401 Response
    Send Request And Validate Response  Publish Event To VES Collector Without Auth And Cert   ${VES_ENDPOINT_V7}  ${VES_VALID_JSON_V7}  401

Publish V7 Batch Event with certBasicAuth over HTTPS
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with valid data and valid username/password to /eventListener/v7/eventBatch endpoint over HTTPS and expect 202 Response
    Send Request And Validate Response  Publish Event To VES Collector  ${VES_BATCH_EVENT_ENDPOINT_V7}  ${VES_VALID_BATCH_JSON_V7}  202  Fault_Vscf:Acs-Ericcson_PilotNumberPoolExhaustion

Publish V7 Batch Event With Wrong Auth
    [Tags]  DCAE-VESC-R1
    [Documentation]  Post single event with valid data and invalid username/password to /eventListener/v7/eventBatch endpoint over HTTPS and expect 401 Response
    Send Request And Validate Response  Publish Event To VES Collector With Wrong Auth   ${VES_BATCH_EVENT_ENDPOINT_V7}  ${VES_VALID_BATCH_JSON_V7}  401

Publish V7 Batch Event With Cert
    [Tags]  DCAE-VESC-R1
    [Documentation]  Post single event with valid data and valid certificate to /eventListener/v7/eventBatch endpoint over HTTPS and expect 202 Response
    Send Request And Validate Response  Publish Event To VES Collector With Cert  ${VES_BATCH_EVENT_ENDPOINT_V7}  ${VES_VALID_BATCH_JSON_V7}  202  Fault_Vscf:Acs-Ericcson_PilotNumberPoolExhaustion

Publish V7 Batch With Wrong Cert
    [Tags]  DCAE-VESC-R1
    [Documentation]  Post single event with valid data and invalid certificate to /eventListener/v7/eventBatch endpoint over HTTPS and expect SSLError with bad handshake
    @{err_content}  Create List  bad handshake  certificate unknown
    Send Request And Expect Error  Publish Event To VES Collector With Wrong Cert  ${VES_BATCH_EVENT_ENDPOINT_V7}  ${VES_VALID_BATCH_JSON_V7}  SSLError:*  @{err_content}

Publish V7 Batch Event With Outdated Cert
    [Tags]  DCAE-VESC-R1
    [Documentation]  Post single event with valid data and outdated certificate to /eventListener/v7/eventBatch endpoint over HTTPS and expect SSLError with bad handshake
    @{err_content}  Create List  bad handshake  certificate unknown
    Send Request And Expect Error  Publish Event To VES Collector With Outdated Cert  ${VES_BATCH_EVENT_ENDPOINT_V7}  ${VES_VALID_BATCH_JSON_V7}  SSLError:*  @{err_content}

Publish V7 Batch Event Without Auth And Cert
    [Tags]  DCAE-VESC-R1
    [Documentation]  Post single event with valid data and without certificate or username/password to /eventListener/v7/eventBatch endpoint over HTTPS and expect 401 Response
    Send Request And Validate Response  Publish Event To VES Collector Without Auth And Cert   ${VES_BATCH_EVENT_ENDPOINT_V7}  ${VES_VALID_BATCH_JSON_V7}  401
