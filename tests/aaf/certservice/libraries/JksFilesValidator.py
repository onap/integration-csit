from OpenSSL import crypto
from cryptography.x509.oid import ExtensionOID
from cryptography import x509
from EnvsReader import EnvsReader

class JksFilesValidator:
  keystorePassPath = ''
  keystoreJksPath = ''
  truststorePassPath = ''
  truststoreJksPath = ''

  def __init__(self, mount_path):
    self.keystorePassPath = mount_path + '/keystore.pass'
    self.keystoreJksPath = mount_path + '/keystore.jks'
    self.truststorePassPath = mount_path + '/truststore.pass'
    self.truststoreJksPath = mount_path + '/truststore.jks'

  def get_and_compare_data(self, path_to_env):
    data = self.get_data(path_to_env)
    return data, self.contains_expected_data(data)

  def can_open_keystore_and_truststore_with_pass(self):
    can_open_keystore = self.can_open_jks_file_by_pass_file(self.keystorePassPath, self.keystoreJksPath)
    can_open_truststore = self.can_open_jks_file_by_pass_file(self.truststorePassPath, self.truststoreJksPath)

    return can_open_keystore & can_open_truststore

  def can_open_jks_file_by_pass_file(self, pass_file_path, jks_file_path):
    try:
      self.get_certificate(pass_file_path, jks_file_path)
      return True
    except:
      return False

  def get_data(self, path_to_env):
    envs = self.get_envs_as_dict(EnvsReader().read_list_env_from_file(path_to_env))
    certificate = self.get_certificate(self.keystorePassPath, self.keystoreJksPath)
    data = self.get_owner_data_from_certificate(certificate)
    data['SANS'] = self.get_sans(certificate)
    return type('', (object,), {"expectedData": envs, "actualData": data})

  def contains_expected_data(self, data):
    expectedData = data.expectedData
    actualData = data.actualData
    return cmp(expectedData, actualData) == 0

  def get_owner_data_from_certificate(self, certificate):
    list = certificate.get_subject().get_components()
    return dict((k, v) for k, v in list)

  def get_certificate(self, pass_file_path, jks_file_path):
    password = open(pass_file_path, 'rb').read()
    crypto.load_pkcs12(open(jks_file_path, 'rb').read(), password)
    return crypto.load_pkcs12(open(jks_file_path, 'rb').read(), password).get_certificate()

  def get_sans(self, cert):
    extension = cert.to_cryptography().extensions.get_extension_for_oid(ExtensionOID.SUBJECT_ALTERNATIVE_NAME)
    dnsList = extension.value.get_values_for_type(x509.DNSName)
    return ':'.join(map(lambda dns: dns.encode('ascii','ignore'), dnsList))

  def get_envs_as_dict(self, list):
    envs = self.get_list_of_pairs_by_mappings(list)
    return self.remove_nones_from_dict(envs)

  def remove_nones_from_dict(self, dictionary):
    return dict((k, v) for k, v in dictionary.iteritems() if k is not None)

  def get_list_of_pairs_by_mappings(self, list):
    mappings = self.get_mappings()
    listOfEnvs = map(lambda k: k.split('='), list)
    return dict((mappings.get(a[0]), a[1]) for a in listOfEnvs)

  def get_mappings(self):
    return {'COMMON_NAME':'CN', 'ORGANIZATION':'O', 'ORGANIZATION_UNIT':'OU', 'LOCATION':'L', 'STATE':'ST', 'COUNTRY':'C', 'SANS':'SANS'}
