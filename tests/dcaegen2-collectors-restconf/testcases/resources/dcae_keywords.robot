*** Settings ***
Documentation     The main interface for interacting with DCAE. It handles low level stuff like managing the http request library and DCAE required fields
Library 	      RequestsLibrary
Library	          DcaeLibrary   
Library           OperatingSystem
Library           Collections
Resource          ../resources/dcae_properties.robot

*** Variables ***
${DCAE_HEALTH_CHECK_BODY}    %{WORKSPACE}/tests/dcae/testcases/assets/json_events/dcae_healthcheck.json

*** Keywords ***
Create rcc sessions
    [Documentation]  Create all required sessions
    Create Session    dcae_rcc_url    ${RCC_URL}
    Set Suite Variable    ${suite_dcae_rcc_url_session}    dcae_rcc_url
    ${auth}=  Create List  ${RCC_HTTPS_USER}   ${RCC_HTTPS_PD}
    Create Session    dcae_rcc_url_https    ${RCC_URL_HTTPS}  auth=${auth}  disable_warnings=1
    Set Suite Variable    ${suite_dcae_rcc_url_https_session}    dcae_rcc_url_https

Create rcc header
    ${headers}=    Create Dictionary    Content-Type=application/json
    Set Suite Variable    ${suite_headers}    ${headers}
