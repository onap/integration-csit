*** Settings ***

Resource          ../../../common.robot
Resource          ./cert-service-properties.robot
Library 	      RequestsLibrary
Library           HttpLibrary.HTTP
Library           Collections
Library           ../libraries/CertClientManager.py  ${MOUNT_PATH}  ${TRUSTSTORE_PATH}
Library           ../libraries/P12ArtifactsValidator.py  ${MOUNT_PATH}
Library           ../libraries/JksArtifactsValidator.py  ${MOUNT_PATH}
Library           ../libraries/PemArtifactsValidator.py  ${MOUNT_PATH}

*** Keywords ***

Create sessions
    [Documentation]  Create all required sessions
    ${certs}=  Create List  ${CERTSERVICE_SERVER_CRT}  ${CERTSERVICE_SERVER_KEY}
    Create Client Cert Session  alias  ${AAFCERT_URL}  client_certs=${certs}  verify=${ROOTCA}
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
    ${resp}= 	Post Request 	${https_valid_cert_session}  ${path}
    Should Be Equal As Strings 	${resp.status_code} 	${resp_code}

Run Cert Service Client And Validate PKCS12 File Creation And Client Exit Code
    [Documentation]  Run Cert Service Client Container And Validate Exit Code
    [Arguments]   ${env_file}  ${expected_exit_code}
    ${exit_code}=  Run Client Container  ${DOCKER_CLIENT_IMAGE}  ${CLIENT_CONTAINER_NAME}  ${env_file}  ${CERT_SERVICE_ADDRESS}${CERT_SERVICE_ENDPOINT}  ${CERT_SERVICE_NETWORK}
    ${can_open}=  Can Open Keystore And Truststore With Pass
    Remove Client Container And Save Logs  ${CLIENT_CONTAINER_NAME}  positive_path
    Should Be Equal As Strings  ${exit_code}  ${expected_exit_code}  Client return: ${exitcode} exit code, but expected: ${expected_exit_code}
    Should Be True  ${can_open}  Cannot Open Keystore/TrustStore by passpshase

Run Cert Service Client And Validate JKS File Creation And Client Exit Code
    [Documentation]  Run Cert Service Client Container And Validate Exit Code
    [Arguments]   ${env_file}  ${expected_exit_code}
    ${exit_code}=  Run Client Container  ${DOCKER_CLIENT_IMAGE}  ${CLIENT_CONTAINER_NAME}  ${env_file}  ${CERT_SERVICE_ADDRESS}${CERT_SERVICE_ENDPOINT}  ${CERT_SERVICE_NETWORK}
    ${can_open}=  Can Open Keystore And Truststore With Pass Jks
    Remove Client Container And Save Logs  ${CLIENT_CONTAINER_NAME}  positive_path
    Should Be Equal As Strings  ${exit_code}  ${expected_exit_code}  Client return: ${exitcode} exit code, but expected: ${expected_exit_code}
    Should Be True  ${can_open}  Cannot Open Keystore/TrustStore by passpshase

Run Cert Service Client And Validate PKCS12 Files Contain Expected Data
    [Documentation]  Run Cert Service Client Container And Validate PKCS12 Files Contain Expected Data
    [Arguments]  ${env_file}  ${expected_exit_code}
    ${exit_code}=  Run Client Container  ${DOCKER_CLIENT_IMAGE}  ${CLIENT_CONTAINER_NAME}  ${env_file}  ${CERT_SERVICE_ADDRESS}${CERT_SERVICE_ENDPOINT}  ${CERT_SERVICE_NETWORK}
    ${data}    ${isEqual}=  Get And Compare Data P12  ${env_file}
    Remove Client Container And Save Logs  ${CLIENT_CONTAINER_NAME}  positive_path_with_data
    Should Be Equal As Strings  ${exit_code}  ${expected_exit_code}  Client return: ${exitcode} exit code, but expected: ${expected_exit_code}
    Should Be True  ${isEqual}  Keystore doesn't contain ${data.expectedData}. Actual data is: ${data.actualData}

