import docker
import os
import shutil
import tarfile
import re
from OpenSSL import crypto

ARCHIVES_PATH = os.getenv("WORKSPACE") + "/archives/"
TMP_PATH = os.getenv("WORKSPACE") + "/tests/aaf/certservice/tmp"

ERROR_API_REGEX = 'Error on API response.*[0-9]{3}'
RESPONSE_CODE_REGEX = '[0-9]{3}'

class CertClientManager:

    def run_client_container(self, client_image, container_name, path_to_env, request_url, network):
        client = docker.from_env()
        environment = self.read_list_env_from_file(path_to_env)
        environment.append("REQUEST_URL=" + request_url)
        container = client.containers.run(image=client_image, name=container_name, detach=True, environment=environment,
                                          network=network)
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

    def remove_client_container_and_save_logs(self, container_name):
        client = docker.from_env()
        container = client.containers.get(container_name)
        text_file = open(ARCHIVES_PATH + "container_" + container.short_id + ".log", "w")
        text_file.write(container.logs())
        text_file.close()
        container.remove()

    def can_open_keystore_and_truststore_by_pass(self, container_name):
        self.copy_jks_file_to_tmp_dir(container_name)

        keystore_pass_path = TMP_PATH + '/logs/log/keystore.pass'
        keystore_jks_path = TMP_PATH + '/logs/log/keystore.jks'
        can_open_keystore = self.can_open(keystore_pass_path, keystore_jks_path)

        truststore_pass_path = TMP_PATH + '/logs/log/truststore.pass'
        truststore_jks_path = TMP_PATH + '/logs/log/truststore.jks'
        can_open_truststore = self.can_open(truststore_pass_path,truststore_jks_path)

        self.remove_tmp_dir(TMP_PATH)
        return can_open_keystore & can_open_truststore

    def copy_jks_file_to_tmp_dir(self, container_name):
        os.mkdir(TMP_PATH)
        self.copy_jks_file_from_container_to_tmp_dir(container_name)
        self.extract_tar_file()

    def copy_jks_file_from_container_to_tmp_dir(self, container_name):
        client = docker.from_env()
        container = client.containers.get(container_name)
        f = open(TMP_PATH + '/var_log.tar', 'wb')
        bits, stat = container.get_archive('/var/log/')
        for chunk in bits:
            f.write(chunk)
        f.close()

    def extract_tar_file(self):
        my_tar = tarfile.open(TMP_PATH + '/var_log.tar')
        my_tar.extractall(TMP_PATH + '/logs')
        my_tar.close()

    def can_open(self, pass_file_path, jks_file_path):
        code = open(pass_file_path, 'rb').read()
        try:
            crypto.load_pkcs12(open(jks_file_path, 'rb').read(), code)
            return True
        except:
            return False

    def remove_tmp_dir(self, tmp_path):
        shutil.rmtree(tmp_path)

    def can_find_api_response_in_logs(self, container_name):
        logs = self.get_container_logs(container_name)
        try:
            re.findall(ERROR_API_REGEX, logs)
            return True
        except:
            return False

    def get_api_response_from_logs(self, container_name):
        logs = self.get_container_logs(container_name)
        error_api_message = re.findall(ERROR_API_REGEX, logs)
        code = re.findall(RESPONSE_CODE_REGEX,error_api_message[0])
        return code[0]

    def get_container_logs(self, container_name):
        client = docker.from_env()
        container = client.containers.get(container_name)
        logs = container.logs()
        return logs