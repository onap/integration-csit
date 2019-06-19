*** Settings ***
Library           RequestsLibrary
Library           Collections

*** Keywords ***
Create sessions
    Create Session    dmaap_session    ${DMAAP_SIMULATOR_SETUP_URL}
    Set Suite Variable    ${dmaap_session}    dmaap_session
    Create Session    aai_session    ${AAI_SIMULATOR_SETUP_URL}
    Set Suite Variable    ${aai_session}    aai_session
    Create Session    consul_session    ${CONSUL_SETUP_URL}
    Set Suite Variable    ${consul_session}    consul_session
    Create Session    prh_session    ${PRH_SETUP_URL}
    Set Suite Variable    ${prh_session}    prh_session


Create headers
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    Set Suite Variable    ${suite_headers}    ${headers}