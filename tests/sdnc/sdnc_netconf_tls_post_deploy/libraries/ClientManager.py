# ============LICENSE_START=======================================================
#  Copyright (C) 2020 Nordix Foundation.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================

__author__ = "Ajay Deep Singh (ajay.deep.singh@est.tech)"
__copyright__ = "Copyright (C) 2020 Nordix Foundation"
__license__ = "Apache 2.0"

import logging
import os
import shutil
import subprocess

import docker
from OpenSSL import crypto
from docker.types import Mount

DEV_NULL = open(os.devnull, 'wb')
NETCONF_PNP_SIM_CONTAINER_NAME = 'netconf-simulator'
ARCHIVES_PATH = os.getenv("WORKSPACE") + "/archives/"


class ClientManager:

    def __init__(self, mount_path):
        self.mount_path = mount_path
        self.caCertPem = mount_path + '/ca.pem'
        self.serverKeyPem = mount_path + '/server_key.pem'
        self.serverCertPem = mount_path + '/server_cert.pem'
        self.keystoreJksPath = mount_path + '/keystore.jks'
        self.keystorePassPath = mount_path + '/keystore.pass'
        self.truststoreJksPath = mount_path + '/truststore.jks'
        self.truststorePassPath = mount_path + '/truststore.pass'

    def run_client_container(self, client_image, container_name, path_to_env, request_url, network):
        """
        Run a container in detach Mode. By default, it will wait for the container to finish
        and return its logs, similar to ``docker run  -d``.
        """
        self.create_mount_dir()
        client = docker.from_env()
        environment = self.read_env_list_from_file(path_to_env)
        environment.append("REQUEST_URL=" + request_url)
        container = client.containers.run(
            image=client_image,
            name=container_name,
            environment=environment,
            network=network,
            user='root',
            mounts=[Mount(target='/var/certs', source=self.mount_path, type='bind')],
            detach=True
        )
        exitcode = container.wait()
        return exitcode

    # Function to validate keystore.jks/truststore.jks can be opened with generated pass-phrase.
    def can_open_keystore_and_truststore_with_pass(self):
        can_open_keystore = self.can_open_jks_file_with_pass_file(self.keystorePassPath, self.keystoreJksPath)
        can_open_truststore = self.can_open_jks_file_with_pass_file(self.truststorePassPath, self.truststoreJksPath)
        return can_open_keystore & can_open_truststore

    def can_install_keystore_and_truststore_certs(self, cmd, container_name):
        """
        Method for Uploading Certificate in SDNC-Container.
        Creating/Uploading Server-key, Server-cert, Ca-cert PEM files in Netconf-Pnp-Simulator.
        """
        if container_name == NETCONF_PNP_SIM_CONTAINER_NAME:
            logging.info('Generating PEM files for %s from JKS files', container_name)
            self.create_pem(self.keystorePassPath, self.keystoreJksPath, self.truststorePassPath,
                            self.truststoreJksPath)
        logging.info("Initiate Configuration Push for : {0}".format(container_name))
        resp_code = self.execute_bash_config(cmd, container_name)
        if resp_code == 0:
            print("Execution Successful for: {0}".format(container_name))
            return True
        else:
            print("Execution Failed for: {0}".format(container_name))
            return False

    def create_pem(self, keystore_pass_file_path, keystore_jks_file_path, truststore_pass_file_path,
                   truststore_jks_file_path):
        # Create [server_key.pem, server_cert.pem, ca.pem] files for Netconf-Pnp-Simulation/TLS Configuration.
        try:
            keystore_p12 = self.get_pkcs12(keystore_pass_file_path, keystore_jks_file_path)
            truststore_p12 = self.get_pkcs12(truststore_pass_file_path, truststore_jks_file_path)
            with open(self.serverKeyPem, "wb+") as key_file:
                key_file.write(crypto.dump_privatekey(crypto.FILETYPE_PEM, keystore_p12.get_privatekey()))
            with open(self.serverCertPem, "wb+") as server_cert_file:
                server_cert_file.write(crypto.dump_certificate(crypto.FILETYPE_PEM, keystore_p12.get_certificate()))
            with open(self.caCertPem, "wb+") as ca_cert_file:
                ca_cert_file.write(
                    crypto.dump_certificate(crypto.FILETYPE_PEM, truststore_p12.get_ca_certificates()[0]))
            return True
        except IOError as err:
            print("I/O Error: {0}".format(err))
            return False
        except Exception as e:
            print("Unexpected Error: {0}".format(e))
            return False

    def can_open_jks_file_with_pass_file(self, pass_file_path, jks_file_path):
        try:
            if jks_file_path.split('/')[-1] == 'truststore.jks':
                self.get_pkcs12(pass_file_path, jks_file_path).get_ca_certificates()[0]
            else:
                self.get_pkcs12(pass_file_path, jks_file_path).get_certificate()
            return True
        except IOError as err:
            print("I/O Error PKCS12 Creation failed: {0}".format(err))
            return False
        except Exception as e:
            print("Unexpected Error PKCS12 Creation failed: {0}".format(e))
            return False

    def remove_client_container_and_save_logs(self, container_name, log_file_name):
        client = docker.from_env()
        container = client.containers.get(container_name)
        text_file = open(ARCHIVES_PATH + "client_container_" + log_file_name + ".log", "w")
        text_file.write(container.logs())
        text_file.close()
        container.remove()
        self.remove_mount_dir()

    def create_mount_dir(self):
        if not os.path.exists(self.mount_path):
            os.makedirs(self.mount_path)

    def remove_mount_dir(self):
        shutil.rmtree(self.mount_path)

    @staticmethod
    def get_pkcs12(pass_file_path, jks_file_path):
        # Load PKCS12 Object
        password = open(pass_file_path, 'rb').read()
        p12 = crypto.load_pkcs12(open(jks_file_path, 'rb').read(), password)
        return p12

    @staticmethod
    def execute_bash_config(cmd, container_name):
        # Run command with arguments. Wait for command to complete or timeout, return code attribute.
        try:
            res_code = subprocess.call(["%s %s" % (cmd, container_name)], shell=True, stdout=DEV_NULL,
                                       stderr=subprocess.STDOUT)
            logging.info('Response Code from Config.sh Execution: %s ', res_code)
            return res_code
        except subprocess.CalledProcessError as e:
            logging.error("CalledProcessError Certificate installation failed in SDNC-ODL Container: {0}".format(e))
            return 1  # Return Error Code

    @staticmethod
    def get_container_logs(container_name):
        client = docker.from_env()
        container = client.containers.get(container_name)
        logs = container.logs()
        return logs

    @staticmethod
    def read_env_list_from_file(path):
        f = open(path, "r")
        r_list = []
        for line in f:
            line = line.strip()
            if line[0] != "#":
                r_list.append(line)
        return r_list
