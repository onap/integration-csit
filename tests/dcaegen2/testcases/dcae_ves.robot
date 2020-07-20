*** Settings ***
Documentation     Run healthchecks for DCAE VES
...               Testing /eventListener/v7 and /eventListener/v7/eventBatch endpoints for DCEA VES v7.
...               Testing /eventListener/v5 and /eventListener/v5/eventBatch for DCEA VES v5 with various event feeds from VoLTE, vFW and PNF
Library           RequestsLibrary
Library           OperatingSystem
Library           Collections
Library           DcaeLibrary
Resource          ./resources/dcae_keywords.robot

Test Teardown     Cleanup VES Events
Suite Setup       Run keywords  VES Collector Suite Setup DMaaP  Generate Certs  Create sessions  Create header
Suite Teardown    Run keywords  VES Collector Suite Shutdown DMaaP  Remove Certs

*** Test Cases ***

#No authentication tests

VES Collector HTTP Health Check
    [Tags]    DCAE-VESC-R1  DCAE-VESC-HC
    [Documentation]   Run healthcheck over HTTP
    Run Healthcheck  ${http_session}

Publish Single VES VNF Measurement Event API V7
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with valid data to /eventListener/v7 endpoint and expect 202 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  ${VES_EVENTLISTENER_V7}  ${VES_VALID_JSON_V7}  202  ab305d54-85b4-a31b-7db2-fb6b9e546015

Publish Single VES VNF Measurement Event with Standard Defined Fields API V7
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with valid data with Standard Defined Fields to /eventListener/v7 endpoint and expect 202 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  ${VES_EVENTLISTENER_V7}  ${VES_VALID_JSON_V7_STND_DEF_FIELDS}  202  stndDefined-gNB-Nokia-PowerLost

Publish Single VES VNF Measurement Event with wrong JSON
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with invalid data to /eventListener/v7 endpoint and expect 400 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  ${VES_EVENTLISTENER_V7}  ${VES_INVALID_JSON_V7}  400

Publish Single VES VNF Measurement Event with missing mandatory parameter
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with lack of one of the mandatory parameters "domain" to /eventListener/v7 endpoint and expect 400 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  ${VES_EVENTLISTENER_V7}  ${VES_MISSING_MANDATORY_PARAMETER_V7}  400

Publish Single VES VNF Measurement Event with empty json
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with empty json to /eventListener/v7 endpoint and expect 400 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  ${VES_EVENTLISTENER_V7}  ${VES_EMPTY_JSON}  400

Publish Single VES VNF Measurement Event with parameter out of schema
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with parameter which is not defined in schema and send to /eventListener/v7 endpoint. Expected 400 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  ${VES_EVENTLISTENER_V7}  ${VES_PARAMETER_OUT_OF_SCHEMA_V7}  400

Publish Single VES VNF Measurement Event with No Auth over HTTPS
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event over HTTPS with authentication disabled and expect ConnectionError
    @{err_content}  Create List  Errno 111
    Send Request And Expect Error  Publish Event To VES Collector  ${https_basic_auth_session}  ${VES_EVENTLISTENER_V7}  ${VES_VALID_JSON_V7}  ConnectionError:*  @{err_content}

Publish Single VES VoLTE Fault Event
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with valid data to /eventListener/v5 endpoint and expect 202 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  ${VES_ANY_EVENT_PATH}  ${EVENT_DATA_FILE}  202  ab305d54-85b4-a31b-7db2-fb6b9e546015

Publish Single VES VNF Measurement Event API V5
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single measurement event with valid data to /eventListener/v5 endpoint and expect 202 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  ${VES_ANY_EVENT_PATH}  ${EVENT_MEASURE_FILE}  202  0b2b5790-3673-480a-a4bd-5a00b88e5af6

Publish VES VoLTE Fault Batch Events
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with valid data to /eventListener/v5/eventBatch endpoint and expect 202 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  ${VES_BATCH_EVENT_PATH}  ${EVENT_BATCH_DATA_FILE}  202  ab305d54-85b4-a31b-7db2-fb6b9e546025

