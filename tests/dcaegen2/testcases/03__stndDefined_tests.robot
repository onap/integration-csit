*** Settings ***
Resource          ./resources/dcae_keywords.robot
*** Test Cases ***
Disable VESC StndDefined Validation Checkflag
    [Tags]    DCAE-VESC-R1  DCAE-VESC-HC  DCAE-VESC-STNDDEFINED
    [Documentation]  Disable VESC StndDefined Validation Checkflag and Run Health Check
    Override Collector Properties  ${VES_DISABLED_STNDDEFINED_COLLECTOR_PROPERTIES}
    Run Healthcheck  ${https_basic_auth_session}

Publish Single VES Event With Incorrect StndDefined Data
    [Tags]    DCAE-VESC-R1 DCAE-VESC-STNDDEFINED
    [Documentation]   Post single event with incorrect stndDefined data
    Send Request And Validate Response  Publish Event To VES Collector  ${https_basic_auth_session}  ${VES_EVENTLISTENER_V7}  ${VES_STDN_DEFINED_INVALID_DATA}  202

