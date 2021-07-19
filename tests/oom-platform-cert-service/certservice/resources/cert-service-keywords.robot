*** Settings ***

Resource          ../../../common.robot
Resource          ./cert-service-properties.robot
Library 	      RequestsLibrary
Library           HttpLibrary.HTTP
Library           Collections
Library           Process
Library           DateTime
Library           ../libraries/CertClientManager.py  ${MOUNT_PATH}  ${TRUSTSTORE_PATH}
Library           ../libraries/P12ArtifactsValidator.py  ${MOUNT_PATH}
Library           ../libraries/JksArtifactsValidator.py  ${MOUNT_PATH}
Library           ../libraries/PemArtifactsValidator.py  ${MOUNT_PATH}
Library           ../libraries/ResponseParser.py

*** Keywords ***

Create sessions
    [Documentation]  Create all required sessions
    ${certs}=  Create List  ${CERTSERVICE_SERVER_CRT}  ${CERTSERVICE_SERVER_KEY}
    Create Client Cert Session  alias  ${OOMCERT_URL}  client_certs=${certs}  verify=${ROOTCA}
    Set Suite Variable  ${https_valid_cert_session}  alias

Run Healthcheck
    [Documentation]  Run Healthcheck
    ${resp}=  Get Request 	${https_valid_cert_session} 	/actuator/health
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
    ${resp}= 	Get Request 	${https_valid_cert_session}  ${path}
    Should Be Equal As Strings 	${resp.status_code} 	${resp_code}

Send Get Request with Header
    [Documentation]  Send request to passed url
    [Arguments]  ${path}  ${csr_file}  ${pk_file}
    [Return]  ${resp}
    ${headers}=  Create Header with CSR and PK  ${csr_file}  ${pk_file}
    ${resp}= 	Get Request 	${https_valid_cert_session}  ${path}  headers=${headers}

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
    FOR    ${content}    IN    @{list}
        Should Contain  ${content}  BEGIN CERTIFICATE
        Should Contain  ${content}  END CERTIFICATE
    END

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
    ${resp}= 	Post Request 	${https_valid_cert_session}  ${path}
    Should Be Equal As Strings 	${resp.status_code} 	${resp_code}

Send Initialization Request And Key Update Request And Expect Success
    [Documentation]   Send initialization request and then key update request to passed urls and validate received response
    [Arguments]   ${path}  ${update_path}   ${csr_file}  ${pk_file}  ${update_csr_file}  ${update_pk_file}
    ${start_time}=  Get Current Timestamp For Docker Log
    Send Initialization Request And Update Request And Check Status Code  ${path}  ${update_path}  ${csr_file}  ${pk_file}
    ...  ${update_csr_file}  ${update_pk_file}  200
    Verify Key Update Request Sent By Cert Service  ${start_time}

Send Initialization Request And Certification Request And Expect Success
    [Documentation]   Send initialization request and then certification request to passed urls and validate received response
    [Arguments]   ${path}  ${update_path}   ${csr_file}  ${pk_file}  ${update_csr_file}  ${update_pk_file}
    ${start_time}=  Get Current Timestamp For Docker Log
    Send Initialization Request And Update Request And Check Status Code  ${path}  ${update_path}  ${csr_file}  ${pk_file}
    ...  ${update_csr_file}  ${update_pk_file}  200
    Verify Certification Request Sent By Cert Service  ${start_time}

Send Initialization Request And Key Update Request With Wrong Old Private Key And Expect Error
    [Documentation]   Send initialization request and then key update request to passed urls and validate received response
    [Arguments]   ${path}  ${update_path}   ${csr_file}  ${pk_file}  ${update_csr_file}  ${update_pk_file}  ${wrong_old_pk_file}
    ${start_time}=  Get Current Timestamp For Docker Log
    ${old_cert}=  Send Certificate Initialization Request And Return Certificate  ${path}  ${csr_file}  ${pk_file}
    ${resp}=  Send Certificate Update Request And Return Response  ${update_path}  ${update_csr_file}  ${update_pk_file}  ${old_cert}  ${wrong_old_pk_file}
    Should Be Equal As Strings 	${resp.status_code}  500
    Verify Key Update Request Sent By Cert Service  ${start_time}

