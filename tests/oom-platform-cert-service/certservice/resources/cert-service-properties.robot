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
${VALID_KUR_CSR}                         ${ASSETS_DIR}/valid_kur.csr
${VALID_KUR_KEY}                         ${ASSETS_DIR}/valid_kur.key
${VALID_CR_CSR_CHANGED_SUBJECT}          ${ASSETS_DIR}/valid_cr_changed_subject.csr
${VALID_CR_KEY_CHANGED_SUBJECT}          ${ASSETS_DIR}/valid_cr_changed_subject.key
${VALID_CR_CSR_CHANGED_SANS}             ${ASSETS_DIR}/valid_cr_changed_sans.csr
${VALID_CR_KEY_CHANGED_SANS}             ${ASSETS_DIR}/valid_cr_changed_sans.key
${INVALID_OLD_CERT}                      ${ASSETS_DIR}/invalid_old_cert.pem
${EXPECTED_KUR_LOG}                      Preparing Key Update Request
${EXPECTED_CR_LOG}                       Preparing Certification Request

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
