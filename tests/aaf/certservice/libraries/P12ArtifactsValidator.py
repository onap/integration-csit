from OpenSSL import crypto
from EnvsReader import EnvsReader
from ArtifactsValidator import ArtifactsValidator

class P12ArtifactsValidator:

  def __init__(self, mount_path):
    self.validator = ArtifactsValidator(mount_path, "p12")

  def get_and_compare_data_p12(self, path_to_env):
    data = self.get_data(path_to_env)
    return data, self.validator.contains_expected_data(data)

  def can_open_keystore_and_truststore_with_pass(self):
    can_open_keystore = self.can_open_store_file_with_pass_file(self.validator.keystorePassPath, self.validator.keystorePath)
    can_open_truststore = self.can_open_store_file_with_pass_file(self.validator.truststorePassPath, self.validator.truststorePath)

    return can_open_keystore & can_open_truststore

  def can_open_store_file_with_pass_file(self, pass_file_path, store_file_path):
    try:
      self.get_certificate(pass_file_path, store_file_path)
      return True
    except:
      return False

  def get_data(self, path_to_env):
    envs = self.validator.get_envs_as_dict(EnvsReader().read_env_list_from_file(path_to_env))
    certificate = self.get_certificate(self.validator.keystorePassPath, self.validator.keystorePath)
    data = self.validator.get_owner_data_from_certificate(certificate)
    data['SANS'] = self.validator.get_sans(certificate)
    return type('', (object,), {"expectedData": envs, "actualData": data})

  def get_certificate(self, pass_file_path, store_file_path):
    password = open(pass_file_path, 'rb').read()
    crypto.load_pkcs12(open(store_file_path, 'rb').read(), password)
    return crypto.load_pkcs12(open(store_file_path, 'rb').read(), password).get_certificate()
