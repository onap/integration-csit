*** Variables ***

${AAFCERT_URL}                           http://%{AAFCERT_IP}:8080
${CAName}                                TEST
${CERT_PATH}                             /v1/certificate/${CAName}
${VALID_CSR_FILE}                        %{WORKSPACE}/tests/aaf/certservice/assets/valid.csr
${VALID_PK_FILE}                         %{WORKSPACE}/tests/aaf/certservice/assets/valid.key
${INVALID_CSR_FILE}                      %{WORKSPACE}/tests/aaf/certservice/assets/invalid.csr
${INVALID_PK_FILE}                       %{WORKSPACE}/tests/aaf/certservice/assets/invalid.key


${CERT_ADDRESS}                          ${AAFCERT_URL}/v1/certificate/
${DOCKER_ENVIROMENT_PATH}                %{WORKSPACE}/tests/aaf/certservice/assets/client_docker.env
${DOCKER_CLIENT_IMAGE}                   nexus3.onap.org:10001/onap/org.onap.aaf.certservice.aaf-certservice-client:latest
${DOCKER_CONTAINER_NAME}                 CertServiceClient


