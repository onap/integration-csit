*** Variables ***

${DOCKER_MERGER_IMAGE}                                nexus3.onap.org:10001/onap/org.onap.oom.platform.cert-service.oom-truststore-merger:latest
${MERGER_CONTAINER_NAME}                              %{MergerContainerName}
${MOUNT_PATH}                                         %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/tmp
${TRUSTSTORES_PATH}                                   %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/truststores
${EXPECTED_TRUSTSTORES_PATH}                          %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/expected_truststores

${JKS_TRUSTSTORE_MOUNT_PATH}                          %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/tmp/truststore.jks
${JKS_PASSWORD_MOUNT_PATH}                            %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/tmp/truststoreJks.pass
${P12_TRUSTSTORE_MOUNT_PATH}                          %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/tmp/truststore.p12
${P12_PASSWORD_MOUNT_PATH}                            %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/tmp/truststoreP12.pass
${PEM_TRUSTSTORE_MOUNT_PATH}                          %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/tmp/truststore.pem
${JKS_KEYSTORE_MOUNT_PATH}                            %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/tmp/external/keystore.jks

${JKS_TRUSTSTORE_EXPECTED_PATH}                       %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/expected_truststores/jksAndPemAndP12.jks
${PEM_TRUSTSTORE_EXPECTED_PATH}                       %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/expected_truststores/pemAndP12.pem
${JKSBAK_KEYSTORE_EXPECTED_PATH}                      %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/expected_keystores/keystore.jks.bak
${JKS_KEYSTORE_EXPECTED_PATH}                         %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/expected_keystores/keystore.jks

${ENV_NOK_FILE_LIST_EMPTY}                            %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_empty_file.env
${ENV_NOK_INVALID_FILE_LIST_SIZE}                     %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_different_lists_size.env
${ENV_NOK_EMPTY_PASSWORDS}                            %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_empty_passwords.env
${ENV_NOK_INVALID_PASSWORD_PATHS}                     %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_password_path.env
${ENV_NOK_INVALID_TRUSTSTORE_PATHS}                   %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_truststore_paths.env
${ENV_NOK_INVALID_PASSWORD}                           %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_file_password_pair.env
${ENV_NOK_INVALID_FILE_EXTENSION}                     %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_extension.env
${ENV_NOK_DUPLICATED_ALIASES}                         %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_duplicated_aliases.env
${ENV_NOK_EMPTY_CERTS}                                %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_empty_certs.env
${ENV_OK_JKS_PEM_P12}                                 %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/valid_jks_pem_p12.env
${ENV_OK_PEM_P12}                                     %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/valid_pem_p12.env
${ENV_OK_SINGLE_TRUSTSTORE}                           %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/valid_single_truststore.env
${ENV_NOK_INVALID_KEYSTORE_SOURCE_PATHS}              %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_keystore_source_paths.env
${ENV_NOK_EMPTY_KEYSTORE_DESTINATION_PATH}            %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_empty_keystore_destination_path.env
${ENV_OK_EXTRA_OPTIONAL_ENVS}                         %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/valid_envs_and_extra_optional.env

${KEYSTORE_JKS}                                       %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/truststores/external/keystore.jks
${KEYSTORE_JKS_PASS}                                  %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/truststores/external/keystore.pass
${TRUSTSTORE_JKS}                                     %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/truststores/truststore.jks
${TRUSTSTORE_JKS_PASS}                                %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/truststores/truststoreJks.pass
${TRUSTSTORE_P12}                                     %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/truststores/truststore.p12
${TRUSTSTORE_P12_PASS}                                %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/truststores/truststore.pass
${TRUSTSTORE_PEM}                                     %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/truststores/truststore.pem

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


