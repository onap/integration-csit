import _thread
import re
import ssl
import time
from http.server import BaseHTTPRequestHandler
from http.server import HTTPServer

posted_event_from_prh = b'Empty'
received_event_to_get_method = b'Empty'


class DmaapSetup(BaseHTTPRequestHandler):

    def do_PUT(self):
        if re.search('/set_get_event', self.path):
            global received_event_to_get_method
            content_length = int(self.headers['Content-Length'])
            received_event_to_get_method = self.rfile.read(content_length)
            _header_200_and_json(self)

        return

    def do_GET(self):
        if re.search('/events/pnfReady', self.path):
            _header_200_and_json(self)
            self.wfile.write(posted_event_from_prh)

        return

    def do_POST(self):
        if re.search('/reset', self.path):
            global posted_event_from_prh
            global received_event_to_get_method
            posted_event_from_prh = b'Empty'
            received_event_to_get_method = b'Empty'
            _header_200_and_json(self)

        return


class DMaaPHandler(BaseHTTPRequestHandler):

    def do_POST(self):
        if re.search('/events/unauthenticated.PNF_READY', self.path):
            global posted_event_from_prh
            content_length = int(self.headers['Content-Length'])
            posted_event_from_prh = self.rfile.read(content_length)
            _header_200_and_json(self)

        return

    def do_GET(self):
        if re.search('/events/unauthenticated.VES_PNFREG_OUTPUT/OpenDcae-c12/c12', self.path):
            _header_200_and_json(self)
            self.wfile.write(received_event_to_get_method)

        return


def _header_200_and_json(self):
    self.send_response(200)
    self.send_header('Content-Type', 'application/json')
    self.end_headers()


def _main_(handler_class=DMaaPHandler, protocol="HTTP/1.0"):
    handler_class.protocol_version = protocol
    _thread.start_new_thread(_init_http_endpoints, (2222, DMaaPHandler))
    _thread.start_new_thread(_init_https_endpoints, (2223, DMaaPHandler))
    _thread.start_new_thread(_init_http_endpoints, (2224, DmaapSetup))
    while 1:
        time.sleep(10)


def _init_http_endpoints(port, handler_class, server_class=HTTPServer):
    server = server_class(('', port), handler_class)
    sa = server.socket.getsockname()
    print("Serving HTTP on", sa[0], "port", sa[1], "for", handler_class, "...")
    server.serve_forever()


def _init_https_endpoints(port, handler_class, server_class=HTTPServer):
    server = server_class(('', port), handler_class)
    server.socket = ssl.wrap_socket(server.socket,
                                    keyfile="certs/server.key", certfile="certs/server.crt",
                                    ca_certs="certs/client.crt", server_side=True)
    sa = server.socket.getsockname()
    print("Serving HTTPS on", sa[0], "port", sa[1], "for", handler_class, "...")
    server.serve_forever()


if __name__ == '__main__':
    _main_()
