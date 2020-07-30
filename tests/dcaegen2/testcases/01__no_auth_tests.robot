*** Settings ***
Resource          ./resources/dcae_keywords.robot
*** Test Cases ***
VES Collector HTTP Health Check
    [Tags]    DCAE-VESC-R1  DCAE-VESC-HC
    [Documentation]   Run healthcheck over HTTP
    Run Healthcheck  ${http_session}

#Publish Single VES VNF Measurement Event API V7
#    [Tags]    DCAE-VESC-R1
#    [Documentation]   Post single event with valid data to /eventListener/v7 endpoint and expect 202 Response Status Code
#    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  ${VES_EVENTLISTENER_V7}  ${VES_VALID_JSON_V7}  202  ab305d54-85b4-a31b-7db2-fb6b9e546015
#
Publish Single VES VNF Measurement Event with Standard Defined Fields API V7
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with valid data with Standard Defined Fields to /eventListener/v7 endpoint and expect 202 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  ${VES_EVENTLISTENER_V7}  ${VES_VALID_JSON_V7_STND_DEF_FIELDS}  202  stndDefined-gNB-Nokia-PowerLost  unauthenticated.SEC_3GPP_FAULTSUPERVISION_OUTPUT

#Publish Single VES VNF Measurement Event with wrong JSON
#    [Tags]    DCAE-VESC-R1
#    [Documentation]   Post single event with invalid data to /eventListener/v7 endpoint and expect 400 Response Status Code
#    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  ${VES_EVENTLISTENER_V7}  ${VES_INVALID_JSON_V7}  400
#
#Publish Single VES VNF Measurement Event with missing mandatory parameter
#    [Tags]    DCAE-VESC-R1
#    [Documentation]   Post single event with lack of one of the mandatory parameters "domain" to /eventListener/v7 endpoint and expect 400 Response Status Code
#    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  ${VES_EVENTLISTENER_V7}  ${VES_MISSING_MANDATORY_PARAMETER_V7}  400
#
#Publish Single VES VNF Measurement Event with empty json
#    [Tags]    DCAE-VESC-R1
#    [Documentation]   Post single event with empty json to /eventListener/v7 endpoint and expect 400 Response Status Code
#    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  ${VES_EVENTLISTENER_V7}  ${VES_EMPTY_JSON}  400
#
#Publish Single VES VNF Measurement Event with parameter out of schema
#    [Tags]    DCAE-VESC-R1
#    [Documentation]   Post single event with parameter which is not defined in schema and send to /eventListener/v7 endpoint. Expected 400 Response Status Code
#    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  ${VES_EVENTLISTENER_V7}  ${VES_PARAMETER_OUT_OF_SCHEMA_V7}  400
#
#Publish Single VES VNF Measurement Event with No Auth over HTTPS
#    [Tags]    DCAE-VESC-R1
#    [Documentation]   Post single event over HTTPS with authentication disabled and expect ConnectionError
#    @{err_content}  Create List  Errno 111
#    Send Request And Expect Error  Publish Event To VES Collector  ${https_basic_auth_session}  ${VES_EVENTLISTENER_V7}  ${VES_VALID_JSON_V7}  ConnectionError:*  @{err_content}
#
#Publish Single VES VoLTE Fault Event
#    [Tags]    DCAE-VESC-R1
#    [Documentation]   Post single event with valid data to /eventListener/v5 endpoint and expect 202 Response Status Code
#    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  ${VES_ANY_EVENT_PATH}  ${EVENT_DATA_FILE}  202  ab305d54-85b4-a31b-7db2-fb6b9e546015
#
#Publish Single VES VNF Measurement Event API V5
#    [Tags]    DCAE-VESC-R1
#    [Documentation]   Post single measurement event with valid data to /eventListener/v5 endpoint and expect 202 Response Status Code
#    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  ${VES_ANY_EVENT_PATH}  ${EVENT_MEASURE_FILE}  202  0b2b5790-3673-480a-a4bd-5a00b88e5af6
#
#Publish VES VoLTE Fault Batch Events
#    [Tags]    DCAE-VESC-R1
#    [Documentation]   Post single event with valid data to /eventListener/v5/eventBatch endpoint and expect 202 Response Status Code
#    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  ${VES_BATCH_EVENT_PATH}  ${EVENT_BATCH_DATA_FILE}  202  ab305d54-85b4-a31b-7db2-fb6b9e546025
#
#Publish VES Batch Events with empty json
#    [Tags]    DCAE-VESC-R1
#    [Documentation]   Post empty json to /eventListener/v7/eventBatch endpoint and expect 400 Response Status Code
#    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  ${VES_BATCH_EVENT_ENDPOINT_V7}  ${VES_EMPTY_JSON}  400
#
#Publish VES Batch Events with missing mandatory parameter
#    [Tags]    DCAE-VESC-R1
#    [Documentation]   Post event list where one of the events doesn't have mandatory domain param, to /eventListener/v7/eventBatch endpoint and expect 400 Response Status Code
#    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  ${VES_BATCH_EVENT_ENDPOINT_V7}  ${VES_BATCH_MISSING_MANDATORY_PARAM_V7}  400
#
#Publish VES Batch Events wih parameter out of schema
#    [Tags]    DCAE-VESC-R1
#    [Documentation]   Post event list where one of the events have additional dummy param, to /eventListener/v7/eventBatch endpoint and expect 400 Response Status Code
#    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  ${VES_BATCH_EVENT_ENDPOINT_V7}  ${VES_BATCH_PARAM_OUT_OF_SCHEMA_V7}  400
#
#Publish VES Event With Invalid Method
#    [Tags]    DCAE-VESC-R1
#    [Documentation]    Use invalid Put instead of Post method to expect 405 Response Status Code
#    Log   Send HTTP Request with invalid method Put instead of Post
#    Send Request And Validate Response  Publish Event To VES Collector With Put Method  ${http_session}  ${VES_ANY_EVENT_PATH}  ${EVENT_DATA_FILE}  405
#
#Publish VES Event With Invalid URL Path
#    [Tags]    DCAE-VESC-R1
#    [Documentation]   Post single event to invalid url path and expect 404 Response  Status Code
#    Log   Send HTTP Request with invalid /listener/v5/ instead of /eventListener/v5 path
#    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  /listener/v5/  ${EVENT_DATA_FILE}  404
#
#Publish 'Other' Registration Event
#    [Tags]    DCAE-VESC-R1
#    [Documentation]   Post an event aligned with “other” domain and expect HTTP 202 Accepeted Response Status Code
#    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  ${VES_ANY_EVENT_PATH}  ${EVENT_PNF_REGISTRATION}  202  QTFCOC540002E-reg
#
#Publish VES Event With Invalid Method V7
#    [Tags]    DCAE-VESC-R1
#    [Documentation]    Use invalid Put instead of Post method to expect 405 Response Status Code
#    Log   Send HTTP Request with invalid method Put instead of Post
#    Send Request And Validate Response  Publish Event To VES Collector With Put Method  ${http_session}  ${VES_EVENTLISTENER_V7}  ${EVENT_DATA_FILE}  405
#
#Publish VES Event With Invalid URL Path V7
#    [Tags]    DCAE-VESC-R1
#    [Documentation]   Post single event to invalid url path and expect 404 Response  Status Code
#    Log   Send HTTP Request with invalid /listener/v5/ instead of /eventListener/v5 path
#    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  /listener/v7/  ${EVENT_DATA_FILE}  404
#
#Publish PNF Registration Event
#    [Tags]    DCAE-VESC-R1
#    [Documentation]   Post PNF Registration event and expect HTTP 202 Accepeted Response Status Code
#    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  ${VES_EVENTLISTENER_V7}  ${EVENT_PNF_REGISTRATION_V7}  202  registration_38407540
