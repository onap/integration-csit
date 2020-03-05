*** Settings ***

Documentation     AAF Cert Service API test case scenarios
Library 	      RequestsLibrary
Resource          ./resources/cert-service-keywords.robot

Suite Setup       Create sessions

*** Test Cases ***

Health Check
    [Tags]      AAF-CERT-SERVICE
    [Documentation]   Service is up and running
    Run health check

Reload Configuration
    [Tags]      AAF-CERT-SERVICE
    [Documentation]   Configuration was changed
    Send Get Request And Validate Response  /reload  200

Generate Certificate In RA Mode For CA Name
    [Tags]      AAF-CERT-SERVICE
    [Documentation]  Send request to ${CERT_SERVICE_ENDPOINT}/${RA_CA_NAME} endpoint and expect 200
    Send Get Request with Header And Expect Success  ${CERT_SERVICE_ENDPOINT}/${RA_CA_NAME}  ${VALID_RA_CSR_FILE}  ${VALID_RA_PK_FILE}

Report Not Found Error When Path To Service Is Not Valid
    [Tags]      AAF-CERT-SERVICE
    [Documentation]  Send request to ${CERT_SERVICE_ENDPOINT}/ endpoint and expect 404
    Send Get Request with Header And Expect Error  ${CERT_SERVICE_ENDPOINT}/  ${VALID_CLIENT_CSR_FILE}  ${VALID_CLIENT_PK_FILE}  404

Report Bad Request Error When Header Is Missing In Request
    [Tags]      AAF-CERT-SERVICE
    [Documentation]  Send request without header to ${CERT_SERVICE_ENDPOINT}/${CLIENT_CA_NAME} endpoint and expect 400
    Send Get Request And Validate Response  ${CERT_SERVICE_ENDPOINT}/${CLIENT_CA_NAME}  400

Report Bad Request Error When CSR Is Not Valid
    [Tags]      AAF-CERT-SERVICE
    [Documentation]  Send request to ${CERT_SERVICE_ENDPOINT}/${CLIENT_CA_NAME} endpoint and expect 400
    Send Get Request with Header And Expect Error  ${CERT_SERVICE_ENDPOINT}/${CLIENT_CA_NAME}  ${INVALID_CSR_FILE}  ${VALID_CLIENT_PK_FILE}  400

Report Bad Request Error When PK Is Not Valid
    [Tags]      AAF-CERT-SERVICE
    [Documentation]  Send request to ${CERT_SERVICE_ENDPOINT}/${CLIENT_CA_NAME} endpoint and expect 400
    Send Get Request with Header And Expect Error  ${CERT_SERVICE_ENDPOINT}/${CLIENT_CA_NAME}  ${VALID_CLIENT_CSR_FILE}  ${INVALID_PK_FILE}  400

AAF Cert Service Client run with valid evniroment variable
    [Tags]      AAF-CERT-SERVICE
    [Documentation]  Run with correct env and expected exit code 0
    Run Cert Service Client Container And Validate Exit Code  ${VALID_ENV_FILE}  0

AAF Cert Service Client run with invalid evniroment variable
    [Tags]      AAF-CERT-SERVICE
    [Documentation]  Run with invalid CaName env and expected exit code 5
    Run Cert Service Client Container And Validate Exit Code  ${INVALID_ENV_FILE}  5

