import BaseHTTPServer
import DMaaPHandler


class DMaaPServer(BaseHTTPServer.HTTPServer):

    def __init__(self, server_address, protocol, dmaap_simulator):

        def handler_class_constructor(*args):
            DMaaPHandler.DMaaPHandler(dmaap_simulator, *args)
        DMaaPHandler.protocol_version = protocol
        BaseHTTPServer.HTTPServer.__init__(self, server_address, handler_class_constructor)

        sa = self.socket.getsockname()
        print "Serving HTTP on", sa[0], "port", sa[1], "..."


def create_dmaap_server(dmaap_simulator, protocol="HTTP/1.0", port=3904):
    server_address = ('', port)
    httpd = DMaaPServer(server_address, protocol, dmaap_simulator)

    return httpd
