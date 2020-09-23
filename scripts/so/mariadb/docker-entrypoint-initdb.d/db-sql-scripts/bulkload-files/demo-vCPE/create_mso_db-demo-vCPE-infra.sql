SOURCE ../default/create_mso_db-default.sql

USE `mso_requests`;
DROP USER 'mso';
CREATE USER 'mso';
GRANT ALL on mso_requests.* to 'mso' identified by 'mso123' with GRANT OPTION;
FLUSH PRIVILEGES;

USE `mso_catalog`;
DROP USER 'catalog';
CREATE USER 'catalog';
GRANT ALL on mso_catalog.* to 'catalog' identified by 'catalog123' with GRANT OPTION;
FLUSH PRIVILEGES;

SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;

INSERT INTO `heat_environment` (`ARTIFACT_UUID`, `NAME`, `VERSION`, `DESCRIPTION`, `BODY`, `ARTIFACT_CHECKSUM`, `CREATION_TIMESTAMP`) VALUES ('EnvArtifact-UUID2','base_vcpe_infra.env','1.0','base_vcpe_infra ENV file','parameters:\n  vcpe_image_name: PUT THE IMAGE NAME HERE (Ubuntu 1604 SUGGESTED)\n  vcpe_flavor_name: PUT THE FLAVOR NAME HERE (MEDIUM FLAVOR SUGGESTED)\n  public_net_id: PUT THE PUBLIC NETWORK ID HERE\n  cpe_signal_net_id: zdfw1cpe01_private\n  cpe_signal_subnet_id: zdfw1cpe01_sub_private\n  cpe_public_net_id: zdfw1cpe01_public\n  cpe_public_subnet_id: zdfw1cpe01_sub_public\n  onap_private_net_id: PUT THE ONAP PRIVATE NETWORK NAME HERE\n  onap_private_subnet_id: PUT THE ONAP PRIVATE SUBNETWORK NAME HERE\n  onap_private_net_cidr: 10.0.0.0/16\n  cpe_signal_net_cidr: 10.4.0.0/24\n  cpe_public_net_cidr: 10.2.0.0/24\n  vdhcp_private_ip_0: 10.4.0.1\n  vdhcp_private_ip_1: 10.0.101.1\n  vaaa_private_ip_0: 10.4.0.4\n  vaaa_private_ip_1: 10.0.101.2\n  vdns_private_ip_0: 10.2.0.1\n  vdns_private_ip_1: 10.0.101.3\n  vweb_private_ip_0: 10.2.0.10\n  vweb_private_ip_1: 10.0.101.40\n  mr_ip_addr: 10.0.11.1\n  vaaa_name_0: zdcpe1cpe01aaa01\n  vdns_name_0: zdcpe1cpe01dns01\n  vdhcp_name_0: zdcpe1cpe01dhcp01\n  vweb_name_0: zdcpe1cpe01web01\n  vnf_id: vCPE_Infrastructure_demo_app\n  vf_module_id: vCPE_Intrastructure\n  dcae_collector_ip: 10.0.4.1\n  dcae_collector_port: 8081\n  repo_url_blob: https://nexus.onap.org/content/sites/raw\n  repo_url_artifacts: https://nexus.onap.org/content/groups/staging\n  demo_artifacts_version: 1.2.0\n  install_script_version: 1.2.0-SNAPSHOT\n  key_name: vaaa_key\n  pub_key: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDQXYJYYi3/OUZXUiCYWdtc7K0m5C0dJKVxPG0eI8EWZrEHYdfYe6WoTSDJCww+1qlBSpA5ac/Ba4Wn9vh+lR1vtUKkyIC/nrYb90ReUd385Glkgzrfh5HdR5y5S2cL/Frh86lAn9r6b3iWTJD8wBwXFyoe1S2nMTOIuG4RPNvfmyCTYVh8XTCCE8HPvh3xv2r4egawG1P4Q4UDwk+hDBXThY2KS8M5/8EMyxHV0ImpLbpYCTBA6KYDIRtqmgS6iKyy8v2D1aSY5mc9J0T5t9S2Gv+VZQNWQDDKNFnxqYaAo1uEoq/i1q63XC5AD3ckXb2VT6dp23BQMdDfbHyUWfJN\n  cloud_env: PUT THE CLOUD PROVIDED HERE (openstack or rackspace)\n','MANUAL RECORD','2018-04-28 13:04:07a');

