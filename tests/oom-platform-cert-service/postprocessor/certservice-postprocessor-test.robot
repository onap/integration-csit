*** Settings ***

Documentation     Certifcate Post Processors test case scenarios
Library 	        RequestsLibrary
Resource          ./resources/test-keywords.robot

*** Test Cases ***

Cert Post Processor fails when file extension is invalid (merger)
    [Tags]      OOM-CERTSERVICE-POST-PROCESSOR
    [Documentation]  Run with invalid truststore extension env and expect error code
    Run Cert Service Post Processor And Expect Error  ${ENV_FILE_INVALID_FILE_EXTENSION}  ${EXITCODE_CERTIFICATES_PATHS_VALIDATION_EXCEPTION}

Cert Post Processor fails when a variable is empty (merger)
    [Tags]      OOM-CERTSERVICE-POST-PROCESSOR
    [Documentation]  Run with empty truststore password path env and expect error code
    Run Cert Service Post Processor And Expect Error  ${ENV_FILE_EMPTY_PASSWORDS}  ${EXITCODE_CERTIFICATES_PATHS_VALIDATION_EXCEPTION}

Cert Post Processor fails when truststore and passwords envs not provided (merger)
    [Tags]      OOM-CERTSERVICE-POST-PROCESSOR
    [Documentation]  Run with invalid empty envs and expect error code
    Run Cert Service Post Processor And Expect Error  ${ENV_FILE_EMPTY}  ${EXITCODE_CONFIGURATION_EXCEPTION}

Cert Post Processor fails when list sizes are different (merger)
    [Tags]      OOM-CERTSERVICE-POST-PROCESSOR
    [Documentation]  Run with different truststore and password envs size and expect error code
    Run Cert Service Post Processor And Expect Error  ${ENV_FILE_INVALID_FILE_LIST_SIZE}  ${EXITCODE_CONFIGURATION_EXCEPTION}

Cert Post Processor fails when truststore paths are invalid (merger)
    [Tags]      OOM-CERTSERVICE-POST-PROCESSOR
    [Documentation]  Run with invalid truststore path and expect error code
    Run Cert Service Post Processor And Expect Error  ${ENV_FILE_INVALID_TRUSTSTORE_PATHS}  ${EXITCODE_TRUSTSTORE_FILE_FACTORY_EXCEPTION}

Cert Post Processor fails when password path is invalid (merger)
    [Tags]      OOM-CERTSERVICE-POST-PROCESSOR
    [Documentation]  Run with invalid password path and expect error code
    Run Cert Service Post Processor And Expect Error  ${ENV_FILE_INVALID_PASSWORD_PATHS}  ${EXITCODE_PASSWORD_READER_EXCEPTION}

Cert Post Processor fails when password file pair is invalid (merger)
    [Tags]      OOM-CERTSERVICE-POST-PROCESSOR
    [Documentation]  Run with incorrect password env and expect error code
    Run Cert Service Post Processor And Expect Error  ${ENV_FILE_INVALID_PASSWORD}  ${EXITCODE_TRUSTSTORE_LOAD_FILE_EXCEPTION}

Cert Post Processor fails when pem does not contain cert (merger)
    [Tags]      OOM-CERTSERVICE-POST-PROCESSOR
    [Documentation]  Run with empty pem truststore and expect error code
    Run Cert Service Post Processor And Expect Error  ${ENV_FILE_EMPTY_CERTS}  ${EXITCODE_MISSING_TRUSTSTORE_EXCEPTIONSUCCESS}

Cert Post Processor fails when aliases are duplicated (merger)
    [Tags]      OOM-CERTSERVICE-POST-PROCESSOR
    [Documentation]  Run with duplicated aliases in truststores and expect error code
    Run Cert Service Post Processor And Expect Error  ${ENV_FILE_DUPLICATED_ALIASES}  ${EXITCODE_ALIAS_CONFLICT_EXCEPTION}

Cert Post Processor merges successfully jks pem p12 (merger)
    [Tags]      OOM-CERTSERVICE-POST-PROCESSOR
    [Documentation]  Run with valid env file and expect merged certs from jks, pem and p12
    Run Cert Service Post Processor And Merge Truststore Files To Jks  ${ENV_FILE_JKS_PEM_P12}  ${EXITCODE_SUCCESS}  ${JKS_TRUSTSTORE_MOUNT_PATH}  ${TRUSTSTORE_JKS_PASS}  ${JKS_TRUSTSTORE_EXPECTED_PATH}

Cert Post Processor merges successfully pem p12 (merger)
    [Tags]      OOM-CERTSERVICE-POST-PROCESSOR
    [Documentation]  Run with valid env file and expect merged certs from pem and p12
    Run Cert Service Post Processor And Merge Truststore Files To Pem  ${ENV_FILE_PEM_P12}  ${EXITCODE_SUCCESS}  ${PEM_TRUSTSTORE_MOUNT_PATH}  ${PEM_TRUSTSTORE_EXPECTED_PATH}

Cert Post Processor ends successfully with single truststore (merger)
    [Tags]      OOM-CERTSERVICE-POST-PROCESSOR
    [Documentation]  Run with one truststore in env file and expect code 0
    Run Cert Service Post Processor And Merge Truststore Files To Jks  ${ENV_FILE_SINGLE_TRUSTSTORE}  ${EXITCODE_SUCCESS}  ${JKS_TRUSTSTORE_MOUNT_PATH}  ${TRUSTSTORE_JKS_PASS}  ${TRUSTSTORE_JKS}

Cert Post Processor fails when file to copy does not exist (merger)
    [Tags]      OOM-CERTSERVICE-POST-PROCESSOR
    [Documentation]  Run with invalid extra optional env as a path to file and expect error code
    Run Cert Service Post Processor And Expect Error  ${ENV_FILE_INVALID_KEYSTORE_SOURCE_PATHS}  ${EXITCODE_KEYSTORE_NOT_EXIST_EXCEPTION}

Cert Post Processor fails when only one extra optional env is set (merger)
    [Tags]      OOM-CERTSERVICE-POST-PROCESSOR
    [Documentation]  Run with empty extra optional env and expect code
    Run Cert Service Post Processor And Expect Error  ${ENV_FILE_EMPTY_KEYSTORE_DESTINATION_PATH}  ${EXITCODE_CONFIGURATION_EXCEPTION}

Cert Post Processor successfully backs up files (copier)
    [Tags]      OOM-CERTSERVICE-POST-PROCESSOR
    [Documentation]  Run with valid env file and expect successfully backed up file
    Run Cert Service Post Processor And Check Copied Keystore Files  ${ENV_FILE_EXTRA_OPTIONAL_ENVS}  ${EXITCODE_SUCCESS}  ${JKS_KEYSTORE_MOUNT_PATH}  ${KEYSTORE_JKS_PASS}  ${JKSBAK_KEYSTORE_EXPECTED_PATH}

Cert Post Processor successfully copies file (copier)
    [Tags]      OOM-CERTSERVICE-POST-PROCESSOR
    [Documentation]  Run with valid env file and expect successfully copied file
    Run Cert Service Post Processor And Check Copied Keystore Files  ${ENV_FILE_EXTRA_OPTIONAL_ENVS}  ${EXITCODE_SUCCESS}  ${JKS_KEYSTORE_MOUNT_PATH}  ${KEYSTORE_JKS_PASS}  ${JKS_KEYSTORE_EXPECTED_PATH}

