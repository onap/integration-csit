from OpenSSL import crypto
from cryptography.x509.oid import ExtensionOID
import re
import base64


def generate_csr_and_pk_with_sans(sans):
  sans = [str(s) for s in sans]
  key = crypto.PKey()
  key.generate_key(crypto.TYPE_RSA, 2048)

  req = _generate_csr(key, sans)

  key_pem = crypto.dump_privatekey(crypto.FILETYPE_PEM, key)
  req_pem = crypto.dump_certificate_request(crypto.FILETYPE_PEM, req)
  base64_key_pem = base64.b64encode(key_pem)
  base64_req_pem = base64.b64encode(req_pem)
  return base64_req_pem, base64_key_pem


def _generate_csr(key, sans):
  req = crypto.X509Req()
  req.get_subject().CN = "onap.org"
  req.get_subject().countryName = "US"
  req.get_subject().stateOrProvinceName = "California"
  req.get_subject().localityName = "San-Francisco"
  req.get_subject().organizationName = "Linux-Foundation"
  req.get_subject().organizationalUnitName = "ONAP"
  req.add_extensions([
    crypto.X509Extension("subjectAltName", False, ", ".join(sans))
  ])
  req.set_pubkey(key)
  req.sign(key, "sha1")
  return req

def validate_cert_contains_sans(cert_chain, sans):
  sans = [re.sub(r'.*?:', "", str(s), 1) for s in sans]
  cert_pem = cert_chain[0].encode('utf8')
  cert = crypto.load_certificate(crypto.FILETYPE_PEM, cert_pem)
  sans_from_cert = cert.to_cryptography().extensions.get_extension_for_oid(ExtensionOID.SUBJECT_ALTERNATIVE_NAME).value
  sans_from_cert = [str(s.value) for s in sans_from_cert]
  for san in sans:
    if san not in sans_from_cert:
      return False
  return True