INSERT INTO `heat_template` (`ARTIFACT_UUID`, `NAME`, `VERSION`, `DESCRIPTION`, `BODY`, `TIMEOUT_MINUTES`, `ARTIFACT_CHECKSUM`, `CREATION_TIMESTAMP`) VALUES ('Artifact-UUID2','base_vcpe_infra.yaml','1.0','Base VCPE INFRA Heat','heat_template_version: 2013-05-23\n\ndescription: Heat template to deploy vCPE Infrastructue emlements (vAAA, vDHCP, vDNS_DHCP, webServer)\n\nparameters:\n  vcpe_image_name:\n    type: string\n    label: Image name or ID\n    description: Image to be used for compute instance\n  vcpe_flavor_name:\n    type: string\n    label: Flavor\n    description: Type of instance (flavor) to be used\n  public_net_id:\n    type: string\n    label: Public network name or ID\n    description: Public network that enables remote connection to VNF\n  onap_private_net_id:\n    type: string\n    label: ONAP management network name or ID\n    description: Private network that connects ONAP components and the VNF\n  onap_private_subnet_id:\n    type: string\n    label: ONAP management sub-network name or ID\n    description: Private sub-network that connects ONAP components and the VNF\n  onap_private_net_cidr:\n    type: string\n    label: ONAP private network CIDR\n    description: The CIDR of the protected private network\n  cpe_signal_net_id:\n    type: string\n    label: vAAA private network name or ID\n    description: Private network that connects vAAA with vDNSs\n  cpe_signal_subnet_id:\n    type: string\n    label: CPE Signal subnet\n    description: CPE Signal subnet\n  cpe_signal_net_cidr:\n    type: string\n    label: vAAA private network CIDR\n    description: The CIDR of the vAAA private network\n  cpe_public_net_id:\n    type: string\n    label: vCPE Public network (emulates internet) name or ID\n    description: Private network that connects vGW to emulated internet\n  cpe_public_subnet_id:\n    type: string\n    label: CPE Public subnet\n    description: CPE Public subnet\n  cpe_public_net_cidr:\n    type: string\n    label: vCPE public network CIDR\n    description: The CIDR of the vCPE public\n  vaaa_private_ip_0:\n    type: string\n    label: vAAA private IP address towards the CPE_SIGNAL private network\n    description: Private IP address that is assigned to the vAAA to communicate with the vCPE components\n  vaaa_private_ip_1:\n    type: string\n    label: vAAA private IP address towards the ONAP management network\n    description: Private IP address that is assigned to the vAAA to communicate with ONAP components\n  vdns_private_ip_0:\n    type: string\n    label: vDNS private IP address towards the CPE_PUBLIC private network\n    description: Private IP address that is assigned to the vDNS to communicate with the vCPE components\n  vdns_private_ip_1:\n    type: string\n    label: vDNS private IP address towards the ONAP management network\n    description: Private IP address that is assigned to the vDNS to communicate with ONAP components\n  vdhcp_private_ip_0:\n    type: string\n    label: vDHCP  private IP address towards the CPE_SIGNAL private network\n    description: Private IP address that is assigned to the vDHCP to communicate with the vCPE components\n  vdhcp_private_ip_1:\n    type: string\n    label: vDNS private IP address towards the ONAP management network\n    description: Private IP address that is assigned to the vDHCP to communicate with ONAP components\n  vweb_private_ip_0:\n    type: string\n    label: vWEB private IP address towards the CPE_PUBLIC private network\n    description: Private IP address that is assigned to the vWEB to communicate with the vGWs \n  vweb_private_ip_1:\n    type: string\n    label: vWEB private IP address towards the ONAP management network\n    description: Private IP address that is assigned to the vWEB to communicate with ONAP components\n  vaaa_name_0:\n    type: string\n    label: vAAA name\n    description: Name of the vAAA\n  vdns_name_0:\n    type: string\n    label: vDNS name\n    description: Name of the vDNS\n  vdhcp_name_0:\n    type: string\n    label: vDHCP name\n    description: Name of the vDHCP\n  vweb_name_0:\n    type: string\n    label: vWEB name\n    description: Name of the vWEB \n  vnf_id:\n    type: string\n    label: VNF ID\n    description: The VNF ID is provided by ONAP\n  vf_module_id:\n    type: string\n    label: vFirewall module ID\n    description: The vAAA Module ID is provided by ONAP\n  dcae_collector_ip:\n    type: string\n    label: DCAE collector IP address\n    description: IP address of the DCAE collector\n  dcae_collector_port:\n    type: string\n    label: DCAE collector port\n    description: Port of the DCAE collector\n  mr_ip_addr:\n    type: string\n    label: Message Router IP address\n    description: IP address of the Message Router that for vDHCP configuration \n  key_name:\n    type: string\n    label: Key pair name\n    description: Public/Private key pair name\n  pub_key:\n    type: string\n    label: Public key\n    description: Public key to be installed on the compute instance\n  repo_url_blob:\n    type: string\n    label: Repository URL\n    description: URL of the repository that hosts the demo packages\n  repo_url_artifacts:\n    type: string\n    label: Repository URL\n    description: URL of the repository that hosts the demo packages\n  install_script_version:\n    type: string\n    label: Installation script version number\n    description: Version number of the scripts that install the vFW demo app\n  demo_artifacts_version:\n    type: string\n    label: Artifacts version used in demo vnfs\n    description: Artifacts (jar, tar.gz) version used in demo vnfs\n  cloud_env:\n    type: string\n    label: Cloud environment\n    description: Cloud environment (e.g., openstack, rackspace)\n\nresources:\n\n  random-str:\n    type: OS::Heat::RandomString\n    properties:\n      length: 4\n\n  my_keypair:\n    type: OS::Nova::KeyPair\n    properties:\n      name:\n        str_replace:\n          template: base_rand\n          params:\n            base: { get_param: key_name }\n            rand: { get_resource: random-str }\n      public_key: { get_param: pub_key }\n      save_private_key: false\n\n\n  vaaa_private_0_port:\n    type: OS::Neutron::Port\n    properties:\n      network: { get_param: cpe_signal_net_id }\n      fixed_ips: [{"subnet": { get_param: cpe_signal_subnet_id }, "ip_address": { get_param: vaaa_private_ip_0 }}]\n\n  vaaa_private_1_port:\n    type: OS::Neutron::Port\n    properties:\n      network: { get_param: onap_private_net_id }\n      fixed_ips: [{"subnet": { get_param: onap_private_subnet_id }, "ip_address": { get_param: vaaa_private_ip_1 }}]\n\n  vaaa_0:\n    type: OS::Nova::Server\n    properties:\n      image: { get_param: vcpe_image_name }\n      flavor: { get_param: vcpe_flavor_name }\n      name: { get_param: vaaa_name_0 }\n      key_name: { get_resource: my_keypair }\n      networks:\n        - network: { get_param: public_net_id }\n        - port: { get_resource: vaaa_private_0_port }\n        - port: { get_resource: vaaa_private_1_port }\n      metadata: {vnf_id: { get_param: vnf_id }, vf_module_id: { get_param: vf_module_id }}\n      user_data_format: RAW\n      user_data:\n        str_replace:\n          params:\n            __dcae_collector_ip__: { get_param: dcae_collector_ip }\n            __dcae_collector_port__: { get_param: dcae_collector_port }\n            __cpe_signal_net_ipaddr__: { get_param: vaaa_private_ip_0 }\n            __oam_ipaddr__: { get_param: vaaa_private_ip_1 }\n            __oam_cidr__: { get_param: onap_private_net_cidr }\n            __cpe_signal_net_cidr__: { get_param: cpe_signal_net_cidr }\n            __repo_url_blob__ : { get_param: repo_url_blob }\n            __repo_url_artifacts__ : { get_param: repo_url_artifacts }\n            __demo_artifacts_version__ : { get_param: demo_artifacts_version }\n            __install_script_version__ : { get_param: install_script_version }\n            __cloud_env__ : { get_param: cloud_env }\n          template: |\n            #!/bin/bash\n\n            mkdir /opt/config\n            echo "__dcae_collector_ip__" > /opt/config/dcae_collector_ip.txt\n            echo "__dcae_collector_port__" > /opt/config/dcae_collector_port.txt\n            echo "__cpe_signal_net_ipaddr__" > /opt/config/cpe_signal_net_ipaddr.txt\n            echo "__oam_ipaddr__" > /opt/config/oam_ipaddr.txt\n            echo "__oam_cidr__" > /opt/config/oam_cidr.txt\n            echo "__cpe_signal_net_cidr__" > /opt/config/cpe_signal_net_cidr.txt\n            echo "__repo_url_blob__" > /opt/config/repo_url_blob.txt\n            echo "__repo_url_artifacts__" > /opt/config/repo_url_artifacts.txt\n            echo "__demo_artifacts_version__" > /opt/config/demo_artifacts_version.txt\n            echo "__install_script_version__" > /opt/config/install_script_version.txt\n            echo "__cloud_env__" > /opt/config/cloud_env.txt\n\n            curl -k __repo_url_blob__/org.onap.demo/vnfs/vcpe/__install_script_version__/v_aaa_install.sh -o /opt/v_aaa_install.sh\n            cd /opt\n            chmod +x v_aaa_install.sh\n            ./v_aaa_install.sh\n\n\n  vdns_private_0_port:\n    type: OS::Neutron::Port\n    properties:\n      network: { get_param: cpe_public_net_id }\n      fixed_ips: [{"subnet": { get_param: cpe_public_subnet_id }, "ip_address": { get_param: vdns_private_ip_0 }}]\n\n  vdns_private_1_port:\n    type: OS::Neutron::Port\n    properties:\n      network: { get_param: onap_private_net_id }\n      fixed_ips: [{"subnet": { get_param: onap_private_subnet_id }, "ip_address": { get_param: vdns_private_ip_1 }}]\n\n  vdns_0:\n    type: OS::Nova::Server\n    properties:\n      image: { get_param: vcpe_image_name }\n      flavor: { get_param: vcpe_flavor_name }\n      name: { get_param: vdns_name_0 }\n      key_name: { get_resource: my_keypair }\n      networks:\n        - network: { get_param: public_net_id }\n        - port: { get_resource: vdns_private_0_port }\n        - port: { get_resource: vdns_private_1_port }\n      metadata: {vnf_id: { get_param: vnf_id }, vf_module_id: { get_param: vf_module_id }}\n      user_data_format: RAW\n      user_data:\n        str_replace:\n          params:\n            __oam_ipaddr__ : { get_param: vdns_private_ip_1 }\n            __cpe_public_net_ipaddr__: { get_param: vdns_private_ip_0 }\n            __oam_cidr__: { get_param: onap_private_net_cidr }\n            __cpe_public_net_cidr__: { get_param: cpe_public_net_cidr }\n            __repo_url_blob__ : { get_param: repo_url_blob }\n            __repo_url_artifacts__ : { get_param: repo_url_artifacts }\n            __demo_artifacts_version__ : { get_param: demo_artifacts_version }\n            __install_script_version__ : { get_param: install_script_version }\n            __cloud_env__ : { get_param: cloud_env }\n          template: |\n            #!/bin/bash\n\n            mkdir /opt/config\n            echo "__oam_ipaddr__" > /opt/config/oam_ipaddr.txt\n            echo "__cpe_public_net_ipaddr__" > /opt/config/cpe_public_net_ipaddr.txt\n            echo "__oam_cidr__" > /opt/config/oam_cidr.txt\n            echo "__cpe_public_net_cidr__" > /opt/config/cpe_public_net_cidr.txt\n            echo "__repo_url_blob__" > /opt/config/repo_url_blob.txt\n            echo "__repo_url_artifacts__" > /opt/config/repo_url_artifacts.txt\n            echo "__demo_artifacts_version__" > /opt/config/demo_artifacts_version.txt\n            echo "__install_script_version__" > /opt/config/install_script_version.txt\n            echo "__cloud_env__" > /opt/config/cloud_env.txt\n\n            curl -k __repo_url_blob__/org.onap.demo/vnfs/vcpe/__install_script_version__/v_dns_install.sh -o /opt/v_dns_install.sh\n            cd /opt\n            chmod +x v_dns_install.sh\n            ./v_dns_install.sh\n\n\n  vdhcp_private_0_port:\n    type: OS::Neutron::Port\n    properties:\n      network: { get_param: cpe_signal_net_id }\n      fixed_ips: [{"subnet": { get_param: cpe_signal_subnet_id }, "ip_address": { get_param: vdhcp_private_ip_0 }}]\n\n  vdhcp_private_1_port:\n    type: OS::Neutron::Port\n    properties:\n      network: { get_param: onap_private_net_id }\n      fixed_ips: [{"subnet": { get_param: onap_private_subnet_id }, "ip_address": { get_param: vdhcp_private_ip_1 }}]\n\n  vdhcp_0:\n    type: OS::Nova::Server\n    properties:\n      image: { get_param: vcpe_image_name }\n      flavor: { get_param: vcpe_flavor_name }\n      name: { get_param: vdhcp_name_0 }\n      key_name: { get_resource: my_keypair }\n      networks:\n        - network: { get_param: public_net_id }\n        - port: { get_resource: vdhcp_private_0_port }\n        - port: { get_resource: vdhcp_private_1_port }\n      metadata: {vnf_id: { get_param: vnf_id }, vf_module_id: { get_param: vf_module_id }}\n      user_data_format: RAW\n      user_data:\n        str_replace:\n          params:\n            __oam_ipaddr__ : { get_param: vdhcp_private_ip_1 }\n            __cpe_signal_ipaddr__ : { get_param: vdhcp_private_ip_0 }\n            __oam_cidr__ : { get_param: onap_private_net_cidr }\n            __cpe_signal_net_cidr__ : { get_param: cpe_signal_net_cidr }\n            __mr_ip_addr__ : { get_param: mr_ip_addr }\n            __repo_url_blob__ : { get_param: repo_url_blob }\n            __repo_url_artifacts__ : { get_param: repo_url_artifacts }\n            __demo_artifacts_version__ : { get_param: demo_artifacts_version }\n            __install_script_version__ : { get_param: install_script_version }\n            __cloud_env__ : { get_param: cloud_env }\n          template: |\n            #!/bin/bash\n\n            mkdir /opt/config\n            echo "__oam_ipaddr__" > /opt/config/oam_ipaddr.txt\n            echo "__cpe_signal_ipaddr__" > /opt/config/cpe_signal_ipaddr.txt\n            echo "__oam_cidr__" > /opt/config/oam_cidr.txt\n            echo "__cpe_signal_net_cidr__" > /opt/config/cpe_signal_net_cidr.txt\n            echo "__mr_ip_addr__" > /opt/config/mr_ip_addr.txt\n            echo "__repo_url_blob__" > /opt/config/repo_url_blob.txt\n            echo "__repo_url_artifacts__" > /opt/config/repo_url_artifacts.txt\n            echo "__demo_artifacts_version__" > /opt/config/demo_artifacts_version.txt\n            echo "__install_script_version__" > /opt/config/install_script_version.txt\n            echo "__cloud_env__" > /opt/config/cloud_env.txt\n\n            curl -k __repo_url_blob__/org.onap.demo/vnfs/vcpe/__install_script_version__/v_dhcp_install.sh -o /opt/v_dhcp_install.sh\n            cd /opt\n            chmod +x v_dhcp_install.sh\n            ./v_dhcp_install.sh\n\n  vweb_private_0_port:\n    type: OS::Neutron::Port\n    properties:\n      network: { get_param: cpe_public_net_id }\n      fixed_ips: [{"subnet": { get_param: cpe_public_subnet_id }, "ip_address": { get_param: vweb_private_ip_0 }}]\n\n  vweb_private_1_port:\n    type: OS::Neutron::Port\n    properties:\n      network: { get_param: onap_private_net_id }\n      fixed_ips: [{"subnet": { get_param: onap_private_subnet_id }, "ip_address": { get_param: vweb_private_ip_1 }}]\n\n\n  vweb_0:\n    type: OS::Nova::Server\n    properties:\n      image: { get_param: vcpe_image_name }\n      flavor: { get_param: vcpe_flavor_name }\n      name: { get_param: vweb_name_0 }\n      key_name: { get_resource: my_keypair }\n      networks:\n        - network: { get_param: public_net_id }\n        - port: { get_resource: vweb_private_0_port }\n        - port: { get_resource: vweb_private_1_port }\n      metadata: {vnf_id: { get_param: vnf_id }, vf_module_id: { get_param: vf_module_id }}\n      user_data_format: RAW\n      user_data:\n        str_replace:\n          params:\n            __oam_ipaddr__ : { get_param: vweb_private_ip_1 }\n            __cpe_public_ipaddr__: { get_param: vweb_private_ip_0 }\n            __oam_cidr__: { get_param: onap_private_net_cidr }\n            __cpe_public_net_cidr__: { get_param: cpe_public_net_cidr }\n            __repo_url_blob__ : { get_param: repo_url_blob }\n            __repo_url_artifacts__ : { get_param: repo_url_artifacts }\n            __demo_artifacts_version__ : { get_param: demo_artifacts_version }\n            __install_script_version__ : { get_param: install_script_version }\n            __cloud_env__ : { get_param: cloud_env }\n          template: |\n            #!/bin/bash\n\n            mkdir /opt/config\n            echo "__oam_ipaddr__" > /opt/config/oam_ipaddr.txt\n            echo "__cpe_public_ipaddr__" > /opt/config/cpe_public_ipaddr.txt\n            echo "__oam_cidr__" > /opt/config/oam_cidr.txt\n            echo "__cpe_public_net_cidr__" > /opt/config/cpe_public_net_cidr.txt\n            echo "__repo_url_blob__" > /opt/config/repo_url_blob.txt\n            echo "__repo_url_artifacts__" > /opt/config/repo_url_artifacts.txt\n            echo "__demo_artifacts_version__" > /opt/config/demo_artifacts_version.txt\n            echo "__install_script_version__" > /opt/config/install_script_version.txt\n            echo "__cloud_env__" > /opt/config/cloud_env.txt\n\n            curl -k __repo_url_blob__/org.onap.demo/vnfs/vcpe/__install_script_version__/v_web_install.sh -o /opt/v_web_install.sh\n            cd /opt\n            chmod +x v_web_install.sh\n            ./v_web_install.sh\n',300,'MANUAL RECORD','2018-04-28 13:04:07');

INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','cloud_env','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','pub_key','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','key_name','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','install_script_version','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','demo_artifacts_version','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','repo_url_artifacts','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','repo_url_blob','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','dcae_collector_port','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','dcae_collector_ip','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','vf_module_id','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','vnf_id','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','vweb_name_0','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','vdhcp_name_0','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','vdns_name_0','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','vaaa_name_0','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','mr_ip_addr','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','vweb_private_ip_1','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','vweb_private_ip_0','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','vdns_private_ip_1','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','vdns_private_ip_0','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','vaaa_private_ip_1','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','vaaa_private_ip_0','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','vdhcp_private_ip_1','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','vdhcp_private_ip_0','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','cpe_public_net_cidr','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','cpe_signal_net_cidr','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','onap_private_net_cidr','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','onap_private_subnet_id','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','onap_private_net_id','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','cpe_public_subnet_id','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','cpe_public_net_id','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','cpe_signal_subnet_id','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','cpe_signal_net_id','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','public_net_id','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','vcpe_flavor_name','','string',NULL);
INSERT INTO `heat_template_params` (`HEAT_TEMPLATE_ARTIFACT_UUID`, `PARAM_NAME`, `IS_REQUIRED`, `PARAM_TYPE`, `PARAM_ALIAS`) VALUES ('Artifact-UUID2','vcpe_image_name','','string',NULL);