Publish VES Batch Events with empty json
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post empty json to /eventListener/v7/eventBatch endpoint and expect 400 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  ${VES_BATCH_EVENT_ENDPOINT_V7}  ${VES_EMPTY_JSON}  400

Publish VES Batch Events with missing mandatory parameter
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post event list where one of the events doesn't have mandatory domain param, to /eventListener/v7/eventBatch endpoint and expect 400 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  ${VES_BATCH_EVENT_ENDPOINT_V7}  ${VES_BATCH_MISSING_MANDATORY_PARAM_V7}  400

Publish VES Batch Events wih parameter out of schema
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post event list where one of the events have additional dummy param, to /eventListener/v7/eventBatch endpoint and expect 400 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  ${VES_BATCH_EVENT_ENDPOINT_V7}  ${VES_BATCH_PARAM_OUT_OF_SCHEMA_V7}  400

Publish VES Event With Invalid Method
    [Tags]    DCAE-VESC-R1
    [Documentation]    Use invalid Put instead of Post method to expect 405 Response Status Code
    Log   Send HTTP Request with invalid method Put instead of Post
    Send Request And Validate Response  Publish Event To VES Collector With Put Method  ${http_session}  ${VES_ANY_EVENT_PATH}  ${EVENT_DATA_FILE}  405

Publish VES Event With Invalid URL Path
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event to invalid url path and expect 404 Response  Status Code
    Log   Send HTTP Request with invalid /listener/v5/ instead of /eventListener/v5 path
    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  /listener/v5/  ${EVENT_DATA_FILE}  404

Publish 'Other' Registration Event
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post an event aligned with “other” domain and expect HTTP 202 Accepeted Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  ${VES_ANY_EVENT_PATH}  ${EVENT_PNF_REGISTRATION}  202  QTFCOC540002E-reg

Publish VES Event With Invalid Method V7
    [Tags]    DCAE-VESC-R1
    [Documentation]    Use invalid Put instead of Post method to expect 405 Response Status Code
    Log   Send HTTP Request with invalid method Put instead of Post
    Send Request And Validate Response  Publish Event To VES Collector With Put Method  ${http_session}  ${VES_EVENTLISTENER_V7}  ${EVENT_DATA_FILE}  405

Publish VES Event With Invalid URL Path V7
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event to invalid url path and expect 404 Response  Status Code
    Log   Send HTTP Request with invalid /listener/v5/ instead of /eventListener/v5 path
    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  /listener/v7/  ${EVENT_DATA_FILE}  404

Publish PNF Registration Event
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post PNF Registration event and expect HTTP 202 Accepeted Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  ${VES_EVENTLISTENER_V7}  ${EVENT_PNF_REGISTRATION_V7}  202  registration_38407540

# Auth by certificate and basic auth username / password

Enable VESC HTTPS with certBasicAuth
    [Tags]    DCAE-VESC-R1  DCAE-VESC-HC
    [Documentation]  Enable VESC Https and Authentication and Run Health Check
    Enable VESC with certBasicAuth
    Run Healthcheck  ${https_basic_auth_session}

VES Collector HTTP Health Check with certBasicAuth
    [Tags]    DCAE-VESC-R1  DCAE-VESC-HC
    [Documentation]   Run healthcheck over HTTP with certBasicAuth
    Enable VESC with certBasicAuth
    Run Healthcheck  ${http_session}

