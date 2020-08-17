*** Settings ***
Resource          ./resources/dcae_keywords.robot
*** Test Cases ***
Enable VESC HTTPS with certBasicAuth
    [Tags]    DCAE-VESC-R1  DCAE-VESC-HC
    [Documentation]  Enable VESC Https and Authentication and Run Health Check
    Enable VESC with certBasicAuth
    Run Healthcheck  ${https_basic_auth_session}

VES Collector HTTP Health Check with certBasicAuth
    [Tags]    DCAE-VESC-R1  DCAE-VESC-HC
    [Documentation]   Run healthcheck over HTTP with certBasicAuth
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

Publish VES Event With Empty Stnd Domain Namespace Parameter
    [Tags]    DCAE-VESC-R1 DCAE-VESC-STNDDEFINED
    [Documentation]   Post single event with invalid data (empty stnd namespace parameter) to /eventListener/v7 endpoint, expect 400 Response Status Code and "Mandatory input %1 %2 is empty in request" message
    Send Request And Validate Response And Error Message  Publish Event To VES Collector  ${https_basic_auth_session}  ${VES_EVENTLISTENER_V7}  ${VES_STND_DEFINED_EMPTY_NAMESPACE}   400   Mandatory input %1 %2 is empty in request

Publish VES Event With Missing Stnd Domain Namespace Parameter
    [Tags]    DCAE-VESC-R1 DCAE-VESC-STNDDEFINED
    [Documentation]   Post single event with invalid data (missing stnd namespace parameter) to /eventListener/v7 endpoint, expect 400 Response Status Code and "Mandatory input %1 %2 is missing from request" message
    Send Request And Validate Response And Error Message  Publish Event To VES Collector  ${https_basic_auth_session}  ${VES_EVENTLISTENER_V7}  ${VES_STND_DEFINED_MISSING_NAMESPACE}    400   Mandatory input %1 %2 is missing from request

Publish Single VES Event With Empty JSON
    [Tags]    DCAE-VESC-R1 DCAE-VESC-STNDDEFINED
    [Documentation]   Post single event with empty json and expect 400 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${https_basic_auth_session}  ${VES_EVENTLISTENER_V7}  ${VES_EMPTY_JSON}  400

Publish Single VES Event With Missing SourceName Parameter
    [Tags]    DCAE-VESC-R1 DCAE-VESC-STNDDEFINED
    [Documentation]   Post single event with empty json and expect 400 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${https_basic_auth_session}  ${VES_EVENTLISTENER_V7}  ${VES_NAMESPACE_3GPP_PROVISIONING_MISSING_SOURCENAME}  400

Publish Single VES Event With stndDefinedNamespace = 3GPP-Provisioning
    [Tags]    DCAE-VESC-R1 DCAE-VESC-STNDDEFINED
    [Documentation]   Post single event with stndDefinedNamespace = 3GPP-Provisioning and event should routed to topic unauthenticated.SEC_3GPP_PROVISIONING_OUTPUT
    Send Request And Validate Response  Publish Event To VES Collector  ${https_basic_auth_session}  ${VES_EVENTLISTENER_V7}  ${VES_STND_DEFINED_3GPP_PROVISIONING}  202  unauthenticated.SEC_3GPP_PROVISIONING_OUTPUT

Publish Single VES Event With stndDefinedNamespace = 3GPP-Heartbeat
    [Tags]    DCAE-VESC-R1 DCAE-VESC-STNDDEFINED
    [Documentation]   Post single event with stndDefinedNamespace = 3GPP-Heartbeat and event should routed to topic unauthenticated.SEC_3GPP_HEARTBEAT_OUTPUT
    Send Request And Validate Response  Publish Event To VES Collector  ${https_basic_auth_session}  ${VES_EVENTLISTENER_V7}  ${VES_STND_DEFINED_3GPP_HEARTBEAT}  202  unauthenticated.SEC_3GPP_HEARTBEAT_OUTPUT

Publish Single VES Event With stndDefinedNamespace = 3GPP-PerformanceAssurance
    [Tags]    DCAE-VESC-R1 DCAE-VESC-STNDDEFINED
    [Documentation]   Post single event with stndDefinedNamespace = 3GPP-PerformanceAssurance and event should routed to topic unauthenticated.SEC_3GPP_PERFORMANCEASSURANCE_OUTPUT
    Send Request And Validate Response  Publish Event To VES Collector  ${https_basic_auth_session}  ${VES_EVENTLISTENER_V7}  ${VES_STND_DEFINED_3GPP_PERFORMANCE_ASSURANCE}  202  unauthenticated.SEC_3GPP_PERFORMANCEASSURANCE_OUTPUT

Publish Single VES Event With stndDefinedNamespace = 3GPP-FaultSupervision
    [Tags]    DCAE-VESC-R1 DCAE-VESC-STNDDEFINED
    [Documentation]   Post single event with stndDefinedNamespace = 3GPP-FaultSupervision and event should routed to topic unauthenticated.SEC_3GPP_FAULTSUPERVISION_OUTPUT
    Send Request And Validate Response  Publish Event To VES Collector  ${https_basic_auth_session}  ${VES_EVENTLISTENER_V7}  ${VES_STND_DEFINED_3GPP_FAULTSUPERVISION}  202  unauthenticated.SEC_3GPP_FAULTSUPERVISION_OUTPUT
