*** Variables ***

${CERT_SERVICE_CONTAINER_NAME}           aaf-cert-service
${CERT_SERVICE_PORT}                     8443
${AAFCERT_URL}                           https://localhost:${cert_service_port}
${CLIENT_CA_NAME}                        Client
${RA_CA_NAME}                            RA
${CERT_SERVICE_ENDPOINT}                 /v1/certificate/
${ROOTCA}                                %{WORKSPACE}/tests/aaf/certservice/assets/certs/root.crt
${CERTSERVICE_SERVER_CRT}                %{WORKSPACE}/tests/aaf/certservice/assets/certs/certServiceServer.crt
${CERTSERVICE_SERVER_KEY}                %{WORKSPACE}/tests/aaf/certservice/assets/certs/certServiceServer.key
${VALID_CLIENT_CSR_FILE}                 %{WORKSPACE}/tests/aaf/certservice/assets/valid_client.csr
${VALID_CLIENT_PK_FILE}                  %{WORKSPACE}/tests/aaf/certservice/assets/valid_client.pk
${VALID_RA_CSR_FILE}                     %{WORKSPACE}/tests/aaf/certservice/assets/valid_ra.csr
${VALID_RA_PK_FILE}                      %{WORKSPACE}/tests/aaf/certservice/assets/valid_ra.pk
${INVALID_CSR_FILE}                      %{WORKSPACE}/tests/aaf/certservice/assets/invalid.csr
${INVALID_PK_FILE}                       %{WORKSPACE}/tests/aaf/certservice/assets/invalid.key


${CERT_SERVICE_ADDRESS}                  https://${CERT_SERVICE_CONTAINER_NAME}:${CERT_SERVICE_PORT}
${VALID_ENV_FILE}                        %{WORKSPACE}/tests/aaf/certservice/assets/valid_client_docker.env
${INVALID_ENV_FILE}                      %{WORKSPACE}/tests/aaf/certservice/assets/invalid_client_docker.env
${DOCKER_CLIENT_IMAGE}                   onap/org.onap.aaf.certservice.aaf-certservice-client:latest
${CLIENT_CONTAINER_NAME}                 %{ClientContainerName}
${CERT_SERVICE_NETWORK}                  certservice_certservice
${MOUNT_PATH}                            %{WORKSPACE}/tests/aaf/certservice/tmp
${TRUSTSTORE_PATH}                       %{WORKSPACE}/plans/aaf/certservice/certs
