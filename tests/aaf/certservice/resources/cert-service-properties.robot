*** Variables ***

${AAFCERT_URL}                           http://%{AAFCERT_IP}:8080
${CAName}                                TEST
${CERT_PATH}                             /v1/certificate/${CAName}
${VALID_CSR_FILE}                        %{WORKSPACE}/tests/aaf/certservice/assets/valid.csr
${VALID_PK_FILE}                         %{WORKSPACE}/tests/aaf/certservice/assets/valid.key
${INVALID_CSR_FILE}                      %{WORKSPACE}/tests/aaf/certservice/assets/invalid.csr
${INVALID_PK_FILE}                       %{WORKSPACE}/tests/aaf/certservice/assets/invalid.key
