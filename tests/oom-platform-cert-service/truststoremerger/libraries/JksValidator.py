
import jks

class JksValidator:

  def get_jks_entries(self, jks_path, password_path):
    store = jks.KeyStore.load(jks_path, open(password_path, 'rb').read())
    return store.entries

  def assert_jks_truststores_equal(self, result_truststore_path, password_path, expected_truststore_path):
    result_keys = self.get_jks_entries(result_truststore_path, password_path)
    expected_keys = self.get_jks_entries(expected_truststore_path, password_path)
    if len(result_keys) != len(expected_keys):
      return False
    for k in result_keys:
      if not (k in expected_keys and result_keys[k].cert == expected_keys[k].cert):
        return False
    return True

  def assert_jks_keystores_equal(self, result_keystore_path, password_path, expected_keystore_path):
    result_keys = self.get_jks_entries(result_keystore_path, password_path)
    expected_keys = self.get_jks_entries(expected_keystore_path, password_path)
    if len(result_keys) != len(expected_keys):
      return False
    for k in result_keys:
      if not (k in expected_keys and result_keys[k].pkey == expected_keys[k].pkey):
        return False
    return True
