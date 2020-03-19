import docker
import os
import shutil
import re
from OpenSSL import crypto
from cryptography.x509.oid import ExtensionOID
from cryptography import x509
from docker.types import Mount

ARCHIVES_PATH = os.getenv("WORKSPACE") + "/archives/"
MOUNT_PATH = os.getenv("WORKSPACE") + "/tests/aaf/certservice/tmp"

KEYSTORE_PASS_PATH = MOUNT_PATH + '/keystore.pass'
KEYSTORE_JKS_PATH = MOUNT_PATH + '/keystore.jks'
TRUSTSTORE_PASS_PATH = MOUNT_PATH + '/truststore.pass'
TRUSTSTORE_JKS_PATH = MOUNT_PATH + '/truststore.jks'

ERROR_API_REGEX = 'Error on API response.*[0-9]{3}'
RESPONSE_CODE_REGEX = '[0-9]{3}'


class CertClientManager:

    def run_client_container(self, client_image, container_name, path_to_env, request_url, network):
        self.create_mount_dir()
        client = docker.from_env()
        environment = self.read_list_env_from_file(path_to_env)
        environment.append("REQUEST_URL=" + request_url)
        container = client.containers.run(
            image=client_image,
            name=container_name,
            environment=environment,
            network=network,
            user='root', #Run container as root to avoid permission issues with volume mount access
            mounts=[Mount(target='/var/certs', source=MOUNT_PATH, type='bind')],
            detach=True
        )
        exitcode = container.wait()
        return exitcode

    def read_list_env_from_file(self, path):
        f = open(path, "r")
        r_list = []
        for line in f:
            line = line.strip()
            if line[0] != "#":
                r_list.append(line)
        return r_list

    def remove_nones_from_dict(self, dictionary):
        return dict((k, v) for k, v in dictionary.iteritems() if k is not None)

    def get_mappings(self):
        return {'COMMON_NAME':'CN', 'ORGANIZATION':'O', 'ORGANIZATION_UNIT':'OU', 'LOCATION':'L', 'STATE':'ST', 'COUNTRY':'C', 'SANS':'SANS'}

    def get_list_of_pairs_by_mappings(self, list):
        mappings = self.get_mappings()
        listOfEnvs = map(lambda k: k.split('='), list)
        return dict((mappings.get(a[0]), a[1]) for a in listOfEnvs)

    def get_envs_as_dict(self, list):
        envs = self.get_list_of_pairs_by_mappings(list)
        return self.remove_nones_from_dict(envs)

    def remove_client_container_and_save_logs(self, container_name, log_file_name):
        client = docker.from_env()
        container = client.containers.get(container_name)
        text_file = open(ARCHIVES_PATH + "container_" + log_file_name + ".log", "w")
        text_file.write(container.logs())
        text_file.close()
        container.remove()
        self.remove_mount_dir()

    def can_open_keystore_and_truststore_with_pass(self):
        can_open_keystore = self.can_open_jks_file_by_pass_file(KEYSTORE_PASS_PATH, KEYSTORE_JKS_PATH)
        can_open_truststore = self.can_open_jks_file_by_pass_file(TRUSTSTORE_PASS_PATH, TRUSTSTORE_JKS_PATH)

        return can_open_keystore & can_open_truststore

    def get_certificate(self, pass_file_path, jks_file_path):
        password = open(pass_file_path, 'rb').read()
        crypto.load_pkcs12(open(jks_file_path, 'rb').read(), password)
        return crypto.load_pkcs12(open(jks_file_path, 'rb').read(), password).get_certificate()

    def get_owner_data_from_certificate(self, certificate):
        list = certificate.get_subject().get_components()
        return dict((k, v) for k, v in list)

    def can_open_jks_file_by_pass_file(self, pass_file_path, jks_file_path):
      try:
        self.get_certificate(pass_file_path, jks_file_path)
        return True
      except:
        return False

    def get_sans(self, cert):
        extension = cert.to_cryptography().extensions.get_extension_for_oid(ExtensionOID.SUBJECT_ALTERNATIVE_NAME)
        dnsList = extension.value.get_values_for_type(x509.DNSName)
        return ':'.join(map(lambda dns: dns.encode('ascii','ignore'), dnsList))

    def owner_data_match_envs(self, path_to_env):
        envs = self.get_envs_as_dict(self.read_list_env_from_file(path_to_env))
        certificate = self.get_certificate(KEYSTORE_PASS_PATH, KEYSTORE_JKS_PATH)
        data = self.get_owner_data_from_certificate(certificate)
        data['SANS'] = self.get_sans(certificate)
        return cmp(envs, data) == 0

    def create_mount_dir(self):
        if not os.path.exists(MOUNT_PATH):
            os.makedirs(MOUNT_PATH)

    def remove_mount_dir(self):
        shutil.rmtree(MOUNT_PATH)

    def can_find_api_response_in_logs(self, container_name):
        logs = self.get_container_logs(container_name)
        api_logs = re.findall(ERROR_API_REGEX, logs)
        if api_logs:
            return True
        else:
            return False

    def get_api_response_from_logs(self, container_name):
        logs = self.get_container_logs(container_name)
        error_api_message = re.findall(ERROR_API_REGEX, logs)
        code = re.findall(RESPONSE_CODE_REGEX, error_api_message[0])
        return code[0]

    def get_container_logs(self, container_name):
        client = docker.from_env()
        container = client.containers.get(container_name)
        logs = container.logs()
        return logs
