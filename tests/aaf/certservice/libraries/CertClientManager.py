import docker
import os
import shutil
import re
from OpenSSL import crypto
from docker.types import Mount

ARCHIVES_PATH = os.getenv("WORKSPACE") + "/archives/"
MOUNT_PATH = os.getenv("WORKSPACE") + "/tests/aaf/certservice/tmp"

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

    def remove_client_container_and_save_logs(self, container_name, log_file_name):
        client = docker.from_env()
        container = client.containers.get(container_name)
        text_file = open(ARCHIVES_PATH + "container_" + log_file_name + ".log", "w")
        text_file.write(container.logs())
        text_file.close()
        container.remove()
        self.remove_mount_dir()

    def can_open_keystore_and_truststore_with_pass(self):
        keystore_pass_path = MOUNT_PATH + '/keystore.pass'
        keystore_jks_path = MOUNT_PATH + '/keystore.jks'
        can_open_keystore = self.can_open_jks_file_by_pass_file(keystore_pass_path, keystore_jks_path)

        truststore_pass_path = MOUNT_PATH + '/truststore.pass'
        truststore_jks_path = MOUNT_PATH + '/truststore.jks'
        can_open_truststore = self.can_open_jks_file_by_pass_file(truststore_pass_path, truststore_jks_path)

        return can_open_keystore & can_open_truststore

    def can_open_jks_file_by_pass_file(self, pass_file_path, jks_file_path):
        try:
            password = open(pass_file_path, 'rb').read()
            crypto.load_pkcs12(open(jks_file_path, 'rb').read(), password)
            return True
        except:
            return False

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
