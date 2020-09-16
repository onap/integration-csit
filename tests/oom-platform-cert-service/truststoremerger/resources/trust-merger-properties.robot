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
${JKSBAK_KEYSTORE_EXPECTED_PATH}                      %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/expected_keystore/keystore.jks.bak

${INVALID_ENV_FILE_EMPTY}                             %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_empty_file.env
${INVALID_ENV_FILE_LIST_SIZE}                         %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_different_lists_size.env
${INVALID_ENV_FILE_EMPTY_PASSWORDS}                   %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_empty_passwords.env
${INVALID_ENV_FILE_PASSWORD_PATHS}                    %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_password_path.env
${INVALID_ENV_FILE_TRUSTSTORE_PATHS}                  %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_truststore_paths.env
${INVALID_ENV_FILE_PASSWORD}                          %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_file_password_pair.env
${INVALID_ENV_FILE_EXTENSION}                         %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_extension.env
${INVALID_ENV_FILE_DUPLICATED_ALIASES}                %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_duplicated_aliases.env
${INVALID_ENV_FILE_EMPTY_CERTS}                       %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_empty_certs.env
${VALID_ENV_FILE_JKS_PEM_P12}                         %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/valid_jks_pem_p12.env
${VALID_ENV_FILE_PEM_P12}                             %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/valid_pem_p12.env
${VALID_ENV_FILE_SINGLE_TRUSTSTORE}                   %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/valid_single_truststore.env
${INVALID_KEYSTORE_SOURCE_PATHS}                      %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_keystore_source_paths.env
${INVALID_EMPTY_KEYSTORE_DESTINATION_PATH}            %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_empty_keystore_destination_path.env
${VALID_ENVS_AND_EXTRA_OPTIONAL_ENVS}                 %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/valid_envs_with_extra_optional.env

${TRUSTSTORE_JKS}                                     %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/truststores/truststore.jks
${TRUSTSTORE_JKS_PASS}                                %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/truststores/truststoreJks.pass
${TRUSTSTORE_P12}                                     %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/truststores/truststore.p12
${TRUSTSTORE_P12_PASS}                                %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/truststores/truststore.pass
${TRUSTSTORE_PEM}                                     %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/truststores/truststore.pem
