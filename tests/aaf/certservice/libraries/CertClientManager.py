import docker


class CertClientManager:

    def client_run_container(self, client_image, container_name, path_to_env, request_url):
        client = docker.from_env()
        environment = self.read_list_env_from_file(path_to_env)
        environment.append("REQUEST_URL=" + request_url)
        container = client.containers.run(image=client_image, name=container_name, detach=True, environment=environment)
        exitcode = container.wait()
        return exitcode

    def client_remove_container(self, container_name):
        client = docker.from_env()
        container = client.containers.get(container_name)
        container.remove()


    def read_list_env_from_file(self, path):
        f = open(path, "r")
        r_list = []
        for line in f:
            line = line.strip()
            if line[0] != "#":
                r_list.append(line)
        return r_list
