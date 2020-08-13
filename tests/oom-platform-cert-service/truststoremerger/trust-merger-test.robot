*** Settings ***

Documentation     Truststore merger test case scenarios
Library 	      RequestsLibrary
Resource          ./resources/trust-merger-keywords.robot

*** Test Cases ***

Trust Merger fails when paths are invalid
    [Tags]      OOM-TRUST-STORE-MERGER
    [Documentation]  Run with invalid env file
    Run Trust Merger And Expect Error  ${INVALID_ENV_PATHS}  2

Trust Merger fails when list sizes are different
    [Tags]      OOM-TRUST-STORE-MERGER
    [Documentation]  Run with invalid env file
    Run Trust Merger And Expect Error  ${INVALID_ENV_LIST_SIZE}  2

Trust Merger fails when a variable is empty
    [Tags]      OOM-TRUST-STORE-MERGER
    [Documentation]  Run with invalid env file
    Run Trust Merger And Expect Error  ${INVALID_ENV_EMPTY_VARIABLES}  2

Trust Merger fails when password file pair is invalid
    [Tags]      OOM-TRUST-STORE-MERGER
    [Documentation]  Run with invalid env file
    Run Trust Merger And Expect Error  ${INVALID_ENV_FILE_PASSWORD}  3

Trust Merger fails when file extension is invalid
    [Tags]      OOM-TRUST-STORE-MERGER
    [Documentation]  Run with invalid env file
    Run Trust Merger And Expect Error  ${INVALID_ENV_EXTENSION}  1

Trust Merger merges successfully jks pem p12
    [Tags]      OOM-TRUST-STORE-MERGER
    [Documentation]  Run with valid env file
    Run Trust Merger And Merge Truststore Files To Jks  ${VALID_ENV_JKS_PEM_P12}  0  ${JKS_TRUSTSTORE_MOUNT_PATH}  ${TRUSTSTORE_JKS_PASS}  ${JKS_TRUSTSTORE_EXPECTED_PATH}

Trust Merger merges successfully pem p12
    [Tags]      OOM-TRUST-STORE-MERGER
    [Documentation]  Run with valid env file
    Run Trust Merger And Merge Truststore Files To Pem  ${VALID_ENV_PEM_P12}  0  ${PEM_TRUSTSTORE_MOUNT_PATH}  ${PEM_TRUSTSTORE_EXPECTED_PATH}

Trust Merger ends successfully with single truststore
    [Tags]      OOM-TRUST-STORE-MERGER
    [Documentation]  Run with valid env file
    Run Trust Merger And Merge Truststore Files To Jks  ${VALID_ENV_SINGLE_TRUSTSTORE}  0  ${JKS_TRUSTSTORE_MOUNT_PATH}  ${TRUSTSTORE_JKS_PASS}  ${TRUSTSTORE_JKS}
