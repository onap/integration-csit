*** Settings ***
Resource          ./resources/dcae_keywords.robot
*** Test Cases ***
VES Collector HTTP Health Check
    [Tags]    DCAE-VESC-R1  DCAE-VESC-HC
    [Documentation]   Run healthcheck over HTTP
    Override Collector Properties  ${VES_BACKWARDS_COMPATIBILITY_PROPERTIES}
    Run Healthcheck  ${http_session}

Publish Single VES VNF Measurement Event API V7
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with valid data to /eventListener/v7 endpoint and expect 200 Response Status Code
    Send Request And Validate Response  Publish Event To VES Collector  ${http_session}  ${VES_EVENTLISTENER_V7}  ${VES_VALID_JSON_V7}  200

Publish Single VES VNF Measurement Event API V7 DmaaP response code mock as 404, expected VES response code 503
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with valid data to /eventListener/v7 endpoint and expect 503 Response Status Code
    Set Successfull Dmaap Code  404
    Send Request And Validate Response And Error Message  Publish Event To VES Collector  ${http_session}  ${VES_EVENTLISTENER_V7}  ${VES_VALID_JSON_V7}  503  ${ERROR_MESSAGE_CODE}

Publish Single VES VNF Measurement Event API V7 DmaaP response code mock as 408, expected VES response code 503
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with valid data to /eventListener/v7 endpoint and expect 503 Response Status Code
    Set Successfull Dmaap Code  408
    Send Request And Validate Response And Error Message  Publish Event To VES Collector  ${http_session}  ${VES_EVENTLISTENER_V7}  ${VES_VALID_JSON_V7}  503  ${ERROR_MESSAGE_CODE}

Publish Single VES VNF Measurement Event API V7 DmaaP response code mock as 429, expected VES response code 503
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with valid data to /eventListener/v7 endpoint and expect 503 Response Status Code
    Set Successfull Dmaap Code  429
    Send Request And Validate Response And Error Message  Publish Event To VES Collector  ${http_session}  ${VES_EVENTLISTENER_V7}  ${VES_VALID_JSON_V7}  503  ${ERROR_MESSAGE_CODE}

Publish Single VES VNF Measurement Event API V7 DmaaP response code mock as 502, expected VES response code 503
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with valid data to /eventListener/v7 endpoint and expect 503 Response Status Code
    Set Successfull Dmaap Code  502
    Send Request And Validate Response And Error Message  Publish Event To VES Collector  ${http_session}  ${VES_EVENTLISTENER_V7}  ${VES_VALID_JSON_V7}  503  ${ERROR_MESSAGE_CODE}

Publish Single VES VNF Measurement Event API V7 DmaaP response code mock as 503, expected VES response code 503
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with valid data to /eventListener/v7 endpoint and expect 503 Response Status Code
    Set Successfull Dmaap Code  503
    Send Request And Validate Response And Error Message  Publish Event To VES Collector  ${http_session}  ${VES_EVENTLISTENER_V7}  ${VES_VALID_JSON_V7}  503  ${ERROR_MESSAGE_CODE}

Publish Single VES VNF Measurement Event API V7 DmaaP response code mock as 504, expected VES response code 503
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with valid data to /eventListener/v7 endpoint and expect 503 Response Status Code
    Set Successfull Dmaap Code  504
    Send Request And Validate Response And Error Message  Publish Event To VES Collector  ${http_session}  ${VES_EVENTLISTENER_V7}  ${VES_VALID_JSON_V7}  503  ${ERROR_MESSAGE_CODE}

Publish Single VES VNF Measurement Event API V7 DmaaP response code mock as 413, expected VES response code 413
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event with valid data to /eventListener/v7 endpoint and expect 413 Response Status Code
    Set Successfull Dmaap Code  413
    Send Request And Validate Response And Error Message  Publish Event To VES Collector  ${http_session}  ${VES_EVENTLISTENER_V7}  ${VES_VALID_JSON_V7}  413  ${ERROR_MESSAGE_CODE}

Publish VES Batch Event With Different Domain Parameters
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post batch event with two different domain fileds data to /eventListener/v7/eventBatch endpoint, expect 400 Response Status Code and "Different value of domain fields in Batch Event" message
    Send Request And Validate Response And Error Message  Publish Event To VES Collector  ${http_session}  ${VES_BATCH_EVENT_ENDPOINT_V7}  ${VES_BATCH_TWO_DIFFERENT_DOMAIN}   400   Different value of domain fields in Batch Event