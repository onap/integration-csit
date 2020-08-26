
import jks

class JksTruststoreValidator:

  def get_truststore(self, truststore_path, password_path):
    truststore = jks.KeyStore.load(truststore_path, open(password_path, 'rb').read())
    return truststore.certs

  def assert_jks_truststores_equal(self, result_truststore_path, password_path, expected_truststore_path):
    result_certs = self.get_truststore(result_truststore_path, password_path)
    expected_certs = self.get_truststore(expected_truststore_path, password_path)
    if len(result_certs) != len(expected_certs):
      return False
    for k in result_certs:
      if not (k in expected_certs and result_certs[k].cert == expected_certs[k].cert):
        return False
    return True