Send Update Request With Wrong Header And Expect Error
    [Documentation]   Send update request to passed url and expect wrong header response
    [Arguments]  ${update_path}  ${update_csr_file}  ${update_pk_file}  ${old_cert_base64}  ${old_pk_file}
    ${resp}=  Send Certificate Update Request And Return Response  ${update_path}  ${update_csr_file}  ${update_pk_file}  ${old_cert_base64}  ${old_pk_file}
    Should Be Equal As Strings 	${resp.status_code}  400

Send Update Request With Missing Header And Expect Error
    [Documentation]   Send update request to passed url and expect wrong header response
    [Arguments]  ${update_path}  ${update_csr_file}  ${update_pk_file}  ${old_cert_base64}  ${old_pk_file}  ${header_to_remove}
    ${headers}=  Create Header for Certificate Update  ${update_csr_file}  ${update_pk_file}  ${old_cert_base64}  ${old_pk_file}
    Remove From Dictionary  ${headers}  ${header_to_remove}
    ${resp}=  Get Request  ${https_valid_cert_session}  ${update_path}  headers=${headers}
    Should Be Equal As Strings 	${resp.status_code}  400

Send Initialization Request And Update Request And Check Status Code
    [Documentation]   Send certificate update request and check status code
    [Arguments]   ${path}  ${update_path}   ${csr_file}  ${pk_file}  ${update_csr_file}  ${update_pk_file}  ${expected_status_code}
    ${old_cert}=  Send Certificate Initialization Request And Return Certificate  ${path}  ${csr_file}  ${pk_file}
    ${resp}=  Send Certificate Update Request And Return Response  ${update_path}  ${update_csr_file}  ${update_pk_file}  ${old_cert}  ${pk_file}
    Should Be Equal As Strings 	${resp.status_code}  ${expected_status_code}

Send Certificate Initialization Request And Return Certificate
    [Documentation]   Send certificate initialization request and return base64 encoded certificate from response
    [Arguments]   ${path}  ${csr_file}  ${pk_file}
    [Return]    ${base64Certificate}
    ${resp}= 	Send Get Request with Header  ${path}  ${csr_file}  ${pk_file}
    ${json}=    Parse Json      ${resp.content}
    ${base64Certificate}=    Parse Response    ${json}

Send Certificate Update Request And Return Response
    [Documentation]   Send certificate update request and return response code
    [Arguments]   ${path}   ${csr_file}  ${pk_file}  ${old_cert}  ${old_pk_file}
    [Return]  ${resp}
    ${headers}=  Create Header for Certificate Update  ${csr_file}  ${pk_file}  ${old_cert}  ${old_pk_file}
    ${resp}=  Get Request  ${https_valid_cert_session}  ${path}  headers=${headers}

Create Header for Certificate Update
    [Documentation]  Create header with CSR and PK, OLD_CERT and OLD_PK
    [Arguments]  ${csr_file}  ${pk_file}  ${old_cert}  ${old_pk_file}
    [Return]     ${headers}
    ${csr}=  Get Data From File  ${csr_file}
    ${pk}=  Get Data From File  ${pk_file}
    ${old_pk}=  Get Data From File  ${old_pk_file}
    ${headers}=  Create Dictionary  CSR=${csr}  PK=${pk}  OLD_CERT=${old_cert}  OLD_PK=${old_pk}

Verify Key Update Request Sent By Cert Service
    [Documentation]  Verify that request was key update request
    [Arguments]  ${start_time}
    ${result}=  Run Process  docker logs oomcert-service --since ${start_time}  shell=yes
    Should Contain  ${result.stdout}  ${EXPECTED_KUR_LOG}

