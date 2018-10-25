
class RequestsClientCert:
    """RequestsClientCert allows adding a client cert to the Requests Robot Library."""
    
    def add_client_cert(self, session, cert):
        """Add Client Cert takes in a requests session object and a string path to the cert"""
        session.cert = cert