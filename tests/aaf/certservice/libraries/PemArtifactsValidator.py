import os
from OpenSSL import crypto
from cryptography import x509
from cryptography.hazmat.backends import default_backend
from EnvsReader import EnvsReader
from ArtifactsValidator import ArtifactsValidator

class PemArtifactsValidator:

  def __init__(self, mount_path):
    self.validator = ArtifactsValidator(mount_path, "pem")
    self.key = mount_path + '/key.pem'

  def get_and_compare_data_pem(self, path_to_env):
    data = self.get_data_pem(path_to_env)
    return data, self.validator.contains_expected_data(data)

  def artifacts_exist_and_are_not_empty(self):
    keystoreExists = self.file_exists_and_is_not_empty(self.validator.keystorePath)
    truststoreExists = self.file_exists_and_is_not_empty(self.validator.truststorePath)
    keyExists = self.file_exists_and_is_not_empty(self.key)
    return keystoreExists and truststoreExists and keyExists

  def file_exists_and_is_not_empty(self, pathToFile):
    return os.path.isfile(pathToFile) and os.path.getsize(pathToFile) > 0

  def get_data_pem(self, path_to_env):
    envs = self.validator.get_envs_as_dict(EnvsReader().read_env_list_from_file(path_to_env))
    certificate = self.get_keystore_certificate()
    data = self.validator.get_owner_data_from_certificate(certificate)
    data['SANS'] = self.validator.get_sans(certificate)
    return type('', (object,), {"expectedData": envs, "actualData": data})

  def get_keystore_certificate(self):
    return crypto.X509.from_cryptography(self.load_x509_certificate())

  def load_x509_certificate(self):
    cert = x509.load_pem_x509_certificate(open(self.validator.keystorePath, 'rb').read(), default_backend())
    return cert
