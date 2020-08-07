*** Settings ***

Documentation     OOM Cert Service API test case scenarios
Library 	      RequestsLibrary
Resource          ./resources/cert-service-keywords.robot

Suite Setup       Create sessions

*** Test Cases ***

Health Check
    [Tags]      OOM-CERT-SERVICE
    [Documentation]   Service is up and running
    Run health check

Reload Configuration
    [Tags]      OOM-CERT-SERVICE
    [Documentation]   Configuration was changed
    Send Get Request And Validate Response  /reload  200

Check if application is ready
    [Tags]      OOM-CERT-SERVICE
    [Documentation]   Send request to /ready endpoint and expect 200
    Send Get Request And Validate Response  /ready  200

Generate Certificate In RA Mode For CA Name
    [Tags]      OOM-CERT-SERVICE
    [Documentation]  Send request to ${CERT_SERVICE_ENDPOINT}${RA_CA_NAME} endpoint and expect 200
    Send Get Request with Header And Expect Success  ${CERT_SERVICE_ENDPOINT}${RA_CA_NAME}  ${VALID_RA_CSR_FILE}  ${VALID_RA_PK_FILE}

Report Not Found Error When Path To Service Is Not Valid
    [Tags]      OOM-CERT-SERVICE
    [Documentation]  Send request to ${CERT_SERVICE_ENDPOINT} endpoint and expect 404
    Send Get Request with Header And Expect Error  ${CERT_SERVICE_ENDPOINT}  ${VALID_CLIENT_CSR_FILE}  ${VALID_CLIENT_PK_FILE}  404

Report Bad Request Error When Header Is Missing In Request
    [Tags]      OOM-CERT-SERVICE
    [Documentation]  Send request without header to ${CERT_SERVICE_ENDPOINT}${CLIENT_CA_NAME} endpoint and expect 400
    Send Get Request And Validate Response  ${CERT_SERVICE_ENDPOINT}${CLIENT_CA_NAME}  400

Report Bad Request Error When CSR Is Not Valid
    [Tags]      OOM-CERT-SERVICE
    [Documentation]  Send request to ${CERT_SERVICE_ENDPOINT}${CLIENT_CA_NAME} endpoint and expect 400
    Send Get Request with Header And Expect Error  ${CERT_SERVICE_ENDPOINT}${CLIENT_CA_NAME}  ${INVALID_CSR_FILE}  ${VALID_CLIENT_PK_FILE}  400

Report Bad Request Error When PK Is Not Valid
    [Tags]      OOM-CERT-SERVICE
    [Documentation]  Send request to ${CERT_SERVICE_ENDPOINT}${CLIENT_CA_NAME} endpoint and expect 400
    Send Get Request with Header And Expect Error  ${CERT_SERVICE_ENDPOINT}${CLIENT_CA_NAME}  ${VALID_CLIENT_CSR_FILE}  ${INVALID_PK_FILE}  400

Cert Service Client successfully creates keystore.p12 and truststore.p12
    [Tags]      OOM-CERT-SERVICE
    [Documentation]  Run with correct env and expected exit code 0
    Run Cert Service Client And Validate PKCS12 File Creation And Client Exit Code  ${VALID_ENV_FILE}  0

Cert Service Client successfully creates keystore.jks and truststore.jks
    [Tags]      OOM-CERT-SERVICE
    [Documentation]  Run with correct env and expected exit code 0
    Run Cert Service Client And Validate JKS File Creation And Client Exit Code  ${VALID_ENV_FILE_JKS}  0

Cert Service Client successfully creates keystore and truststore with expected data with no OUTPUT_TYPE
    [Tags]      OOM-CERT-SERVICE
    [Documentation]  Run with correct env and PKCS12 files created with correct data
    Run Cert Service Client And Validate PKCS12 Files Contain Expected Data  ${VALID_ENV_FILE}  0

Cert Service Client successfully creates keystore and truststore with expected data with OUTPUT_TYPE=JKS
    [Tags]      OOM-CERT-SERVICE
    [Documentation]  Run with correct env and JKS files created with correct data
    Run Cert Service Client And Validate JKS Files Contain Expected Data  ${VALID_ENV_FILE_JKS}  0

Cert Service Client successfully creates keystore and truststore with expected data with OUTPUT_TYPE=P12
    [Tags]      OOM-CERT-SERVICE
    [Documentation]  Run with correct env and PKCS12 files created with correct data
    Run Cert Service Client And Validate PKCS12 Files Contain Expected Data  ${VALID_ENV_FILE_P12}  0

Cert Service Client successfully creates keystore and truststore with expected data with OUTPUT_TYPE=PEM
    [Tags]      OOM-CERT-SERVICE
    [Documentation]  Run with correct env and PEM files created with correct data
    Run Cert Service Client And Validate PEM Files Contain Expected Data  ${VALID_ENV_FILE_PEM}  0

Cert Service Client reports error when OUTPUT_TYPE is invalid
    [Tags]      OOM-CERT-SERVICE
    [Documentation]  Run with invalid OUTPUT_TYPE env and expected exit code 1
    Run Cert Service Client And Validate Client Exit Code  ${INVALID_ENV_FILE_OUTPUT_TYPE}  1

Run Cert Service Client Container And Validate Exit Code And API Response
    [Tags]      OOM-CERT-SERVICE
    [Documentation]  Run with invalid CaName env and expected exit code 5
    Run Cert Service Client And Validate Http Response Code And Client Exit Code  ${INVALID_ENV_FILE}  404  5

