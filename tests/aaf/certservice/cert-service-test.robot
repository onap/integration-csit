*** Settings ***

Documentation     AAF test case scenarios
Library 	      RequestsLibrary
Resource          ./resources/cert-service-keywords.robot

Suite Setup       Create sessions

*** Test Cases ***

AAF Cert Service API Health Check
    [Tags]      AAF-CERT-SERVICE
    [Documentation]   Run healthcheck
    Run Healthcheck

AAF Cert Service API Reload Configuration
    [Tags]      AAF-CERT-SERVICE
    [Documentation]   Reload configuration
    Send Post Request And Validate Response  /actuator/refresh  200

AAF Cert Service API Send Valid CSR and Valid PK
    [Tags]      AAF-CERT-SERVICE
    [Documentation]  Send request to ${CERT_PATH} endpoint and expect 200
    Send Get Request with Header And Validate Response  ${CERT_PATH}  ${VALID_CSR_FILE}  ${VALID_PK_FILE}  200

AAF Cert Service API Send Valid CSR and Valid PK to Wrong Path
    [Tags]      AAF-CERT-SERVICE
    [Documentation]  Send request to /v1/certificate/ endpoint and expect 404
    Send Get Request with Header And Validate Response  /v1/certificate/  ${VALID_CSR_FILE}  ${VALID_PK_FILE}  404

AAF Cert Service API Send Request without Header
    [Tags]      AAF-CERT-SERVICE
    [Documentation]  Send request without header to ${CERT_PATH} endpoint and expect 400
    Send Get Request And Validate Response  ${CERT_PATH}  400

AAF Cert Service API Send Invalid CSR and Valid PK
    [Tags]      AAF-CERT-SERVICE
    [Documentation]  Send request to ${CERT_PATH} endpoint and expect 400
    Send Get Request with Header And Validate Response  ${CERT_PATH}  ${INVALID_CSR_FILE}  ${VALID_PK_FILE}  400

AAF Cert Service API Send Valid CSR and Invalid PK
    [Tags]      AAF-CERT-SERVICE
    [Documentation]  Send request to ${CERT_PATH} endpoint and expect 400
    Send Get Request with Header And Validate Response  ${CERT_PATH}  ${VALID_CSR_FILE}  ${INVALID_PK_FILE}  400