INSERT INTO `service` (`MODEL_UUID`, `MODEL_NAME`, `MODEL_INVARIANT_UUID`, `MODEL_VERSION`, `DESCRIPTION`, `CREATION_TIMESTAMP`, `TOSCA_CSAR_ARTIFACT_UUID`) VALUES ('2e34774e-715e-4fd5-bd09-7b654622f35i','infra-service','585822c7-4027-4f84-ba50-e9248606f112','1.0','INFRA service','2018-04-28 13:04:07',NULL);

INSERT INTO `vf_module` (`MODEL_UUID`, `MODEL_INVARIANT_UUID`, `MODEL_VERSION`, `MODEL_NAME`, `DESCRIPTION`, `IS_BASE`, `HEAT_TEMPLATE_ARTIFACT_UUID`, `VOL_HEAT_TEMPLATE_ARTIFACT_UUID`, `CREATION_TIMESTAMP`, `VNF_RESOURCE_MODEL_UUID`) VALUES ('1e34774e-715e-4fd5-bd08-7b654622f33f.VF_RI1_VFW::module-1::module-1.group','585822c7-4027-4f84-ba50-e9248606f134','1.0','VF_RI1_VFW::module-1',NULL,1,'Artifact-UUID2',NULL,'2018-04-28 13:04:07','685822c7-4027-4f84-ba50-e9248606f132');