Verify Certification Request Sent By Cert Service
    [Documentation]  Verify that request was certification request
    [Arguments]  ${start_time}
    ${result}=  Run Process  docker logs oomcert-service --since ${start_time}  shell=yes
    Should Contain  ${result.stdout}  ${EXPECTED_CR_LOG}

Get Current Timestamp For Docker Log
    [Documentation]  Gets current timestamp valid for docker
    [Return]  ${timestamp}
    ${timestamp}=  Get Current Date  result_format=%Y-%m-%dT%H:%M:%S.%f

Run Cert Service Client And Validate PKCS12 File Creation And Client Exit Code
    [Documentation]  Run Cert Service Client Container And Validate Exit Code
    [Arguments]   ${env_file}  ${expected_exit_code}
    [Teardown]    Remove Client Container And Save Logs  ${CLIENT_CONTAINER_NAME}  positive_path
    ${exit_code}=  Run Client Container  ${DOCKER_CLIENT_IMAGE}  ${CLIENT_CONTAINER_NAME}  ${env_file}  ${CERT_SERVICE_ADDRESS}${CERT_SERVICE_ENDPOINT}  ${CERT_SERVICE_NETWORK}
    ${can_open}=  Can Open Keystore And Truststore With Pass
    Should Be Equal As Strings  ${exit_code}  ${expected_exit_code}  Client return: ${exitcode} exit code, but expected: ${expected_exit_code}
    Should Be True  ${can_open}  Cannot Open Keystore/TrustStore by passpshase

Run Cert Service Client And Validate JKS File Creation And Client Exit Code
    [Documentation]  Run Cert Service Client Container And Validate Exit Code
    [Arguments]   ${env_file}  ${expected_exit_code}
    [Teardown]    Remove Client Container And Save Logs  ${CLIENT_CONTAINER_NAME}  positive_path
    ${exit_code}=  Run Client Container  ${DOCKER_CLIENT_IMAGE}  ${CLIENT_CONTAINER_NAME}  ${env_file}  ${CERT_SERVICE_ADDRESS}${CERT_SERVICE_ENDPOINT}  ${CERT_SERVICE_NETWORK}
    ${can_open}=  Can Open Keystore And Truststore With Pass Jks
    Should Be Equal As Strings  ${exit_code}  ${expected_exit_code}  Client return: ${exitcode} exit code, but expected: ${expected_exit_code}
    Should Be True  ${can_open}  Cannot Open Keystore/TrustStore by passpshase

Run Cert Service Client And Validate PKCS12 Files Contain Expected Data
    [Documentation]  Run Cert Service Client Container And Validate PKCS12 Files Contain Expected Data
    [Arguments]  ${env_file}  ${expected_exit_code}
    [Teardown]    Remove Client Container And Save Logs  ${CLIENT_CONTAINER_NAME}  positive_path_with_data
    ${exit_code}=  Run Client Container  ${DOCKER_CLIENT_IMAGE}  ${CLIENT_CONTAINER_NAME}  ${env_file}  ${CERT_SERVICE_ADDRESS}${CERT_SERVICE_ENDPOINT}  ${CERT_SERVICE_NETWORK}
    ${data}    ${isEqual}=  Get And Compare Data P12  ${env_file}
    Should Be Equal As Strings  ${exit_code}  ${expected_exit_code}  Client return: ${exitcode} exit code, but expected: ${expected_exit_code}
    Should Be True  ${isEqual}  Keystore doesn't contain ${data.expectedData}. Actual data is: ${data.actualData}

