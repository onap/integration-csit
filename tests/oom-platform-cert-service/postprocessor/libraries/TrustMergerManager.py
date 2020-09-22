import docker
import os
import shutil
from EnvsReader import EnvsReader
from docker.types import Mount

ARCHIVES_PATH = os.getenv("WORKSPACE") + "/archives/"


class TrustMergerManager:

  def __init__(self, mount_path, truststores_path):
    self.mount_path = mount_path
    self.truststores_path = truststores_path

  def run_merger_container(self, merger_image, merger_name, path_to_env):
    self.remove_mount_dir()
    shutil.copytree(self.truststores_path, self.mount_path)
    client = docker.from_env()
    environment = EnvsReader().read_env_list_from_file(path_to_env)
    container = client.containers.run(
        image=merger_image,
        name=merger_name,
        environment=environment,
        user='root',  # Run container as root to avoid permission issues with volume mount access
        mounts=[Mount(target='/var/certs', source=self.mount_path, type='bind')],
        detach=True
    )
    exitcode = container.wait()
    return exitcode

  def create_mount_dir(self):
    if not os.path.exists(self.mount_path):
      os.makedirs(self.mount_path)

  def remove_mount_dir(self):
    if os.path.exists(self.mount_path):
      shutil.rmtree(self.mount_path)

  def remove_merger_container_and_save_logs(self, container_name, log_file_name):
    client = docker.from_env()
    container = client.containers.get(container_name)
    text_file = open(ARCHIVES_PATH + "merger_container_" + log_file_name + ".log", "w")
    text_file.write(container.logs())
    text_file.close()
    container.remove()
    self.remove_mount_dir()