Healthcheck with Outdated Cert
    [Tags]    DCAE-VESC-R1  DCAE-VESC-HC
    [Documentation]  Run healthcheck with outdated cert
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=*/*     X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${err_msg}=  Run Keyword And Expect Error  SSLError:*  Get Request 	${https_outdated_cert_session} 	/healthcheck  headers=${headers}
    Should Contain  ${err_msg}  certificate unknown
    Log  Recieved error message ${err_msg}

Publish Single VES Fault Event Over HTTPS
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with valid data to /eventListener/v5 endpoint over HTTPS and expect 202 Response Status Code
    Log  Login User=${VESC_HTTPS_USER}, Pd=${VESC_HTTPS_PD}
    Send Request And Validate Response  Publish Event To VES Collector  ${https_basic_auth_session}  ${VES_ANY_EVENT_PATH}  ${EVENT_DATA_FILE}  202  ab305d54-85b4-a31b-7db2-fb6b9e546015

Publish Single VES Measurement Event Over HTTPS
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single measurement event with valid data to /eventListener/v5 endpoint over HTTPS and expect 202 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${https_basic_auth_session}  ${VES_ANY_EVENT_PATH}  ${EVENT_MEASURE_FILE}  202  0b2b5790-3673-480a-a4bd-5a00b88e5af6

Publish VES Fault Batch Events Over HTTPS
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with valid data to /eventListener/v5/eventBatch endpoint over HTTPS and expect 202 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${https_basic_auth_session}  ${VES_BATCH_EVENT_PATH}  ${EVENT_BATCH_DATA_FILE}  202  ab305d54-85b4-a31b-7db2-fb6b9e546025

Publish VES Event With Invalid URL Path HTTPS
    [Tags]    DCAE-VESC-R1
    [Documentation]    Post single event to invalid url path over HTTPS and expect 404 response Status Code
    Log   Send HTTP Request with invalid /eventlistener/v5/ instead of /eventListener/v5 path
    Send Request And Validate Response  Publish Event To VES Collector  ${https_basic_auth_session}  /eventlistener/v5  ${EVENT_DATA_FILE}  404

Publish Single VES VNF Measurement Event over HTTP
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event over HTTP with authentication enabled and expect 400 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  ${VES_EVENTLISTENER_V7}  ${VES_VALID_JSON_V7}  400

Publish Single VES VNF Measurement Event with certBasicAuth over HTTPS
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with valid data and valid username/password to /eventListener/v7 endpoint over HTTPS and expect 202 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${https_basic_auth_session}  ${VES_EVENTLISTENER_V7}  ${VES_VALID_JSON_V7}  202  ab305d54-85b4-a31b-7db2-fb6b9e546015

Publish Single VES VNF Measurement Event with Standard Defined Fields with certBasicAuth over HTTPS
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with valid data with Standard Defined Fields and valid username/password to /eventListener/v7 endpoint over HTTPS and expect 202 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${https_basic_auth_session}  ${VES_EVENTLISTENER_V7}  ${VES_VALID_JSON_V7_STND_DEF_FIELDS}  202  stndDefined-gNB-Nokia-PowerLost


Publish Single VES VNF Measurement Event over HTTPS with wrong JSON
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with invalid data and valid username/password to /eventListener/v7 endpoint over HTTPS and expect 400 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${https_basic_auth_session}  ${VES_EVENTLISTENER_V7}  ${VES_INVALID_JSON_V7}  400

Publish Single VES VNF Measurement Event With Wrong Auth
    [Tags]  DCAE-VESC-R1
    [Documentation]  Post single event with valid data and invalid username/password to /eventListener/v7 endpoint over HTTPS and expect 401 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${https_wrong_auth_session}  ${VES_EVENTLISTENER_V7}  ${VES_VALID_JSON_V7}  401

Publish Single VES VNF Measurement Event With Cert
    [Tags]  DCAE-VESC-R1
    [Documentation]  Post single event with valid data and valid certificate to /eventListener/v7 endpoint over HTTPS and expect 202 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${https_valid_cert_session}  ${VES_EVENTLISTENER_V7}  ${VES_VALID_JSON_V7}  202  ab305d54-85b4-a31b-7db2-fb6b9e546015

Publish Single VES VNF Measurement Event With Wrong Cert
    [Tags]  DCAE-VESC-R1
    [Documentation]  Post single event with valid data and invalid certificate to /eventListener/v7 endpoint over HTTPS and expect SSLError with certificate unknown
    @{err_content}  Create List  certificate unknown
    Send Request And Expect Error  Publish Event To VES Collector  ${https_invalid_cert_session}  ${VES_EVENTLISTENER_V7}  ${VES_VALID_JSON_V7}  SSLError:*  @{err_content}

Publish Single VES VNF Measurement Event With Outdated Cert
    [Tags]  DCAE-VESC-R1
    [Documentation]  Post single event with valid data and outdated certificate to /eventListener/v7 endpoint over HTTPS and expect SSLError with certificate unknown
    @{err_content}  Create List  certificate unknown
    Send Request And Expect Error  Publish Event To VES Collector  ${https_outdated_cert_session}  ${VES_EVENTLISTENER_V7}  ${VES_VALID_JSON_V7}  SSLError:*  @{err_content}

Publish Single VES VNF Measurement Event Without Auth And Cert
    [Tags]  DCAE-VESC-R1
    [Documentation]  Post single event with valid data and without certificate or username/password to /eventListener/v7 endpoint over HTTPS and expect 401 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${https_no_cert_no_auth_session}   ${VES_EVENTLISTENER_V7}  ${VES_VALID_JSON_V7}  401

Publish V7 Batch Event with certBasicAuth over HTTPS
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with valid data and valid username/password to /eventListener/v7/eventBatch endpoint over HTTPS and expect 202 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${https_basic_auth_session}  ${VES_BATCH_EVENT_ENDPOINT_V7}  ${VES_VALID_BATCH_JSON_V7}  202  Fault_Vscf:Acs-Ericcson_PilotNumberPoolExhaustion

Publish V7 Batch Event With Wrong Auth
    [Tags]  DCAE-VESC-R1
    [Documentation]  Post single event with valid data and invalid username/password to /eventListener/v7/eventBatch endpoint over HTTPS and expect 401 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector   ${https_wrong_auth_session}  ${VES_BATCH_EVENT_ENDPOINT_V7}  ${VES_VALID_BATCH_JSON_V7}  401

Publish V7 Batch Event With Cert
    [Tags]  DCAE-VESC-R1
    [Documentation]  Post single event with valid data and valid certificate to /eventListener/v7/eventBatch endpoint over HTTPS and expect 202 Response
    Send Request And Validate Response  Publish Event To VES Collector  ${https_valid_cert_session}  ${VES_BATCH_EVENT_ENDPOINT_V7}  ${VES_VALID_BATCH_JSON_V7}  202  Fault_Vscf:Acs-Ericcson_PilotNumberPoolExhaustion

Publish V7 Batch With Wrong Cert
    [Tags]  DCAE-VESC-R1
    [Documentation]  Post single event with valid data and invalid certificate to /eventListener/v7/eventBatch endpoint over HTTPS and expect SSLError with certificate unknown
    @{err_content}  Create List  certificate unknown
    Send Request And Expect Error  Publish Event To VES Collector   ${https_invalid_cert_session}  ${VES_BATCH_EVENT_ENDPOINT_V7}  ${VES_VALID_BATCH_JSON_V7}  SSLError:*  @{err_content}

Publish V7 Batch Event With Outdated Cert
    [Tags]  DCAE-VESC-R1
    [Documentation]  Post single event with valid data and outdated certificate to /eventListener/v7/eventBatch endpoint over HTTPS and expect SSLError with certificate unknown
    @{err_content}  Create List  certificate unknown
    Send Request And Expect Error  Publish Event To VES Collector   ${https_outdated_cert_session}  ${VES_BATCH_EVENT_ENDPOINT_V7}  ${VES_VALID_BATCH_JSON_V7}  SSLError:*  @{err_content}

Publish V7 Batch Event Without Auth And Cert
    [Tags]  DCAE-VESC-R1
    [Documentation]  Post single event with valid data and without certificate or username/password to /eventListener/v7/eventBatch endpoint over HTTPS and expect 401 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${https_no_cert_no_auth_session}   ${VES_BATCH_EVENT_ENDPOINT_V7}  ${VES_VALID_BATCH_JSON_V7}  401
