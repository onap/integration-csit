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
    Should Be Equal As Strings 	${resp.status_code} 	200
    Validate Recieved Response  ${resp}  status  UP

Validate Recieved Response
    [Documentation]  Validare message that has been received
    [Arguments]  ${resp}  ${key}  ${expected_value}
    ${json}=    Parse Json      ${resp.content}
    ${value}=  get from dictionary  ${json}  ${key}
    Should Be Equal As Strings    ${value}    ${expected_value}

Send Get Request And Validate Response
    [Documentation]   Send request to passed url and validate received response
    [Arguments]   ${path}  ${resp_code}
    ${resp}= 	Get Request 	${http_session}  ${path}
    Should Be Equal As Strings 	${resp.status_code} 	${resp_code}

Send Get Request with Header And Validate Response
    [Documentation]   Send request to passed url and validate received response
    [Arguments]   ${path}  ${csr_file}  ${pk_file}  ${resp_code}
    ${headers}=  Create Header with CSR and PK  ${csr_file}  ${pk_file}
    ${resp}= 	Get Request 	${http_session}  ${path}  headers=${headers}
    Should Be Equal As Strings 	${resp.status_code} 	${resp_code}

Create Header with CSR and PK
    [Documentation]  Create header with CSR and PK
    [Arguments]  ${csr_file}  ${pk_file}
    [Return]     ${headers}
    ${csr}=  Get Data From File  ${csr_file}
    ${pk}=   Get Data From File  ${pk_file}
    ${headers}=  Create Dictionary  CSR=${csr}  PK=${pk}

