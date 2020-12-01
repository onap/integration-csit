*** Variables ***

${CERT_SERVICE_CONTAINER_NAME}           oom-cert-service
${CERT_SERVICE_PORT}                     8443
${OOMCERT_URL}                           https://localhost:${cert_service_port}
${CLIENT_CA_NAME}                        Client
${RA_CA_NAME}                            RA
${CERT_SERVICE_ENDPOINT}                 /v1/certificate/
${ROOTCA}                                %{WORKSPACE}/tests/oom-platform-cert-service/certservice/assets/certs/root.crt
${CERTSERVICE_SERVER_CRT}                %{WORKSPACE}/tests/oom-platform-cert-service/certservice/assets/certs/certServiceServer.crt
${CERTSERVICE_SERVER_KEY}                %{WORKSPACE}/tests/oom-platform-cert-service/certservice/assets/certs/certServiceServer.key
${VALID_CLIENT_CSR_FILE}                 %{WORKSPACE}/tests/oom-platform-cert-service/certservice/assets/valid_client.csr
${VALID_CLIENT_PK_FILE}                  %{WORKSPACE}/tests/oom-platform-cert-service/certservice/assets/valid_client.pk
${VALID_RA_CSR_FILE}                     %{WORKSPACE}/tests/oom-platform-cert-service/certservice/assets/valid_ra.csr
${VALID_RA_PK_FILE}                      %{WORKSPACE}/tests/oom-platform-cert-service/certservice/assets/valid_ra.pk
${INVALID_CSR_FILE}                      %{WORKSPACE}/tests/oom-platform-cert-service/certservice/assets/invalid.csr
${INVALID_PK_FILE}                       %{WORKSPACE}/tests/oom-platform-cert-service/certservice/assets/invalid.key


${CERT_SERVICE_ADDRESS}                  https://${CERT_SERVICE_CONTAINER_NAME}:${CERT_SERVICE_PORT}
${VALID_ENV_FILE}                        %{WORKSPACE}/tests/oom-platform-cert-service/certservice/assets/valid_client_docker.env
${VALID_ENV_FILE_JKS}                    %{WORKSPACE}/tests/oom-platform-cert-service/certservice/assets/valid_client_docker_jks.env
${VALID_ENV_FILE_P12}                    %{WORKSPACE}/tests/oom-platform-cert-service/certservice/assets/valid_client_docker_p12.env
${VALID_ENV_FILE_PEM}                    %{WORKSPACE}/tests/oom-platform-cert-service/certservice/assets/valid_client_docker_pem.env
${INVALID_ENV_FILE_OUTPUT_TYPE}          %{WORKSPACE}/tests/oom-platform-cert-service/certservice/assets/invalid_client_docker_output_type.env
${INVALID_ENV_FILE}                      %{WORKSPACE}/tests/oom-platform-cert-service/certservice/assets/invalid_client_docker.env
${DOCKER_CLIENT_IMAGE}                   nexus3.onap.org:10001/onap/org.onap.oom.platform.cert-service.oom-certservice-client:guilin-latest
${CLIENT_CONTAINER_NAME}                 %{ClientContainerName}
${CERT_SERVICE_NETWORK}                  certservice_certservice
${MOUNT_PATH}                            %{WORKSPACE}/tests/oom-platform-cert-service/certservice/tmp
${TRUSTSTORE_PATH}                       %{WORKSPACE}/plans/oom-platform-cert-service/certservice/certs
