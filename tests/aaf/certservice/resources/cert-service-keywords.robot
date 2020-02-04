*** Settings ***

Library 	      RequestsLibrary
Library           HttpLibrary.HTTP
Library           Collections
Resource          ../../../common.robot
Resource          ./cert-service-properties.robot

*** Keywords ***

Create sessions
    [Documentation]  Create all required sessions
    Create Session    aaf_cert_service_url    ${AAFCERT_URL}
    Set Suite Variable    ${http_session}    aaf_cert_service_url

Run Healthcheck
    [Documentation]  Run Healthcheck
    ${resp}= 	Get Request 	${http_session} 	/actuator/health
    ${json}=    Parse Json      ${resp.content}
    Should Be Equal As Strings 	${resp.status_code} 	200
    Validate Recieved Response  ${resp}  status  UP

Send Request And Validate Response
    [Documentation]   Send request to passed url and validate received response
    [Arguments]   ${path}  ${csr_file}  ${pk_file}  ${resp_code}
    ${csr}=  Get Data From File  ${csr_file}
    ${pk}=   Get Data From File  ${pk_file}
    ${headers}=  Create Dictionary  CSR=${csr}  PK=${pk}
    ${resp}= 	Get Request 	${http_session}  ${path}  headers=${headers}
    Should Be Equal As Strings 	${resp.status_code} 	${resp_code}

Validate Recieved Response
    [Documentation]  Validare message that has been received
    [Arguments]  ${resp}  ${key}  ${expected_value}
    ${json}=    Parse Json      ${resp.content}
    ${value}=  get from dictionary  ${json}  ${key}
    Should Be Equal As Strings    ${value}    ${expected_value}