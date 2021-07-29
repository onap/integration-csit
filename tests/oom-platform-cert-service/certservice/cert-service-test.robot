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

Generate Certificate In RA Endpoint For CA Name
    [Tags]      OOM-CERT-SERVICE    CERTIFICATE-INITIALIZATION
    [Documentation]  Send request to ${CERT_SERVICE_ENDPOINT}${RA_CA_NAME} endpoint and expect 200
    Send Get Request with Header And Expect Success  ${CERT_SERVICE_ENDPOINT}${RA_CA_NAME}  ${VALID_RA_CSR_FILE}  ${VALID_RA_PK_FILE}

Generate Certificate with all Sans types In RA Endpoint For CA Name
    [Tags]      OOM-CERT-SERVICE    CERTIFICATE-INITIALIZATION
    [Documentation]  Send request to ${CERT_SERVICE_ENDPOINT}${RA_CA_NAME} endpoint and expect 200
    Send Get Request with Header And Expect Success  ${CERT_SERVICE_ENDPOINT}${RA_CA_NAME}  ${VALID_RA_ALL_SANS_CSR_FILE}  ${VALID_RA_ALL_SANS_PK_FILE}

Report Not Found Error When Path To Service Is Not Valid
    [Tags]      OOM-CERT-SERVICE    CERTIFICATE-INITIALIZATION
    [Documentation]  Send request to ${CERT_SERVICE_ENDPOINT} endpoint and expect 404
    Send Get Request with Header And Expect Error  ${CERT_SERVICE_ENDPOINT}  ${VALID_CLIENT_CSR_FILE}  ${VALID_CLIENT_PK_FILE}  404

Report Bad Request Error When Header Is Missing In Request
    [Tags]      OOM-CERT-SERVICE    CERTIFICATE-INITIALIZATION
    [Documentation]  Send request without header to ${CERT_SERVICE_ENDPOINT}${CLIENT_CA_NAME} endpoint and expect 400
    Send Get Request And Validate Response  ${CERT_SERVICE_ENDPOINT}${CLIENT_CA_NAME}  400

Report Bad Request Error When CSR Is Not Valid
    [Tags]      OOM-CERT-SERVICE    CERTIFICATE-INITIALIZATION
    [Documentation]  Send request to ${CERT_SERVICE_ENDPOINT}${CLIENT_CA_NAME} endpoint and expect 400
    Send Get Request with Header And Expect Error  ${CERT_SERVICE_ENDPOINT}${CLIENT_CA_NAME}  ${INVALID_CSR_FILE}  ${VALID_CLIENT_PK_FILE}  400

Report Bad Request Error When PK Is Not Valid
    [Tags]      OOM-CERT-SERVICE    CERTIFICATE-INITIALIZATION
    [Documentation]  Send request to ${CERT_SERVICE_ENDPOINT}${CLIENT_CA_NAME} endpoint and expect 400
    Send Get Request with Header And Expect Error  ${CERT_SERVICE_ENDPOINT}${CLIENT_CA_NAME}  ${VALID_CLIENT_CSR_FILE}  ${INVALID_PK_FILE}  400

Update Certificate With Key Update Request In RA Endpoint Should Succeed
    [Tags]      OOM-CERT-SERVICE    CERTIFICATE-UPDATE
    [Documentation]  Send Initialization Request to ${CERT_SERVICE_ENDPOINT}${RA_CA_NAME} then for received certificate send Key Update Request to ${CERT_SERVICE_UPDATE_ENDPOINT}${RA_CA_NAME} endpoint and expect 200
    Send Initialization Request And Key Update Request And Expect Success  ${CERT_SERVICE_ENDPOINT}${RA_CA_NAME}  ${CERT_SERVICE_UPDATE_ENDPOINT}${RA_CA_NAME}
    ...  ${VALID_IR_CSR_FOR_UPDATE}  ${VALID_IR_KEY_FOR_UPDATE}  ${VALID_KUR_CSR}  ${VALID_KUR_KEY}

