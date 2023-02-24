import http.server
from robot_library.dmaap_simulator import DMaaPHandler


class DMaaPServer(http.server.HTTPServer):

    def __init__(self, server_address, protocol, dmaap_simulator):

        def handler_class_constructor(*args):
            DMaaPHandler.DMaaPHandler(dmaap_simulator, *args)
        DMaaPHandler.protocol_version = protocol
        http.server.HTTPServer.__init__(self, server_address, handler_class_constructor)

        serer_address = self.socket.getsockname()
        print ("Serving HTTP on", serer_address[0], "port", serer_address[1], "...")

    def set_dmaap_successfull_code(self,code_number):
        DMaaPHandler.DMaaPHandler.succes_response_code=code_number

    def reset_dmaap_succesfull_code(self):
        DMaaPHandler.DMaaPHandler.succes_response_code=DMaaPHandler.DMaaPHandler.DEFAULT_SUCCES_RESPONSE_CODE


def create_dmaap_server(dmaap_simulator, protocol="HTTP/1.0", port=3904):
    server_address = ('', port)
    httpd = DMaaPServer(server_address, protocol, dmaap_simulator)

    return httpd
