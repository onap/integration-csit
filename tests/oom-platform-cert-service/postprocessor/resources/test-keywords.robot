*** Settings ***

Resource          ../../../common.robot
Resource          ./test-properties.robot
Library           ../libraries/PostProcessorDockerContainerUtils.py  ${MOUNT_PATH}  ${TRUSTSTORES_PATH}
Library           ../libraries/JksValidator.py
Library           ../libraries/PemTruststoreValidator.py

*** Keywords ***

Run Cert Service Post Processor And Expect Error
    [Documentation]  Run Cert Service Post Processor Container And Validate Exit Code
    [Arguments]   ${env_file}  ${expected_exit_code}
    ${exit_code}=  Run Container  ${CERT_POST_PROCESSOR_DOCKER_IMAGE}  ${CERT_POST_PROCESSOR_CONTAINER_NAME}  ${env_file}
    Remove Container And Save Logs  ${CERT_POST_PROCESSOR_CONTAINER_NAME}  negative_path
    Should Be Equal As Strings  ${exit_code}  ${expected_exit_code}  Client return unexpected exit code return: ${exitcode} , but expected: ${expected_exit_code}

Run Cert Service Post Processor And Merge Truststore Files To Jks
    [Documentation]  Run Cert Service Post Processor Container And Validate Exit Code And Provided Truststore Files
    [Arguments]  ${env_file}  ${expected_exit_code}  ${jks_path}  ${jks_password}  ${expected_jks_path}
    ${exit_code}=  Run Container  ${CERT_POST_PROCESSOR_DOCKER_IMAGE}  ${CERT_POST_PROCESSOR_CONTAINER_NAME}  ${env_file}
    ${files_equal}=  Assert Jks Truststores Equal  ${jks_path}  ${jks_password}  ${expected_jks_path}
    Remove Container And Save Logs  ${CERT_POST_PROCESSOR_CONTAINER_NAME}  positive_path
    Should Be Equal As Strings  ${exit_code}  ${expected_exit_code}  Client return unexpected exit code return: ${exitcode} , but expected: ${expected_exit_code}
    Should Be True  ${files_equal}

Run Cert Service Post Processor And Check Copied Keystore Files
    [Documentation]  Run Cert Service Post Processor Container And Validate Exit Code And Provided Keystore Files
    [Arguments]  ${env_file}  ${expected_exit_code}  ${jks_path}  ${jks_password}  ${expected_jks_path}
    ${exit_code}=  Run Container  ${CERT_POST_PROCESSOR_DOCKER_IMAGE}  ${CERT_POST_PROCESSOR_CONTAINER_NAME}  ${env_file}
    ${files_equal}=  Assert Jks Keystores Equal  ${jks_path}  ${jks_password}  ${expected_jks_path}
    Remove Container And Save Logs  ${CERT_POST_PROCESSOR_CONTAINER_NAME}  positive_path
    Should Be Equal As Strings  ${exit_code}  ${expected_exit_code}  Client return unexpected exit code return: ${exitcode} , but expected: ${expected_exit_code}
    Should Be True  ${files_equal}

Run Cert Service Post Processor And Merge Truststore Files To Pem
    [Documentation]  Run Cert Service Post Processor Container And Validate Exit Code And Files
    [Arguments]  ${env_file}  ${expected_exit_code}  ${pem_path}  ${expected_pem_path}
    ${exit_code}=  Run Container  ${CERT_POST_PROCESSOR_DOCKER_IMAGE}  ${CERT_POST_PROCESSOR_CONTAINER_NAME}  ${env_file}
    ${files_equal}=  Assert Pem Truststores Equal  ${pem_path}  ${expected_pem_path}
    Remove Container And Save Logs  ${CERT_POST_PROCESSOR_CONTAINER_NAME}  positive_path
    Should Be Equal As Strings  ${exit_code}  ${expected_exit_code}  Client return unexpected exit code return: ${exitcode} , but expected: ${expected_exit_code}
    Should Be True  ${files_equal}

