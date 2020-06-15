import jks
from OpenSSL import crypto
from cryptography import x509
from cryptography.hazmat.backends import default_backend
from EnvsReader import EnvsReader
from ArtifactsValidator import ArtifactsValidator

class JksArtifactsValidator:

  def __init__(self, mount_path):
    self.validator = ArtifactsValidator(mount_path, "jks")

  def get_and_compare_data_jks(self, path_to_env):
    data = self.get_data_jks(path_to_env)
    return data, self.validator.contains_expected_data(data)

  def get_keystore(self):
    keystore = jks.KeyStore.load(self.validator.keystorePath, open(self.validator.keystorePassPath, 'rb').read())
    return keystore.private_keys['certificate'].cert_chain[0][1]

  def get_truststore(self):
    truststore = jks.KeyStore.load(self.validator.truststorePath, open(self.validator.truststorePassPath, 'rb').read())
    return truststore.certs

  def can_open_keystore_and_truststore_with_pass_jks(self):
    try:
      jks.KeyStore.load(self.validator.keystorePath, open(self.validator.keystorePassPath, 'rb').read())
      jks.KeyStore.load(self.validator.truststorePath, open(self.validator.truststorePassPath, 'rb').read())
      return True
    except:
      return False

  def get_data_jks(self, path_to_env):
    envs = self.validator.get_envs_as_dict(EnvsReader().read_env_list_from_file(path_to_env))
    certificate = self.get_keystore_certificate()
    data = self.validator.get_owner_data_from_certificate(certificate)
    data['SANS'] = self.validator.get_sans(certificate)
    return type('', (object,), {"expectedData": envs, "actualData": data})

  def get_keystore_certificate(self):
    return crypto.X509.from_cryptography(self.load_x509_certificate(self.get_keystore()))

  def load_x509_certificate(self, data):
    cert = x509.load_der_x509_certificate(data, default_backend())
    return cert
