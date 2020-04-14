*** Variables ***

# AAF CertService
${NEXUS_DOCKER_REPO}                     nexus3.onap.org:10001

${RA_CA_NAME}                            RA
${CERT_SERVICE_PORT}                     8443
${CERT_SERVICE_CONTAINER_NAME}           aaf-cert-service
${CERT_SERVICE_NETWORK}                  aaf-certservice_certservice
${AAFCERT_URL}                           https://localhost:${cert_service_port}
${CERT_SERVICE_ENDPOINT}                 /v1/certificate/
${CERT_SERVICE_ADDRESS}                  https://${CERT_SERVICE_CONTAINER_NAME}:${cert_service_port}
${ROOTCA}                                %{WORKSPACE}/tests/sdnc/sdnc_netconf_tls_post_deploy/certs/root.crt
${CERTSERVICE_SERVER_CRT}                %{WORKSPACE}/tests/sdnc/sdnc_netconf_tls_post_deploy/certs/certServiceServer.crt
${CERTSERVICE_SERVER_KEY}                %{WORKSPACE}/tests/sdnc/sdnc_netconf_tls_post_deploy/certs/certServiceServer.key

#AAF CerService Client
${CLIENT_CONTAINER_NAME}                 %{CLIENT_CONTAINER_NAME}
${DOCKER_CLIENT_IMAGE}                   nexus3.onap.org:10001/onap/org.onap.aaf.certservice.aaf-certservice-client:latest
${TRUSTSTORE_PATH}                       %{WORKSPACE}/plans/sdnc/sdnc_netconf_tls_post_deploy/certs

# SDNC Configuration
${REQUEST_DATA_PATH}                     %{REQUEST_DATA_PATH}
${SDNC_CONTAINER_NAME}                   %{SDNC_CONTAINER_NAME}
${SDNC_RESTCONF_URL}                     http://localhost:8282/restconf
${SDNC_KEYSTORE_CONFIG_PATH}             /config/netconf-keystore:keystore
${MOUNT_PATH}                            %{WORKSPACE}/tests/sdnc/sdnc_netconf_tls_post_deploy/cert-data
${SDNC_CSR_FILE}                         %{WORKSPACE}/tests/sdnc/sdnc_netconf_tls_post_deploy/csr/sdnc_csr.env
${SDNC_MOUNT_PATH}                       /config/network-topology:network-topology/topology/topology-netconf/node/PNFDemo
${PNFSIM_MOUNT_PATH}                     /config/network-topology:network-topology/topology/topology-netconf/node/PNFDemo/yang-ext:mount/mynetconf:netconflist

# Netconf-Pnp-Simulator
${NETCONF_PNP_SIM_CONTAINER_NAME}        %{NETCONF_PNP_SIM_CONTAINER_NAME}
${NETCONF_PNP_SIM_CSR_FILE}              %{WORKSPACE}/tests/sdnc/sdnc_netconf_tls_post_deploy/csr/netconf_pnp_simulator_csr.env
${CONF_SCRIPT}                           %{WORKSPACE}/tests/sdnc/sdnc_netconf_tls_post_deploy/libraries/config.sh