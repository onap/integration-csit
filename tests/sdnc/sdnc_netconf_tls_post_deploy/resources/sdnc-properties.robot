*** Variables ***

${RA_CA_NAME}                            RA
${CERT_SERVICE_PORT}                     8080
${CERT_SERVICE_ENDPOINT}                 /v1/certificate/
${NEXUS_DOCKER_REPO}                     nexus3.onap.org:10001
${SDNC_CONTAINER_NAME}                   %{SDNC_CONTAINER_NAME}
${CLIENT_CONTAINER_NAME}                 %{CLIENT_CONTAINER_NAME}
${CERT_SERVICE_NETWORK}                  aaf-certservice_certservice
${SDNC_KEYSTORE_CONFIG_PATH}             /config/netconf-keystore:keystore
${NETCONF_PNP_SIM_CONTAINER_NAME}        %{NETCONF_PNP_SIM_CONTAINER_NAME}
${AAFCERT_URL}                           http://localhost:${cert_service_port}
${CERT_SERVICE_ADDRESS}                  http://%{AAFCERT_IP}:${cert_service_port}
${REQUEST_DATA_PATH}                     %{REQUEST_DATA_PATH}
${MOUNT_PATH}                            %{WORKSPACE}/tests/sdnc/sdnc_netconf_tls_post_deploy/cert-data
${SDNC_CSR_FILE}                         %{WORKSPACE}/tests/sdnc/sdnc_netconf_tls_post_deploy/csr/sdnc_csr.env
${NETCONF_PNP_SIM_CSR_FILE}              %{WORKSPACE}/tests/sdnc/sdnc_netconf_tls_post_deploy/csr/netconf_pnp_simulator_csr.env
${DOCKER_CLIENT_IMAGE}                   nexus3.onap.org:10001/onap/org.onap.aaf.certservice.aaf-certservice-client:latest
${CONF_SCRIPT}                           %{WORKSPACE}/tests/sdnc/sdnc_netconf_tls_post_deploy/libraries/config.sh
${SDNC_MOUNT_PATH}                       /config/network-topology:network-topology/topology/topology-netconf/node/PNFDemo
${PNFSIM_MOUNT_PATH}                     /config/network-topology:network-topology/topology/topology-netconf/node/PNFDemo/yang-ext:mount/mynetconf:netconflist