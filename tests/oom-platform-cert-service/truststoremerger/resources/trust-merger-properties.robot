*** Variables ***

${DOCKER_MERGER_IMAGE}                                onap-dev-local.esisoj70.emea.nsn-net.net/pmarcink/truststore_2:1.2.0
${MERGER_CONTAINER_NAME}                              %{MergerContainerName}
${MOUNT_PATH}                                         %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/tmp
${TRUSTSTORES_PATH}                                   %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/truststores
${EXPECTED_TRUSTSTORES_PATH}                          %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/expected_truststores

${JKS_TRUSTSTORE_MOUNT_PATH}                          %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/tmp/truststore.jks
${JKS_PASSWORD_MOUNT_PATH}                            %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/tmp/truststoreJks.pass
${P12_TRUSTSTORE_MOUNT_PATH}                          %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/tmp/truststore.p12
${P12_PASSWORD_MOUNT_PATH}                            %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/tmp/truststoreP12.pass
${PEM_TRUSTSTORE_MOUNT_PATH}                          %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/tmp/truststore.pem

${JKS_TRUSTSTORE_EXPECTED_PATH}                       %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/expected_truststores/jksAndPemAndP12.jks
${PEM_TRUSTSTORE_EXPECTED_PATH}                       %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/expected_truststores/pemAndP12.pem

${INVALID_ENV_EMPTY_FILE}                             %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_empty_file.env
${INVALID_ENV_LIST_SIZE}                              %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_different_lists_size.env
${INVALID_ENV_EMPTY_PASSWORDS}                        %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_empty_passwords.env
${INVALID_PASSWORD_PATHS}                             %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_password_path.env
${INVALID_ENV_TRUSTSTORE_PATHS}                       %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_truststore_paths.env
${INVALID_ENV_FILE_PASSWORD}                          %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_file_password_pair.env
${INVALID_ENV_EXTENSION}                              %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_extension.env
${INVALID_ENV_DUPLICATED_ALIASES}                     %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_duplicated_aliases.env
${INVALID_ENV_EMPTY_CERTS}                            %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/invalid_empty_certs.env
${VALID_ENV_JKS_PEM_P12}                              %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/valid_jks_pem_p12.env
${VALID_ENV_PEM_P12}                                  %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/valid_pem_p12.env
${VALID_ENV_SINGLE_TRUSTSTORE}                        %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/valid_single_truststore.env

${TRUSTSTORE_JKS}                                     %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/truststores/truststore.jks
${TRUSTSTORE_JKS_PASS}                                %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/truststores/truststoreJks.pass
${TRUSTSTORE_P12}                                     %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/truststores/truststore.p12
${TRUSTSTORE_P12_PASS}                                %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/truststores/truststore.pass
${TRUSTSTORE_PEM}                                     %{WORKSPACE}/tests/oom-platform-cert-service/truststoremerger/assets/truststores/truststore.pem
