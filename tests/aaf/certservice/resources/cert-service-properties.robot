*** Variables ***

${CERT_SERVICE_PORT}                     8433
${AAFCERT_URL}                           http://localhost:${cert_service_port}
${CLIENT_CA_NAME}                        Client
${RA_CA_NAME}                            RA
${CERT_SERVICE_ENDPOINT}                 /v1/certificate/
${VALID_CLIENT_CSR_FILE}                 %{WORKSPACE}/tests/aaf/certservice/assets/valid_client.csr
${VALID_CLIENT_PK_FILE}                  %{WORKSPACE}/tests/aaf/certservice/assets/valid_client.pk
${VALID_RA_CSR_FILE}                     %{WORKSPACE}/tests/aaf/certservice/assets/valid_ra.csr
${VALID_RA_PK_FILE}                      %{WORKSPACE}/tests/aaf/certservice/assets/valid_ra.pk
${INVALID_CSR_FILE}                      %{WORKSPACE}/tests/aaf/certservice/assets/invalid.csr
${INVALID_PK_FILE}                       %{WORKSPACE}/tests/aaf/certservice/assets/invalid.key


${CERT_SERVICE_ADDRESS}                  http://%{AAFCERT_IP}:${cert_service_port}
${VALID_ENV_FILE}                        %{WORKSPACE}/tests/aaf/certservice/assets/valid_client_docker.env
${INVALID_ENV_FILE}                      %{WORKSPACE}/tests/aaf/certservice/assets/invalid_client_docker.env
${DOCKER_CLIENT_IMAGE}                   onap/org.onap.aaf.certservice.aaf-certservice-client:latest
${CLIENT_CONTAINER_NAME}                 %{ClientContainerName}
${CERT_SERVICE_NETWORK}                  certservice_certservice
${MOUNT_PATH}                            %{WORKSPACE}/tests/aaf/certservice/tmp
