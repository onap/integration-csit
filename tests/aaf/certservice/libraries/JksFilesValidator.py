from OpenSSL import crypto
from cryptography.x509.oid import ExtensionOID
from cryptography import x509
from CertClientManager import MOUNT_PATH
import CertClientManager as manager

KEYSTORE_PASS_PATH = MOUNT_PATH + '/keystore.pass'
KEYSTORE_JKS_PATH = MOUNT_PATH + '/keystore.jks'
TRUSTSTORE_PASS_PATH = MOUNT_PATH + '/truststore.pass'
TRUSTSTORE_JKS_PATH = MOUNT_PATH + '/truststore.jks'

class JksFilesValidator:

  def get_mappings(self):
    return {'COMMON_NAME':'CN', 'ORGANIZATION':'O', 'ORGANIZATION_UNIT':'OU', 'LOCATION':'L', 'STATE':'ST', 'COUNTRY':'C', 'SANS':'SANS'}

  def get_list_of_pairs_by_mappings(self, list):
    mappings = self.get_mappings()
    listOfEnvs = map(lambda k: k.split('='), list)
    return dict((mappings.get(a[0]), a[1]) for a in listOfEnvs)

  def remove_nones_from_dict(self, dictionary):
    return dict((k, v) for k, v in dictionary.iteritems() if k is not None)

  def get_envs_as_dict(self, list):
    envs = self.get_list_of_pairs_by_mappings(list)
    return self.remove_nones_from_dict(envs)

  def get_sans(self, cert):
    extension = cert.to_cryptography().extensions.get_extension_for_oid(ExtensionOID.SUBJECT_ALTERNATIVE_NAME)
    dnsList = extension.value.get_values_for_type(x509.DNSName)
    return ':'.join(map(lambda dns: dns.encode('ascii','ignore'), dnsList))

  def get_certificate(self, pass_file_path, jks_file_path):
    password = open(pass_file_path, 'rb').read()
    crypto.load_pkcs12(open(jks_file_path, 'rb').read(), password)
    return crypto.load_pkcs12(open(jks_file_path, 'rb').read(), password).get_certificate()

  def get_owner_data_from_certificate(self, certificate):
    list = certificate.get_subject().get_components()
    return dict((k, v) for k, v in list)

  def can_open_jks_file_by_pass_file(self, pass_file_path, jks_file_path):
    try:
      self.get_certificate(pass_file_path, jks_file_path)
      return True
    except:
      return False

  def can_open_keystore_and_truststore_with_pass(self):
    can_open_keystore = self.can_open_jks_file_by_pass_file(KEYSTORE_PASS_PATH, KEYSTORE_JKS_PATH)
    can_open_truststore = self.can_open_jks_file_by_pass_file(TRUSTSTORE_PASS_PATH, TRUSTSTORE_JKS_PATH)

    return can_open_keystore & can_open_truststore

  def contains_expected_data(self, data):
    expectedData = data.expectedData
    actualData = data.actualData
    return cmp(expectedData, actualData) == 0

  def get_data(self, path_to_env):
    envs = self.get_envs_as_dict(manager.CertClientManager().read_list_env_from_file(path_to_env))
    certificate = self.get_certificate(KEYSTORE_PASS_PATH, KEYSTORE_JKS_PATH)
    data = self.get_owner_data_from_certificate(certificate)
    data['SANS'] = self.get_sans(certificate)
    return type('', (object,), {"expectedData": envs, "actualData": data})