INSERT INTO `vf_module_customization` (`MODEL_CUSTOMIZATION_UUID`, `LABEL`, `INITIAL_COUNT`, `MIN_INSTANCES`, `MAX_INSTANCES`, `AVAILABILITY_ZONE_COUNT`, `HEAT_ENVIRONMENT_ARTIFACT_UUID`, `VOL_ENVIRONMENT_ARTIFACT_UUID`, `CREATION_TIMESTAMP`, `VF_MODULE_MODEL_UUID`) VALUES ('5aa23938-a9fe-11e7-8b4b-0242ac120002',NULL,1,0,NULL,NULL,'EnvArtifact-UUID2',NULL,'2018-04-28 18:52:03','1e34774e-715e-4fd5-bd08-7b654622f33f.VF_RI1_VFW::module-1::module-1.group');

INSERT INTO `vnf_res_custom_to_vf_module_custom` (`VNF_RESOURCE_CUST_MODEL_CUSTOMIZATION_UUID`, `VF_MODULE_CUST_MODEL_CUSTOMIZATION_UUID`, `CREATION_TIMESTAMP`) VALUES ('5a9bd247-a9fe-11e7-8b4b-0242ac120002','5aa23938-a9fe-11e7-8b4b-0242ac120002','2018-04-28 18:52:03');

