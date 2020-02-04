*** Settings ***

Documentation     Run healthcheck
Library 	      RequestsLibrary
Resource          ./resources/cert-service-keywords.robot

Suite Setup      Create sessions


*** Test Cases ***

AAF Cert Service API Health Check
    [Tags]      AAF-CERT-SERVICE
    [Documentation]   Run healthcheck
    Run Healthcheck

AAF Cert Service API Send Valid CSR and Valid PK
    [Tags]      AAF-CERT-SERVICE
    [Documentation]  Send request to /v1/certificate/test endpoint and expect 200
    Send Request And Validate Response  ${CERT_PATH}  ${VALID_CSR_FILE}  ${VALID_PK_FILE}  200

AAF Cert Service API Send Invalid CSR and Valid PK
    [Tags]      AAF-CERT-SERVICE
    [Documentation]  Send request to /v1/certificate/test endpoint and expect 500
    Send Request And Validate Response  ${CERT_PATH}  ${INVALID_CSR_FILE}  ${VALID_PK_FILE}  400

AAF Cert Service API Send Valid CSR and Invalid PK
    [Tags]      AAF-CERT-SERVICE
    [Documentation]  Send request to /v1/certificate/test endpoint and expect 500
    Send Request And Validate Response  ${CERT_PATH}  ${VALID_CSR_FILE}  ${INVALID_PK_FILE}  400