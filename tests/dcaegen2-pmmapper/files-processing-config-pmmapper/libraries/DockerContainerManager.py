import docker
from EnvsReader import EnvsReader
from docker.types import Mount

class DockerContainerManager:

    def run_pmmapper_container(self, client_image, container_name, path_to_env):
        client = docker.from_env()
        environment = EnvsReader().read_env_list_from_file(path_to_env)
        environment.append("CONFIG_BINDING_SERVICE_SERVICE_HOST=172.18.0.5")
        environment.append("CONFIG_BINDING_SERVICE_SERVICE_PORT=10000")
        environment.append("HOSTNAME=pmmapper")
        client.containers.run(
            image=client_image,
            name=container_name,
            environment=environment,
            ports={'8081': 8081},
            network='files-processing-config-pmmapper_pmmapper-network',
            extra_hosts={'dmaap-dr-node': '172.18.0.2', 'message-router': '172.18.0.7'},
            user='root',
            mounts=[Mount(target='/opt/app/pm-mapper/etc/certs/', source='/var/tmp/', type='bind')],
            detach=True
        )

    def remove_container(self, container_name):
        client = docker.from_env()
        container = client.containers.get(container_name)
        container.stop()
        container.remove()
