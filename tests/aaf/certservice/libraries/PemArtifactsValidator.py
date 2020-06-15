import os

class PemArtifactsValidator:

  def __init__(self, mount_path):
    self.keystorePath = mount_path + '/keystore.pem'
    self.key = mount_path + '/key.pem'
    self.truststorePath = mount_path + '/truststore.pem'

  def artifacts_exist_and_are_not_empty(self):
    keystoreExists = self.file_exists_and_is_not_empty(self.keystorePath)
    truststoreExists = self.file_exists_and_is_not_empty(self.truststorePath)
    keyExists = self.file_exists_and_is_not_empty(self.key)
    return keystoreExists and truststoreExists and keyExists

  def file_exists_and_is_not_empty(self, pathToFile):
    return os.path.isfile(pathToFile) and os.path.getsize(pathToFile) > 0