Run Cert Service Client And Validate JKS Files Contain Expected Data
    [Documentation]  Run Cert Service Client Container And Validate JKS Files Contain Expected Data
    [Arguments]  ${env_file}  ${expected_exit_code}
    [Teardown]    Remove Client Container And Save Logs  ${CLIENT_CONTAINER_NAME}  positive_path_with_data
    ${exit_code}=  Run Client Container  ${DOCKER_CLIENT_IMAGE}  ${CLIENT_CONTAINER_NAME}  ${env_file}  ${CERT_SERVICE_ADDRESS}${CERT_SERVICE_ENDPOINT}  ${CERT_SERVICE_NETWORK}
    ${data}    ${isEqual}=  Get And Compare Data Jks  ${env_file}
    Should Be Equal As Strings  ${exit_code}  ${expected_exit_code}  Client return: ${exitcode} exit code, but expected: ${expected_exit_code}
    Should Be True  ${isEqual}  Keystore doesn't contain ${data.expectedData}. Actual data is: ${data.actualData}

Run Cert Service Client And Validate PEM Files Contain Expected Data
    [Documentation]  Run Cert Service Client Container And Validate PEM Files Contain Expected Data
    [Arguments]  ${env_file}  ${expected_exit_code}
    [Teardown]    Remove Client Container And Save Logs  ${CLIENT_CONTAINER_NAME}  positive_path_with_data
    ${exit_code}=  Run Client Container  ${DOCKER_CLIENT_IMAGE}  ${CLIENT_CONTAINER_NAME}  ${env_file}  ${CERT_SERVICE_ADDRESS}${CERT_SERVICE_ENDPOINT}  ${CERT_SERVICE_NETWORK}
    ${existNotEmpty}=  Artifacts Exist And Are Not Empty
    ${data}    ${isEqual}=  Get And Compare Data Pem  ${env_file}
    Should Be Equal As Strings  ${exit_code}  ${expected_exit_code}  Client return: ${exitcode} exit code, but expected: ${expected_exit_code}
    Should Be True  ${existNotEmpty}  PEM artifacts not created properly
    Should Be True  ${isEqual}  Keystore doesn't contain ${data.expectedData}. Actual data is: ${data.actualData}

Run Cert Service Client And Validate Http Response Code And Client Exit Code
    [Documentation]  Run Cert Service Client Container And Validate Exit Code
    [Arguments]   ${env_file}  ${expected_api_response_code}  ${expected_exit_code}
    ${exit_code}=  Run Client Container  ${DOCKER_CLIENT_IMAGE}  ${CLIENT_CONTAINER_NAME}  ${env_file}  ${CERT_SERVICE_ADDRESS}${CERT_SERVICE_ENDPOINT}  ${CERT_SERVICE_NETWORK}
    ${can_find_API_response}=  Can Find Api Response In Logs  ${CLIENT_CONTAINER_NAME}
    ${api_response_code}=  Get Api Response From Logs  ${CLIENT_CONTAINER_NAME}
    [Teardown]    Remove Client Container And Save Logs  ${CLIENT_CONTAINER_NAME}  negative_path
    Should Be True  ${can_find_API_response}  Cannot Find API response in logs
    Should Be Equal As Strings  ${api_response_code}  ${expected_api_response_code}  API return ${api_response_code} but expected: ${expected_api_response_code}
    Should Be Equal As Strings  ${exit_code}  ${expected_exit_code}  Client return unexpected exit code return: ${exitcode} , but expected: ${expected_exit_code}

Run Cert Service Client And Validate Client Exit Code
    [Documentation]  Run Cert Service Client Container And Validate Exit Code
    [Arguments]   ${env_file}  ${expected_exit_code}
    [Teardown]    Remove Client Container And Save Logs  ${CLIENT_CONTAINER_NAME}  negative_path
    ${exit_code}=  Run Client Container  ${DOCKER_CLIENT_IMAGE}  ${CLIENT_CONTAINER_NAME}  ${env_file}  ${CERT_SERVICE_ADDRESS}${CERT_SERVICE_ENDPOINT}  ${CERT_SERVICE_NETWORK}
    Should Be Equal As Strings  ${exit_code}  ${expected_exit_code}  Client return unexpected exit code return: ${exitcode} , but expected: ${expected_exit_code}

