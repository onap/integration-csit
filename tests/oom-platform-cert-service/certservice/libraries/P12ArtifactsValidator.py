from OpenSSL import crypto
from EnvsReader import EnvsReader
from ArtifactParser import ArtifactParser

class P12ArtifactsValidator:

  def __init__(self, mount_path):
    self.parser = ArtifactParser(mount_path, "p12")

  def get_and_compare_data_p12(self, path_to_env):
    data = self.get_data(path_to_env)
    return data, self.parser.contains_expected_data(data)

  def can_open_keystore_and_truststore_with_pass(self):
    can_open_keystore = self.can_open_store_file_with_pass_file(self.parser.keystorePassPath, self.parser.keystorePath)
    can_open_truststore = self.can_open_store_file_with_pass_file(self.parser.truststorePassPath, self.parser.truststorePath)

    return can_open_keystore & can_open_truststore

  def can_open_store_file_with_pass_file(self, pass_file_path, store_file_path):
    try:
      self.get_certificate(pass_file_path, store_file_path)
      return True
    except:
      return False

  def get_data(self, path_to_env):
    envs = self.parser.get_envs_as_dict(EnvsReader().read_env_list_from_file(path_to_env))
    certificate = self.get_certificate(self.parser.keystorePassPath, self.parser.keystorePath)
    data = self.parser.get_owner_data_from_certificate(certificate)
    data['SANS'] = self.parser.get_sans(certificate)
    return type('', (object,), {"expectedData": envs, "actualData": data})

  def get_certificate(self, pass_file_path, store_file_path):
    password = open(pass_file_path, 'rb').read()
    crypto.load_pkcs12(open(store_file_path, 'rb').read(), password)
    return crypto.load_pkcs12(open(store_file_path, 'rb').read(), password).get_certificate()
