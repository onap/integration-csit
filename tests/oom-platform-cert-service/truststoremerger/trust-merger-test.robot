*** Settings ***

Documentation     Truststore merger test case scenarios
Library 	      RequestsLibrary
Resource          ./resources/trust-merger-keywords.robot

*** Test Cases ***

Trust Merger fails when file extension is invalid
    [Tags]      OOM-TRUST-STORE-MERGER
    [Documentation]  Run with invalid truststore extension env and expect error code
    Run Trust Merger And Expect Error  ${INVALID_ENV_FILE_EXTENSION}  1

Trust Merger fails when a variable is empty
    [Tags]      OOM-TRUST-STORE-MERGER
    [Documentation]  Run with empty truststore password path env and expect error code
    Run Trust Merger And Expect Error  ${INVALID_ENV_FILE_EMPTY_PASSWORDS}  1

Trust Merger fails when truststore and passwords envs not provided
    [Tags]      OOM-TRUST-STORE-MERGER
    [Documentation]  Run with invalid empty envs and expect error code
    Run Trust Merger And Expect Error  ${INVALID_ENV_FILE_EMPTY}  2

Trust Merger fails when list sizes are different
    [Tags]      OOM-TRUST-STORE-MERGER
    [Documentation]  Run with different truststore and password envs size and expect error code
    Run Trust Merger And Expect Error  ${INVALID_ENV_FILE_LIST_SIZE}  2

Trust Merger fails when truststore paths are invalid
    [Tags]      OOM-TRUST-STORE-MERGER
    [Documentation]  Run with invalid truststore path and expect error code
    Run Trust Merger And Expect Error  ${INVALID_ENV_FILE_TRUSTSTORE_PATHS}  3

Trust Merger fails when password path is invalid
    [Tags]      OOM-TRUST-STORE-MERGER
    [Documentation]  Run with invalid password path and expect error code
    Run Trust Merger And Expect Error  ${INVALID_ENV_FILE_PASSWORD_PATHS}  4

Trust Merger fails when password file pair is invalid
    [Tags]      OOM-TRUST-STORE-MERGER
    [Documentation]  Run with incorrect password env and expect error code
    Run Trust Merger And Expect Error  ${INVALID_ENV_FILE_PASSWORD}  7

Trust Merger fails when pem does not contain cert
    [Tags]      OOM-TRUST-STORE-MERGER
    [Documentation]  Run with empty pem truststore and expect error code
    Run Trust Merger And Expect Error  ${INVALID_ENV_FILE_EMPTY_CERTS}  9

Trust Merger fails when aliases are duplicated
    [Tags]      OOM-TRUST-STORE-MERGER
    [Documentation]  Run with duplicated aliases in truststores and expect error code
    Run Trust Merger And Expect Error  ${INVALID_ENV_FILE_DUPLICATED_ALIASES}  10

Trust Merger merges successfully jks pem p12
    [Tags]      OOM-TRUST-STORE-MERGER
    [Documentation]  Run with valid env file and expect merged certs from jks, pem and p12
    Run Trust Merger And Merge Truststore Files To Jks  ${VALID_ENV_FILE_JKS_PEM_P12}  0  ${JKS_TRUSTSTORE_MOUNT_PATH}  ${TRUSTSTORE_JKS_PASS}  ${JKS_TRUSTSTORE_EXPECTED_PATH}

Trust Merger merges successfully pem p12
    [Tags]      OOM-TRUST-STORE-MERGER
    [Documentation]  Run with valid env file and expect merged certs from pem and p12
    Run Trust Merger And Merge Truststore Files To Pem  ${VALID_ENV_FILE_PEM_P12}  0  ${PEM_TRUSTSTORE_MOUNT_PATH}  ${PEM_TRUSTSTORE_EXPECTED_PATH}

Trust Merger ends successfully with single truststore
    [Tags]      OOM-TRUST-STORE-MERGER
    [Documentation]  Run with one truststore in env file and expect code 0
    Run Trust Merger And Merge Truststore Files To Jks  ${VALID_ENV_FILE_SINGLE_TRUSTSTORE}  0  ${JKS_TRUSTSTORE_MOUNT_PATH}  ${TRUSTSTORE_JKS_PASS}  ${TRUSTSTORE_JKS}

Trust Merger fails when file to copy does not exist
    [Tags]      OOM-TRUST-STORE-MERGER
    [Documentation]  Run with invalid extra optional env as a path to file and expect error code
    Run Trust Merger And Expect Error  ${INVALID_KEYSTORE_SOURCE_PATHS}  13

Trust Merger fails when only one extra optional env is set
    [Tags]      OOM-TRUST-STORE-MERGER
    [Documentation]  Run with empty extra optional env and expect code
    Run Trust Merger And Expect Error  ${INVALID_EMPTY_KEYSTORE_DESTINATION_PATH}  2

Trust Merger's Copier successfully backs up files
    [Tags]      OOM-TRUST-STORE-MERGER
    [Documentation]  Run with valid env file and expect successfully backed up file
    Run Trust Merger And Merge Truststore Files To Jks  ${VALID_ENVS_AND_EXTRA_OPTIONAL_ENVS}  0  ${JKS_KEYSTORE_MOUNT_PATH}  ${KEYSTORE_JKS_PASS}  ${JKS_KEYSTORE_EXPECTED_PATH}

Trust Merger's Copier successfully copies file
    [Tags]      OOM-TRUST-STORE-MERGER
    [Documentation]  Run with valid env file and expect successfully copied file
    Run Trust Merger And Merge Truststore Files To Jks  ${VALID_ENVS_AND_EXTRA_OPTIONAL_ENVS}  0  ${JKS_KEYSTORE_MOUNT_PATH}  ${KEYSTORE_JKS_PASS}  ${JKS_KEYSTORE_EXPECTED_PATH}

