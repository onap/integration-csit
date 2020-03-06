*** Variables ***

${AAFCERT_URL}                           http://%{AAFCERT_IP}:8080
${CLIENT_CA_NAME}                        Client
${RA_CA_NAME}                            RA
${CERT_SERVICE_ENDPOINT}                 /v1/certificate
${VALID_CLIENT_CSR_FILE}                 %{WORKSPACE}/tests/aaf/certservice/assets/valid_client.csr
${VALID_CLIENT_PK_FILE}                  %{WORKSPACE}/tests/aaf/certservice/assets/valid_client.pk
${VALID_RA_CSR_FILE}                     %{WORKSPACE}/tests/aaf/certservice/assets/valid_ra.csr
${VALID_RA_PK_FILE}                      %{WORKSPACE}/tests/aaf/certservice/assets/valid_ra.pk
${INVALID_CSR_FILE}                      %{WORKSPACE}/tests/aaf/certservice/assets/invalid.csr
${INVALID_PK_FILE}                       %{WORKSPACE}/tests/aaf/certservice/assets/invalid.key
