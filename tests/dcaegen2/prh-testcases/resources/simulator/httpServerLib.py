import _thread
import ssl
from http.server import HTTPServer


def header_200_and_json(self):
    self.send_response(200)
    self.send_header('Content-Type', 'application/json')
    self.end_headers()


def start_http_endpoint(port, handler_class):
    _thread.start_new_thread(init_http_endpoints, (port, handler_class))


def start_https_endpoint(port, handler_class, keyfile, certfile, ca_certs):
    _thread.start_new_thread(init_https_endpoints, (port, handler_class, keyfile, certfile, ca_certs))


def init_http_endpoints(port, handler_class, server_class=HTTPServer):
    server = server_class(('', port), handler_class)
    sa = server.socket.getsockname()
    print("Serving HTTP on", sa[0], "port", sa[1], "for", handler_class, "...")
    server.serve_forever()


def init_https_endpoints(port, handler_class, keyfile, certfile, ca_certs, server_class=HTTPServer):
    server = server_class(('', port), handler_class)
    server.socket = ssl.wrap_socket(server.socket, keyfile=keyfile, certfile=certfile,
                                    ca_certs=ca_certs, server_side=True)
    sa = server.socket.getsockname()
    print("Serving HTTPS on", sa[0], "port", sa[1], "for", handler_class, "...")
    server.serve_forever()