INSERT INTO `vnf_resource` (`ORCHESTRATION_MODE`, `DESCRIPTION`, `CREATION_TIMESTAMP`, `MODEL_UUID`, `AIC_VERSION_MIN`, `AIC_VERSION_MAX`, `MODEL_INVARIANT_UUID`, `MODEL_VERSION`, `MODEL_NAME`, `TOSCA_NODE_TYPE`, `HEAT_TEMPLATE_ARTIFACT_UUID`) VALUES ('HEAT','INFRA service1707MIGRATED','2018-04-28 13:04:07','685822c7-4027-4f84-ba50-e9248606f132',NULL,NULL,'585822c7-4027-4f84-ba50-e9248606f113','1.0','INFRAResource',NULL,NULL);

INSERT INTO `vnf_resource_customization` (`MODEL_CUSTOMIZATION_UUID`, `MODEL_INSTANCE_NAME`, `MIN_INSTANCES`, `MAX_INSTANCES`, `AVAILABILITY_ZONE_MAX_COUNT`, `NF_TYPE`, `NF_ROLE`, `NF_FUNCTION`, `NF_NAMING_CODE`, `CREATION_TIMESTAMP`, `VNF_RESOURCE_MODEL_UUID`) VALUES ('5a9bd247-a9fe-11e7-8b4b-0242ac120002','VFWResource-1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2018-04-28 18:52:03','685822c7-4027-4f84-ba50-e9248606f132');

SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;