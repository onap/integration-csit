import _thread
import ssl
from http.server import HTTPServer

def set_response_200_ok(self, payload = None):
    self.send_response(200)
    self.send_header('Content-Type', 'application/json')
    self.end_headers()
    if payload != None:
        self.wfile.write(payload)

def set_response_404_not_found(self):
    self.send_response(404)
    self.end_headers()

def set_response_500_server_error(self):
    self.send_response(500)
    self.end_headers()

def get_payload(self):
    if self.headers['Content-Length'] == None:
        raise Exception('Invalid payload, Content-Length not defined')

    content_length = int(self.headers['Content-Length'])
    return self.rfile.read(content_length)

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