Run Cert Service Client And Validate JKS Files Contain Expected Data
    [Documentation]  Run Cert Service Client Container And Validate JKS Files Contain Expected Data
    [Arguments]  ${env_file}  ${expected_exit_code}
    ${exit_code}=  Run Client Container  ${DOCKER_CLIENT_IMAGE}  ${CLIENT_CONTAINER_NAME}  ${env_file}  ${CERT_SERVICE_ADDRESS}${CERT_SERVICE_ENDPOINT}  ${CERT_SERVICE_NETWORK}
    ${data}    ${isEqual}=  Get And Compare Data Jks  ${env_file}
    Remove Client Container And Save Logs  ${CLIENT_CONTAINER_NAME}  positive_path_with_data
    Should Be Equal As Strings  ${exit_code}  ${expected_exit_code}  Client return: ${exitcode} exit code, but expected: ${expected_exit_code}
    Should Be True  ${isEqual}  Keystore doesn't contain ${data.expectedData}. Actual data is: ${data.actualData}

Run Cert Service Client And Validate PEM Files Contain Expected Data
    [Documentation]  Run Cert Service Client Container And Validate PEM Files Contain Expected Data
    [Arguments]  ${env_file}  ${expected_exit_code}
    ${exit_code}=  Run Client Container  ${DOCKER_CLIENT_IMAGE}  ${CLIENT_CONTAINER_NAME}  ${env_file}  ${CERT_SERVICE_ADDRESS}${CERT_SERVICE_ENDPOINT}  ${CERT_SERVICE_NETWORK}
    ${existNotEmpty}=  Artifacts Exist And Are Not Empty
    ${data}    ${isEqual}=  Get And Compare Data Pem  ${env_file}
    Remove Client Container And Save Logs  ${CLIENT_CONTAINER_NAME}  positive_path_with_data
    Should Be Equal As Strings  ${exit_code}  ${expected_exit_code}  Client return: ${exitcode} exit code, but expected: ${expected_exit_code}
    Should Be True  ${existNotEmpty}  PEM artifacts not created properly
    Should Be True  ${isEqual}  Keystore doesn't contain ${data.expectedData}. Actual data is: ${data.actualData}

Run Cert Service Client And Validate Http Response Code And Client Exit Code
    [Documentation]  Run Cert Service Client Container And Validate Exit Code
    [Arguments]   ${env_file}  ${expected_api_response_code}  ${expected_exit_code}
    ${exit_code}=  Run Client Container  ${DOCKER_CLIENT_IMAGE}  ${CLIENT_CONTAINER_NAME}  ${env_file}  ${CERT_SERVICE_ADDRESS}${CERT_SERVICE_ENDPOINT}  ${CERT_SERVICE_NETWORK}
    ${can_find_API_response}=  Can Find Api Response In Logs  ${CLIENT_CONTAINER_NAME}
    ${api_response_code}=  Get Api Response From Logs  ${CLIENT_CONTAINER_NAME}
    Remove Client Container And Save Logs  ${CLIENT_CONTAINER_NAME}  negative_path
    Should Be True  ${can_find_API_response}  Cannot Find API response in logs
    Should Be Equal As Strings  ${api_response_code}  ${expected_api_response_code}  API return ${api_response_code} but expected: ${expected_api_response_code}
    Should Be Equal As Strings  ${exit_code}  ${expected_exit_code}  Client return unexpected exit code return: ${exitcode} , but expected: ${expected_exit_code}

Run Cert Service Client And Validate Client Exit Code
    [Documentation]  Run Cert Service Client Container And Validate Exit Code
    [Arguments]   ${env_file}  ${expected_exit_code}
    ${exit_code}=  Run Client Container  ${DOCKER_CLIENT_IMAGE}  ${CLIENT_CONTAINER_NAME}  ${env_file}  ${CERT_SERVICE_ADDRESS}${CERT_SERVICE_ENDPOINT}  ${CERT_SERVICE_NETWORK}
    Remove Client Container And Save Logs  ${CLIENT_CONTAINER_NAME}  negative_path
    Should Be Equal As Strings  ${exit_code}  ${expected_exit_code}  Client return unexpected exit code return: ${exitcode} , but expected: ${expected_exit_code}

