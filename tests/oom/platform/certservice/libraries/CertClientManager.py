import docker
import os
import shutil
import re
from EnvsReader import EnvsReader
from docker.types import Mount

ARCHIVES_PATH = os.getenv("WORKSPACE") + "/archives/"

ERROR_API_REGEX = 'Error on API response.*[0-9]{3}'
RESPONSE_CODE_REGEX = '[0-9]{3}'


class CertClientManager:

    def __init__(self, mount_path, truststore_path):
        self.mount_path = mount_path
        self.truststore_path = truststore_path

    def run_client_container(self, client_image, container_name, path_to_env, request_url, network):
        self.create_mount_dir()
        client = docker.from_env()
        environment = EnvsReader().read_env_list_from_file(path_to_env)
        environment.append("REQUEST_URL=" + request_url)
        container = client.containers.run(
            image=client_image,
            name=container_name,
            environment=environment,
            network=network,
            user='root',  # Run container as root to avoid permission issues with volume mount access
            mounts=[Mount(target='/var/certs', source=self.mount_path, type='bind'),
                    Mount(target='/etc/onap/oom/platform/certservice/certs/', source=self.truststore_path, type='bind')],
            detach=True
        )
        exitcode = container.wait()
        return exitcode

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
