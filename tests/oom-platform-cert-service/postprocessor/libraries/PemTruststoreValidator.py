import re

BEGIN_CERT = "-----BEGIN CERTIFICATE-----"
END_CERT = "-----END CERTIFICATE-----"

class PemTruststoreValidator:

  def assert_pem_truststores_equal(self, result_pem_path, expected_pem_path):
    result_certs = self.get_list_of_pem_certificates(result_pem_path)
    expected_certs = self.get_list_of_pem_certificates(expected_pem_path)
    result_certs.sort()
    expected_certs.sort()
    if len(result_certs) != len(expected_certs):
      return False
    return result_certs == expected_certs


  def get_list_of_pem_certificates(self, path):
    return re.findall(BEGIN_CERT + '(.+?)' + END_CERT, open(path, 'rb').read(), re.DOTALL)