Update Certificate With Certification Request When Subject Changed In RA Endpoint Should Succeed
    [Tags]      OOM-CERT-SERVICE    CERTIFICATE-UPDATE
    [Documentation]  Send Initialization Request to ${CERT_SERVICE_ENDPOINT}${RA_CA_NAME} then for received certificate send Key Update Request to ${CERT_SERVICE_UPDATE_ENDPOINT}${RA_CA_NAME} endpoint and expect 200
    Send Initialization Request And Certification Request And Expect Success  ${CERT_SERVICE_ENDPOINT}${RA_CA_NAME}  ${CERT_SERVICE_UPDATE_ENDPOINT}${RA_CA_NAME}
    ...  ${VALID_IR_CSR_FOR_UPDATE}  ${VALID_IR_KEY_FOR_UPDATE}  ${VALID_CR_CSR_CHANGED_SUBJECT}  ${VALID_CR_KEY_CHANGED_SUBJECT}

Update Certificate With Certification Request When Sans Changed In RA Endpoint Should Succeed
    [Tags]      OOM-CERT-SERVICE    CERTIFICATE-UPDATE
    [Documentation]  Send Initialization Request to ${CERT_SERVICE_ENDPOINT}${RA_CA_NAME} then for received certificate send Key Update Request to ${CERT_SERVICE_UPDATE_ENDPOINT}${RA_CA_NAME} endpoint and expect 200
    Send Initialization Request And Certification Request And Expect Success  ${CERT_SERVICE_ENDPOINT}${RA_CA_NAME}  ${CERT_SERVICE_UPDATE_ENDPOINT}${RA_CA_NAME}
    ...  ${VALID_IR_CSR_FOR_UPDATE}  ${VALID_IR_KEY_FOR_UPDATE}  ${VALID_CR_CSR_CHANGED_SANS}  ${VALID_CR_KEY_CHANGED_SANS}

Update Certificate With Key Update Request In RA Endpoint Should Fail When Wrong Old Private Key Is Used
    [Tags]      OOM-CERT-SERVICE    CERTIFICATE-UPDATE
    [Documentation]  Send Initialization Request to ${CERT_SERVICE_ENDPOINT}${RA_CA_NAME} then for received certificate send Key Update Request to ${CERT_SERVICE_UPDATE_ENDPOINT}${RA_CA_NAME} endpoint and expect 500
    Send Initialization Request And Key Update Request With Wrong Old Private Key And Expect Error  ${CERT_SERVICE_ENDPOINT}${RA_CA_NAME}  ${CERT_SERVICE_UPDATE_ENDPOINT}${RA_CA_NAME}
    ...  ${VALID_IR_CSR_FOR_UPDATE}  ${VALID_IR_KEY_FOR_UPDATE}  ${VALID_KUR_CSR}  ${VALID_KUR_KEY}  ${INVALID_IR_KEY_FOR_UPDATE}

Update Certificate In RA Endpoint Should Fail When OLD_CERT Header Is Incorrect
    [Tags]      OOM-CERT-SERVICE    CERTIFICATE-UPDATE
    [Documentation]  Send Update Request to ${CERT_SERVICE_UPDATE_ENDPOINT}${RA_CA_NAME} endpoint with wrong OLD_CERT header and expect 400
    Send Update Request With Wrong Header And Expect Error   ${CERT_SERVICE_UPDATE_ENDPOINT}${RA_CA_NAME}
    ...  ${VALID_KUR_CSR}  ${VALID_KUR_KEY}  ${INVALID_OLD_CERT_BASE64}  ${VALID_IR_KEY_FOR_UPDATE}

Update Certificate In RA Endpoint Should Fail When OLD_CERT Header Is Missing
    [Tags]      OOM-CERT-SERVICE    CERTIFICATE-UPDATE
    [Documentation]  Send Update Request to ${CERT_SERVICE_UPDATE_ENDPOINT}${RA_CA_NAME} endpoint with missing OLD_CERT header and expect 400
    Send Update Request With Missing Header And Expect Error   ${CERT_SERVICE_UPDATE_ENDPOINT}${RA_CA_NAME}
    ...  ${VALID_KUR_CSR}  ${VALID_KUR_KEY}  ${VALID_OLD_CERT_BASE64}  ${VALID_IR_KEY_FOR_UPDATE}  OLD_CERT

