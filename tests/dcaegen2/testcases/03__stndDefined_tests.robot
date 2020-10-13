*** Settings ***
Resource          ./resources/dcae_keywords.robot
*** Test Cases ***

###################################################
# Section for tests with stndDefined validation ON
###################################################
Publish Single VES VNF Measurement Event with Standard Defined Fields with certBasicAuth over HTTPS
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with valid data with Standard Defined Fields and valid username/password to /eventListener/v7 endpoint over HTTPS and expect 202 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${https_basic_auth_session}  ${VES_EVENTLISTENER_V7}  ${VES_VALID_JSON_V7_STND_DEF_FIELDS}  202  stndDefined-gNB-Nokia-PowerLost

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

Publish Single VES Event With SchemaReference Field Not Set
    [Tags]    DCAE-VESC-R1 DCAE-VESC-STNDDEFINED
    [Documentation]   Post single event with schemaReference not set and not perform stndDefined validation, but pass general validation stage
    Send Request And Validate Response  Publish Event To VES Collector  ${https_basic_auth_session}  ${VES_EVENTLISTENER_V7}  ${VES_STND_DEFINED_INVALID_DATA_NO_SCHEMA_REF}  202  unauthenticated.SEC_3GPP_FAULTSUPERVISION_OUTPUT

Publish Single VES Event With Incorrect Schema Reference
    [Tags]    DCAE-VESC-R1 DCAE-VESC-STNDDEFINED
    [Documentation]   Post single event with incorrect schemaReference and return error
    Send Request And Validate Response And Error Message  Publish Event To VES Collector  ${https_basic_auth_session}  ${VES_EVENTLISTENER_V7}  ${VES_STND_DEFINED_INCORRECT_SCHEMA_REF}  400  Invalid input value for %1 %2: %3

Publish Single VES Event With Empty StndDefined Data Field
    [Tags]    DCAE-VESC-R1 DCAE-VESC-STNDDEFINED
    [Documentation]   Post single event with Empty stndDefined data field and return error
    Send Request And Validate Response And Error Message  Publish Event To VES Collector  ${https_basic_auth_session}  ${VES_EVENTLISTENER_V7}  ${VES_STND_DEFINED_EMPTY_DATA}  400  The following service error occurred: %1. Error code is %2

Publish Single VES Event With Invalid Type Of Multiply StndDefined Data Fields
    [Tags]    DCAE-VESC-R1 DCAE-VESC-STNDDEFINED
    [Documentation]   Post single event with invalid stndDefined data fields and return error
    Send Request And Validate Response And Error Message  Publish Event To VES Collector  ${https_basic_auth_session}  ${VES_EVENTLISTENER_V7}  ${VES_STND_DEFINED_INVALID_TYPE_DATA}  400  The following service error occurred: %1. Error code is %2


#####################################################
## Section for tests with stndDefined validation OFF
#####################################################
Disable VESC StndDefined Validation Checkflag
    [Tags]    DCAE-VESC-R1  DCAE-VESC-HC  DCAE-VESC-STNDDEFINED
    [Documentation]  Disable VESC StndDefined Validation Checkflag and Run Health Check
    Override Collector Properties  ${VES_DISABLED_STNDDEFINED_COLLECTOR_PROPERTIES}
    Run Healthcheck  ${https_basic_auth_session}

Publish Single VES Event With Incorrect StndDefined Data
    [Tags]    DCAE-VESC-R1 DCAE-VESC-STNDDEFINED
    [Documentation]   Post single event with incorrect stndDefined data
    Send Request And Validate Response  Publish Event To VES Collector  ${https_basic_auth_session}  ${VES_EVENTLISTENER_V7}  ${VES_STND_DEFINED_INVALID_TYPE_DATA}  202

############################################################################################
## Section for tests with stndDefined validation ON and schemas with refernce to other files
############################################################################################
Add refeerence to other schemas
    [Tags]    DCAE-VESC-R1  DCAE-VESC-HC  DCAE-VESC-STNDDEFINED
    [Documentation]  Add refeerence to other schemas and Run Health Check
    Override Collector Properties  ${VES_ADD_REFERENCE_TO_OTHER_SCHEMAS}
    Run Healthcheck  ${https_basic_auth_session}


Publish Single VES VNF Measurement Event with Standard Defined Fields with certBasicAuth over HTTPS and valid reference to other file
    [Tags]    DCAE-VESC-R1  DCAE-VESC-HC  DCAE-VESC-STNDDEFINED
    [Documentation]   Post single event with valid data with Standard Defined Fields and valid username/password to /eventListener/v7 endpoint over HTTPS and valid reference to ther file and expect 202 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${https_basic_auth_session}  ${VES_EVENTLISTENER_V7}  ${VES_VALID_JSON_WITH_RFERENCE_TO_VALID_SCHEMA}  202  stndDefined-gNB-Nokia-PowerLost


Publish Single VES VNF Measurement Event with Standard Defined Fields with certBasicAuth over HTTPS and invalid reference to other schema file
    [Tags]    DCAE-VESC-R1  DCAE-VESC-HC  DCAE-VESC-STNDDEFINED
    [Documentation]   Post single event with valid data with Standard Defined Fields and valid username/password to /eventListener/v7 endpoint over HTTPS and invalid reference to other schema file and expect 400 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${https_basic_auth_session}  ${VES_EVENTLISTENER_V7}  ${VES_VALID_JSON_V7_STND_DEF_FIELDS_WRONG_SCHEMA_FILE_REF}  400


Publish Single VES VNF Measurement Event with Standard Defined Fields with certBasicAuth over HTTPS and invalid internal schema reference
    [Tags]    DCAE-VESC-R1  DCAE-VESC-HC  DCAE-VESC-STNDDEFINED
    [Documentation]   Post single event with valid data with Standard Defined Fields and valid username/password to /eventListener/v7 endpoint over HTTPS and invalid internal schema reference and expect 400 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${https_basic_auth_session}  ${VES_EVENTLISTENER_V7}  ${VES_VALID_JSON_V7_STND_DEF_FIELDS_WRONG_SCHEMA_INTERNAL_REF}  400
