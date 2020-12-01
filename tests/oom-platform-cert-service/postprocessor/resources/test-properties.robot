*** Variables ***

${CERT_POST_PROCESSOR_DOCKER_IMAGE}                   nexus3.onap.org:10001/onap/org.onap.oom.platform.cert-service.oom-certservice-post-processor:guilin-latest
${CERT_POST_PROCESSOR_CONTAINER_NAME}                 %{CertServicePostProcessorContainerName}
${BASE_PATH}                                          %{WORKSPACE}/tests/oom-platform-cert-service/postprocessor
${MOUNT_PATH}                                         ${BASE_PATH}/tmp
${TRUSTSTORES_PATH}                                   ${BASE_PATH}/assets/truststores
${EXPECTED_TRUSTSTORES_PATH}                          ${BASE_PATH}/assets/expected_truststores

${JKS_TRUSTSTORE_MOUNT_PATH}                          ${BASE_PATH}/tmp/truststore.jks
${JKS_PASSWORD_MOUNT_PATH}                            ${BASE_PATH}/tmp/truststoreJks.pass
${P12_TRUSTSTORE_MOUNT_PATH}                          ${BASE_PATH}/tmp/truststore.p12
${P12_PASSWORD_MOUNT_PATH}                            ${BASE_PATH}/tmp/truststoreP12.pass
${PEM_TRUSTSTORE_MOUNT_PATH}                          ${BASE_PATH}/tmp/truststore.pem
${JKS_KEYSTORE_MOUNT_PATH}                            ${BASE_PATH}/tmp/external/keystore.jks

${JKS_TRUSTSTORE_EXPECTED_PATH}                       ${BASE_PATH}/assets/expected_truststores/jksAndPemAndP12.jks
${PEM_TRUSTSTORE_EXPECTED_PATH}                       ${BASE_PATH}/assets/expected_truststores/pemAndP12.pem
${JKSBAK_KEYSTORE_EXPECTED_PATH}                      ${BASE_PATH}/assets/expected_keystores/keystore.jks.bak
${JKS_KEYSTORE_EXPECTED_PATH}                         ${BASE_PATH}/assets/expected_keystores/keystore.jks

${ENV_FILE_EMPTY}                                     ${BASE_PATH}/assets/invalid_empty_file.env
${ENV_FILE_INVALID_FILE_LIST_SIZE}                    ${BASE_PATH}/assets/invalid_different_lists_size.env
${ENV_FILE_EMPTY_PASSWORDS}                           ${BASE_PATH}/assets/invalid_empty_passwords.env
${ENV_FILE_INVALID_PASSWORD_PATHS}                    ${BASE_PATH}/assets/invalid_password_path.env
${ENV_FILE_INVALID_TRUSTSTORE_PATHS}                  ${BASE_PATH}/assets/invalid_truststore_paths.env
${ENV_FILE_INVALID_PASSWORD}                          ${BASE_PATH}/assets/invalid_file_password_pair.env
${ENV_FILE_INVALID_FILE_EXTENSION}                    ${BASE_PATH}/assets/invalid_extension.env
${ENV_FILE_DUPLICATED_ALIASES}                        ${BASE_PATH}/assets/invalid_duplicated_aliases.env
${ENV_FILE_EMPTY_CERTS}                               ${BASE_PATH}/assets/invalid_empty_certs.env
${ENV_FILE_JKS_PEM_P12}                               ${BASE_PATH}/assets/valid_jks_pem_p12.env
${ENV_FILE_PEM_P12}                                   ${BASE_PATH}/assets/valid_pem_p12.env
${ENV_FILE_SINGLE_TRUSTSTORE}                         ${BASE_PATH}/assets/valid_single_truststore.env
${ENV_FILE_INVALID_KEYSTORE_SOURCE_PATHS}             ${BASE_PATH}/assets/invalid_keystore_source_paths.env
${ENV_FILE_EMPTY_KEYSTORE_DESTINATION_PATH}           ${BASE_PATH}/assets/invalid_empty_keystore_destination_path.env
${ENV_FILE_EXTRA_OPTIONAL_ENVS}                       ${BASE_PATH}/assets/valid_envs_and_extra_optional.env

${KEYSTORE_JKS}                                       ${BASE_PATH}/assets/truststores/external/keystore.jks
${KEYSTORE_JKS_PASS}                                  ${BASE_PATH}/assets/truststores/external/keystore.pass
${TRUSTSTORE_JKS}                                     ${BASE_PATH}/assets/truststores/truststore.jks
${TRUSTSTORE_JKS_PASS}                                ${BASE_PATH}/assets/truststores/truststoreJks.pass
${TRUSTSTORE_P12}                                     ${BASE_PATH}/assets/truststores/truststore.p12
${TRUSTSTORE_P12_PASS}                                ${BASE_PATH}/assets/truststores/truststore.pass
${TRUSTSTORE_PEM}                                     ${BASE_PATH}/assets/truststores/truststore.pem

${EXITCODE_SUCCESS}                                    0
${EXITCODE_CERTIFICATES_PATHS_VALIDATION_EXCEPTION}    1
${EXITCODE_CONFIGURATION_EXCEPTION}                    2
${EXITCODE_TRUSTSTORE_FILE_FACTORY_EXCEPTION}          3
${EXITCODE_PASSWORD_READER_EXCEPTION}                  4
${EXITCODE_CREATE_BACKUP_EXCEPTION}                    5
${EXITCODE_KEYSTORE_INSTANCE_EXCEPTION}                6
${EXITCODE_TRUSTSTORE_LOAD_FILE_EXCEPTION}             7
${EXITCODE_TRUSTSTORE_DATA_OPERATION_EXCEPTION}        8
${EXITCODE_MISSING_TRUSTSTORE_EXCEPTIONSUCCESS}        9
${EXITCODE_ALIAS_CONFLICT_EXCEPTION}                   10
${EXITCODE_WRITE_TRUSTSTORE_FILE_EXCEPTION}            11
${EXITCODE_KEYSTORE_FILE_COPY_EXCEPTION}               12
${EXITCODE_KEYSTORE_NOT_EXIST_EXCEPTION}               13
${EXITCODE_UNEXPECTED_EXCEPTION}                       99