Update Certificate In RA Endpoint Should Fail When OLD_PK Header Is Incorrect
    [Tags]      OOM-CERT-SERVICE    CERTIFICATE-UPDATE
    [Documentation]  Send Update Request to ${CERT_SERVICE_UPDATE_ENDPOINT}${RA_CA_NAME} endpoint with wrong OLD_PK header and expect 400
    Send Update Request With Wrong Header And Expect Error   ${CERT_SERVICE_UPDATE_ENDPOINT}${RA_CA_NAME}
    ...  ${VALID_KUR_CSR}  ${VALID_KUR_KEY}  ${VALID_OLD_CERT_BASE64}  ${INVALID_PK_FILE}

Update Certificate In RA Endpoint Should Fail When OLD_PK Header Is Missing
    [Tags]      OOM-CERT-SERVICE    CERTIFICATE-UPDATE
    [Documentation]  Send Update Request to ${CERT_SERVICE_UPDATE_ENDPOINT}${RA_CA_NAME} endpoint with missing OLD_PK header and expect 400
    Send Update Request With Missing Header And Expect Error   ${CERT_SERVICE_UPDATE_ENDPOINT}${RA_CA_NAME}
    ...  ${VALID_KUR_CSR}  ${VALID_KUR_KEY}  ${VALID_OLD_CERT_BASE64}  ${VALID_IR_KEY_FOR_UPDATE}  OLD_PK

Update Certificate In RA Endpoint Should Fail When CSR Header Is Incorrect
    [Tags]      OOM-CERT-SERVICE    CERTIFICATE-UPDATE
    [Documentation]  Send Update Request to ${CERT_SERVICE_UPDATE_ENDPOINT}${RA_CA_NAME} endpoint with wrong CSR header and expect 400
    Send Update Request With Wrong Header And Expect Error   ${CERT_SERVICE_UPDATE_ENDPOINT}${RA_CA_NAME}
    ...  ${INVALID_CSR_FILE}  ${VALID_KUR_KEY}  ${VALID_OLD_CERT_BASE64}  ${VALID_IR_KEY_FOR_UPDATE}

Update Certificate In RA Endpoint Should Fail When CSR Header Is Missing
    [Tags]      OOM-CERT-SERVICE    CERTIFICATE-UPDATE
    [Documentation]  Send Update Request to ${CERT_SERVICE_UPDATE_ENDPOINT}${RA_CA_NAME} endpoint with missing CSR header and expect 400
    Send Update Request With Missing Header And Expect Error   ${CERT_SERVICE_UPDATE_ENDPOINT}${RA_CA_NAME}
    ...  ${VALID_KUR_CSR}  ${VALID_KUR_KEY}  ${VALID_OLD_CERT_BASE64}  ${VALID_IR_KEY_FOR_UPDATE}  CSR

Update Certificate In RA Endpoint Should Fail When PK Header Is Incorrect
    [Tags]      OOM-CERT-SERVICE    CERTIFICATE-UPDATE
    [Documentation]  Send Update Request to ${CERT_SERVICE_UPDATE_ENDPOINT}${RA_CA_NAME} endpoint with wrong PK header and expect 400
    Send Update Request With Wrong Header And Expect Error   ${CERT_SERVICE_UPDATE_ENDPOINT}${RA_CA_NAME}
    ...  ${VALID_KUR_CSR}  ${INVALID_PK_FILE}  ${VALID_OLD_CERT_BASE64}  ${VALID_IR_KEY_FOR_UPDATE}

