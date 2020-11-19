from cryptography.x509.oid import ExtensionOID
from cryptography import x509

class ArtifactParser:

  def __init__(self, mount_path, ext):
    self.keystorePassPath = mount_path + '/keystore.pass'
    self.keystorePath = mount_path + '/keystore.' + ext
    self.truststorePassPath = mount_path + '/truststore.pass'
    self.truststorePath = mount_path + '/truststore.' + ext

  def contains_expected_data(self, data):
    expectedData = data.expectedData
    actualData = data.actualData
    return cmp(expectedData, actualData) == 0

  def get_owner_data_from_certificate(self, certificate):
    list = certificate.get_subject().get_components()
    return dict((k, v) for k, v in list)

  def get_sans(self, cert):
    extension = cert.to_cryptography().extensions.get_extension_for_oid(ExtensionOID.SUBJECT_ALTERNATIVE_NAME)
    dnsList = extension.value.get_values_for_type(x509.DNSName)
    return ','.join(map(lambda dns: dns.encode('ascii','ignore'), dnsList))

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

