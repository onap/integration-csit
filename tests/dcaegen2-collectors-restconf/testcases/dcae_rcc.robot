*** Settings ***
Documentation	  Testing DCAE Restconf Listener with various event feeds from VoLTE, vDNS, vFW and cCPE use scenarios
Library 	  RequestsLibrary   
Library           OperatingSystem
Library           Collections
Library           DcaeLibrary
Resource          ./resources/dcae_keywords.robot
Resource          ../../common.robot
Test Setup        Init RCC
Suite Setup       Run keywords  Create rcc sessions  Create rcc header
Suite Teardown    teardown rcc

*** Variables ***
${RCC_URL_HTTPS}                        https://%{RCC_IP}:8443
${RCC_URL}                              http://%{RCC_IP}:8080

*** Test Cases ***
Restconf Collector Health Check
    [Tags]    DCAE-RCC-R1
    [Documentation]   Restconf Collector Health Check
    ${headers}=  Create Dictionary     Accept=*/*
    ${resp}= 	Get Request 	${suite_dcae_rcc_url_session} 	/healthcheck        headers=${headers}
    Should Be Equal As Strings 	${resp.status_code} 	200  
