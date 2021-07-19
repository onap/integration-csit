*** Variables ***

${CERT_SERVICE_CONTAINER_NAME}           oom-cert-service
${CERT_SERVICE_PORT}                     8443
${OOMCERT_URL}                           https://localhost:${cert_service_port}
${CLIENT_CA_NAME}                        Client
${RA_CA_NAME}                            RA
${CERT_SERVICE_ENDPOINT}                 /v1/certificate/
${CERT_SERVICE_UPDATE_ENDPOINT}          /v1/certificate-update/
${ASSETS_DIR}                            %{WORKSPACE}/tests/oom-platform-cert-service/certservice/assets
${ROOTCA}                                ${ASSETS_DIR}/certs/root.crt
${CERTSERVICE_SERVER_CRT}                ${ASSETS_DIR}/certs/certServiceServer.crt
${CERTSERVICE_SERVER_KEY}                ${ASSETS_DIR}/certs/certServiceServer.key
${VALID_CLIENT_CSR_FILE}                 ${ASSETS_DIR}/valid_client.csr
${VALID_CLIENT_PK_FILE}                  ${ASSETS_DIR}/valid_client.pk
${VALID_RA_CSR_FILE}                     ${ASSETS_DIR}/valid_ra.csr
${VALID_RA_PK_FILE}                      ${ASSETS_DIR}/valid_ra.pk
${VALID_RA_ALL_SANS_CSR_FILE}            ${ASSETS_DIR}/valid_ra_all_sans.csr
${VALID_RA_ALL_SANS_PK_FILE}             ${ASSETS_DIR}/valid_ra_all_sans.pk
${INVALID_CSR_FILE}                      ${ASSETS_DIR}/invalid.csr
${INVALID_PK_FILE}                       ${ASSETS_DIR}/invalid.csr
${VALID_IR_CSR_FOR_UPDATE}               ${ASSETS_DIR}/valid_ir_for_update.csr
${VALID_IR_KEY_FOR_UPDATE}               ${ASSETS_DIR}/valid_ir_for_update.key
${INVALID_IR_KEY_FOR_UPDATE}             ${ASSETS_DIR}/invalid_ir_for_update.key
${VALID_KUR_CSR}                         ${ASSETS_DIR}/valid_kur.csr
${VALID_KUR_KEY}                         ${ASSETS_DIR}/valid_kur.key
${VALID_CR_CSR_CHANGED_SUBJECT}          ${ASSETS_DIR}/valid_cr_changed_subject.csr
${VALID_CR_KEY_CHANGED_SUBJECT}          ${ASSETS_DIR}/valid_cr_changed_subject.key
${VALID_CR_CSR_CHANGED_SANS}             ${ASSETS_DIR}/valid_cr_changed_sans.csr
${VALID_CR_KEY_CHANGED_SANS}             ${ASSETS_DIR}/valid_cr_changed_sans.key
${EXPECTED_KUR_LOG}                      Preparing Key Update Request
${EXPECTED_CR_LOG}                       Preparing Certification Request
${VALID_OLD_CERT_BASE64}                 LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUVpekNDQXZPZ0F3SUJBZ0lVR0VwMkdaNlk4bnpEQTlDS2w1blVSSTdDVU44d0RRWUpLb1pJaHZjTkFRRUwKQlFBd1lURWpNQ0VHQ2dtU0pvbVQ4aXhrQVFFTUUyTXRNR3BpWm5FNGNXRXhabTh3ZDJ0dGJua3hGVEFUQmdOVgpCQU1NREUxaGJtRm5aVzFsYm5SRFFURWpNQ0VHQTFVRUNnd2FSVXBDUTBFZ1EyOXVkR0ZwYm1WeUlGRjFhV05yCmMzUmhjblF3SGhjTk1qRXdOakk1TURZMU1ESTFXaGNOTWpNd05qSTVNRFkxTURJMFdqQjNNUkV3RHdZRFZRUUQKREFodmJtRndMbTl5WnpFWk1CY0dBMVVFQ3d3UVRHbHVkWGd0Um05MWJtUmhkR2x2YmpFTk1Bc0dBMVVFQ2d3RQpUMDVCVURFV01CUUdBMVVFQnd3TlUyRnVMVVp5WVc1amFYTmpiekVUTUJFR0ExVUVDQXdLUTJGc2FXWnZjbTVwCllURUxNQWtHQTFVRUJoTUNWVk13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLQW9JQkFRREIKenZieXJyRWlhb0JqOGttYTJRbUMrVkxtbXRXRld5QUpnU3JZQTRreHV5cmpRQ1c0SnlGR3ZtemJZb1VGRkxPRgpoZnExOFZqVHMwY2JUeXNYOGNGU2ZrVjJFS0dFUkJhWm5aUlFzbzZTSUpOR2EzeE1lNUZIalJFeTM0TnAwNElICmpTUTQyZUlCZ2NOaUlhZGE0amdFbklRUVlRSlNQUXRIa2ZPTUM2TyszUnBUL2VIdHZvNXVyUjE2TUZZMUs2c28KbldZaXRJNVRwRUtSb3phdjZ6cVUvb3RIZ241alJMcnlqMElaeTBpamxCZlNLVHhyRmZacjNLb01EdWRWRWZVTQp0c3FFUjNwb2MxZ0ZrcW1DUkszOEJQTmlZN3Y1S0FUUkIrZldOK1A3NW13NDNkcng5ckltcCtKdHBPVXNESzhyCklCZDhvNGFmTnZyL1dyeWdCQjhyQWdNQkFBR2pnYVF3Z2FFd0RBWURWUjBUQVFIL0JBSXdBREFmQmdOVkhTTUUKR0RBV2dCUjlNMXFVblFNMENwSFV6MzRGNXNWVVVjSUR0akFZQmdOVkhSRUVFVEFQZ2cxMFpYTjBMbTl1WVhBdQpiM0puTUNjR0ExVWRKUVFnTUI0R0NDc0dBUVVGQndNQ0JnZ3JCZ0VGQlFjREJBWUlLd1lCQlFVSEF3RXdIUVlEClZSME9CQllFRkFmcWNVNnhHaThqempsUnVLUUJ0cVJjWGkrdU1BNEdBMVVkRHdFQi93UUVBd0lGNERBTkJna3EKaGtpRzl3MEJBUXNGQUFPQ0FZRUFBZHc3N3E3c2hLdFM4bERHY0ovWThkRWpqTlNsUnRVMTRFTUM1OWttS2VmdApSaTdkMG9DUVh0ZFJDdXQzeW1pekxWcVFrbVg2U3JHc2hwV1VzTnpUZElUalE2SkIyS09haUlXSUY2ME5TbGVXCjB2TG0zNkVtWTFFcksrektlN3R2R1daaFROVnpCWHRucStBTWZKYzQxdTJ1ZWxreDBMTmN6c1g5YUNhakxIMXYKNHo0WHNVbm05cWlYcG5FbTYzMmVtdUp5ajZOdDBKV1Z1TlRKVFBSbnFWWmY2S0tSODN2OEp1VjBFZWZXZDVXVgpjRnNwTDBIM01LSlY3dWY3aGZsbG5JY1J0elhhNXBjdEJDYm9GU2hWa1JOYUFNUHBKZjBEQkxReG03ZEFXajVBCmhHMXJ3bVRtek02TnB3R0hXL0kxU0ZNbXRRaUYwUEFDejFVbjZuRFcvUmYxaUhFb0dmOFlCTFAzMzJMSlNEdWcKUktuMGNNM1FUY3lVRXpDWnhTd0tKMm5nQzllRzlDMmQzWWhCNlp4dGwrZ1VJYTNBd3dQYnFyN1lSOVFrRDJFbwpkNExxRUg5em55QmZpN2syWUN3UDZydGZTaTZDbHliWGU4ZUJjdU1FUzRUQVFmRks2RlZmNTh0R1FJeDA2STBPCjM0bmVtWndrTG9PQnpaa2VwYVF2Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
${INVALID_OLD_CERT_BASE64}               aW5jb3JyZWN0X29sZF9jZXJ0Cg==


