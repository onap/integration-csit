*** Settings ***

Documentation     AAF Cert Service API test case scenarios
Library 	      RequestsLibrary
Resource          ./resources/cert-service-keywords.robot

Suite Setup       Create sessions

*** Test Cases ***

Health Check
    [Tags]      AAF-CERT-SERVICE
    [Documentation]   Service is up and running
    Run Healthcheck

Reload Configuration
    [Tags]      AAF-CERT-SERVICE
    [Documentation]   Configuration was changed
    Send Get Request And Validate Response  /reload  200

Generate Certicicate For CA Name
    [Tags]      AAF-CERT-SERVICE
    [Documentation]  Send request to ${CERT_SERVICE_ENDPOINT}/${CA_NAME} endpoint and expect 200
    Send Get Request with Header And Validate Response  ${CERT_SERVICE_ENDPOINT}/${CA_NAME}  ${VALID_CSR_FILE}  ${VALID_PK_FILE}  200

Report Not Found Error When Path Is Not Valid
    [Tags]      AAF-CERT-SERVICE
    [Documentation]  Send request to ${CERT_SERVICE_ENDPOINT}/ endpoint and expect 404
    Send Get Request with Header And Validate Response  ${CERT_SERVICE_ENDPOINT}/  ${VALID_CSR_FILE}  ${VALID_PK_FILE}  404

Report Bad Request Error When Header Is Missing
    [Tags]      AAF-CERT-SERVICE
    [Documentation]  Send request without header to ${CERT_SERVICE_ENDPOINT}/${CA_NAME} endpoint and expect 400
    Send Get Request And Validate Response  ${CERT_SERVICE_ENDPOINT}/${CA_NAME}  400

Report Bad Request Error When CSR Is Not Valid
    [Tags]      AAF-CERT-SERVICE
    [Documentation]  Send request to ${CERT_SERVICE_ENDPOINT}/${CA_NAME} endpoint and expect 400
    Send Get Request with Header And Validate Response  ${CERT_SERVICE_ENDPOINT}/${CA_NAME}  ${INVALID_CSR_FILE}  ${VALID_PK_FILE}  400

Report Bad Request Error When PK Is Not Valid
    [Tags]      AAF-CERT-SERVICE
    [Documentation]  Send request to ${CERT_SERVICE_ENDPOINT}/${CA_NAME} endpoint and expect 400
    Send Get Request with Header And Validate Response  ${CERT_SERVICE_ENDPOINT}/${CA_NAME}  ${VALID_CSR_FILE}  ${INVALID_PK_FILE}  400