Update Certificate In RA Endpoint Should Fail When PK Header Is Missing
    [Tags]      OOM-CERT-SERVICE    CERTIFICATE-UPDATE
    [Documentation]  Send Update Request to ${CERT_SERVICE_UPDATE_ENDPOINT}${RA_CA_NAME} endpoint with missing PK header and expect 400
    Send Update Request With Missing Header And Expect Error   ${CERT_SERVICE_UPDATE_ENDPOINT}${RA_CA_NAME}
    ...  ${VALID_KUR_CSR}  ${VALID_KUR_KEY}  ${VALID_OLD_CERT_BASE64}  ${VALID_IR_KEY_FOR_UPDATE}  PK

Cert Service Client successfully creates keystore.p12 and truststore.p12
    [Tags]      OOM-CERT-SERVICE    OOM-CERT-SERVICE-CLIENT
    [Documentation]  Run with correct env and expected exit code 0
    Run Cert Service Client And Validate PKCS12 File Creation And Client Exit Code  ${VALID_ENV_FILE}  0

Cert Service Client successfully creates keystore.jks and truststore.jks
    [Tags]      OOM-CERT-SERVICE    OOM-CERT-SERVICE-CLIENT
    [Documentation]  Run with correct env and expected exit code 0
    Run Cert Service Client And Validate JKS File Creation And Client Exit Code  ${VALID_ENV_FILE_JKS}  0

Cert Service Client successfully creates keystore and truststore with expected data with no OUTPUT_TYPE
    [Tags]      OOM-CERT-SERVICE    OOM-CERT-SERVICE-CLIENT
    [Documentation]  Run with correct env and PKCS12 files created with correct data
    Run Cert Service Client And Validate PKCS12 Files Contain Expected Data  ${VALID_ENV_FILE}  0

Cert Service Client successfully creates keystore and truststore with all SANs types provided
    [Tags]      OOM-CERT-SERVICE    OOM-CERT-SERVICE-CLIENT
    [Documentation]  Run with correct env and expected exit code 0
    Run Cert Service Client And Validate PKCS12 Files Contain Expected Data  ${VALID_ENV_FILE_ALL_SANS_TYPES}  0

Cert Service Client successfully creates keystore and truststore with expected data with OUTPUT_TYPE=JKS
    [Tags]      OOM-CERT-SERVICE    OOM-CERT-SERVICE-CLIENT
    [Documentation]  Run with correct env and JKS files created with correct data
    Run Cert Service Client And Validate JKS Files Contain Expected Data  ${VALID_ENV_FILE_JKS}  0

Cert Service Client successfully creates keystore and truststore with expected data with OUTPUT_TYPE=P12
    [Tags]      OOM-CERT-SERVICE    OOM-CERT-SERVICE-CLIENT
    [Documentation]  Run with correct env and PKCS12 files created with correct data
    Run Cert Service Client And Validate PKCS12 Files Contain Expected Data  ${VALID_ENV_FILE_P12}  0

Cert Service Client successfully creates keystore and truststore with expected data with OUTPUT_TYPE=PEM
    [Tags]      OOM-CERT-SERVICE    OOM-CERT-SERVICE-CLIENT
    [Documentation]  Run with correct env and PEM files created with correct data
    Run Cert Service Client And Validate PEM Files Contain Expected Data  ${VALID_ENV_FILE_PEM}  0

Cert Service Client reports error when OUTPUT_TYPE is invalid
    [Tags]      OOM-CERT-SERVICE    OOM-CERT-SERVICE-CLIENT
    [Documentation]  Run with invalid OUTPUT_TYPE env and expected exit code 1
    Run Cert Service Client And Validate Client Exit Code  ${INVALID_ENV_FILE_OUTPUT_TYPE}  1

Run Cert Service Client Container And Validate Exit Code And API Response
    [Tags]      OOM-CERT-SERVICE    OOM-CERT-SERVICE-CLIENT
    [Documentation]  Run with invalid CaName env and expected exit code 5
    Run Cert Service Client And Validate Http Response Code And Client Exit Code  ${INVALID_ENV_FILE}  404  5