${CERT_SERVICE_ADDRESS}                  https://${CERT_SERVICE_CONTAINER_NAME}:${CERT_SERVICE_PORT}
${VALID_ENV_FILE}                        ${ASSETS_DIR}/valid_client_docker.env
${VALID_ENV_FILE_JKS}                    ${ASSETS_DIR}/valid_client_docker_jks.env
${VALID_ENV_FILE_P12}                    ${ASSETS_DIR}/valid_client_docker_p12.env
${VALID_ENV_FILE_PEM}                    ${ASSETS_DIR}/valid_client_docker_pem.env
${VALID_ENV_FILE_ALL_SANS_TYPES}         ${ASSETS_DIR}/valid_client_docker_all_sans_types.env
${INVALID_ENV_FILE_OUTPUT_TYPE}          ${ASSETS_DIR}/invalid_client_docker_output_type.env
${INVALID_ENV_FILE}                      ${ASSETS_DIR}/invalid_client_docker.env
${DOCKER_CLIENT_IMAGE}                   nexus3.onap.org:10001/onap/org.onap.oom.platform.cert-service.oom-certservice-client:2.3.3
${CLIENT_CONTAINER_NAME}                 %{ClientContainerName}
${CERT_SERVICE_NETWORK}                  certservice_certservice
${MOUNT_PATH}                            %{WORKSPACE}/tests/oom-platform-cert-service/certservice/tmp
${TRUSTSTORE_PATH}                       %{WORKSPACE}/plans/oom-platform-cert-service/certservice/certs
