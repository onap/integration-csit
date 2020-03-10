*** Settings ***

Library 	      RequestsLibrary
Library           HttpLibrary.HTTP
Library           Collections
Library           ../libraries/CertClientManager.py
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
    ${value}=  Get From Dictionary  ${json}  ${key}
    Should Be Equal As Strings    ${value}    ${expected_value}

Send Get Request And Validate Response
    [Documentation]   Send request to passed url and validate received response
    [Arguments]   ${path}  ${resp_code}
    ${resp}= 	Get Request 	${http_session}  ${path}
    Should Be Equal As Strings 	${resp.status_code} 	${resp_code}

Send Get Request with Header
    [Documentation]  Send request to passed url
    [Arguments]  ${path}  ${csr_file}  ${pk_file}
    [Return]  ${resp}
    ${headers}=  Create Header with CSR and PK  ${csr_file}  ${pk_file}
    ${resp}= 	Get Request 	${http_session}  ${path}  headers=${headers}

Send Get Request with Header And Expect Success
    [Documentation]   Send request to passed url and validate received response
    [Arguments]   ${path}  ${csr_file}  ${pk_file}
    ${resp}= 	Send Get Request with Header  ${path}  ${csr_file}  ${pk_file}
    Should Be Equal As Strings 	${resp.status_code} 	200
    Check Message Recieved On Success  ${resp.content}

Check Message Recieved On Success
    [Documentation]  Check if correct messsage has been sent on successful request
    [Arguments]  ${content}
    ${resp_content}=  Parse Json  ${content}
    Dictionary Should Contain Key  ${resp_content}  certificateChain
    @{list}=  Get From Dictionary  ${resp_content}  certificateChain
    List Should Contain Certificates  @{list}
    Dictionary Should Contain Key  ${resp_content}  trustedCertificates

List Should Contain Certificates
    [Documentation]  Verify if list contains certificates
    [Arguments]  @{list}
    :FOR    ${content}    IN    @{list}
    \    Should Contain  ${content}  BEGIN CERTIFICATE
    \    Should Contain  ${content}  END CERTIFICATE

Send Get Request with Header And Expect Error
    [Documentation]   Send request to passed url and validate received response
    [Arguments]   ${path}  ${csr_file}  ${pk_file}  ${resp_code}
    ${resp}= 	Send Get Request with Header  ${path}  ${csr_file}  ${pk_file}
    Should Be Equal As Strings 	${resp.status_code} 	${resp_code}

Create Header with CSR and PK
    [Documentation]  Create header with CSR and PK
    [Arguments]  ${csr_file}  ${pk_file}
    [Return]     ${headers}
    ${csr}=  Get Data From File  ${csr_file}
    ${pk}=   Get Data From File  ${pk_file}
    ${headers}=  Create Dictionary  CSR=${csr}  PK=${pk}

Send Post Request And Validate Response
    [Documentation]   Send request to passed url and validate received response
    [Arguments]   ${path}  ${resp_code}
    ${resp}= 	Post Request 	${http_session}  ${path}
    Should Be Equal As Strings 	${resp.status_code} 	${resp_code}

Run Cert Service Client Container And Validate Exit Code
    [Documentation]  Run Cert Service Client Container And Validate Exit Code
    [Arguments]   ${env_file}  ${expected_code}
    ${exitcode}=  Run Client Container  ${DOCKER_CLIENT_IMAGE}  ${CLIENT_CONTAINER_NAME}  ${env_file}  ${CERT_ADDRESS}  ${CERT_SERVICE_NETWORK}
    Remove Client Container  ${CLIENT_CONTAINER_NAME}
    Should Be Equal As Strings  ${exitcode}  ${expected_code}
