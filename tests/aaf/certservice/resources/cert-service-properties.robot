*** Variables ***

${AAFCERT_URL}                           http://%{AAFCERT_IP}:8080
${CA_NAME}                                TEST
${CERT_SERVICE_ENDPOINT}                 /v1/certificate
${VALID_CSR_FILE}                        %{WORKSPACE}/tests/aaf/certservice/assets/valid.csr
${VALID_PK_FILE}                         %{WORKSPACE}/tests/aaf/certservice/assets/valid.key
${INVALID_CSR_FILE}                      %{WORKSPACE}/tests/aaf/certservice/assets/invalid.csr
${INVALID_PK_FILE}                       %{WORKSPACE}/tests/aaf/certservice/assets/invalid.key
