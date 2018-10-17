from http.server import BaseHTTPRequestHandler
from http.server import HTTPServer
import _thread, ssl, time, re

pnfs = 'Empty'


class AAISetup(BaseHTTPRequestHandler):

    def do_PUT(self):
        if re.search('/set_pnfs', self.path):
            global pnfs
            content_length = int(self.headers['Content-Length'])
            pnfs = self.rfile.read(content_length)
            _header_200_and_json(self)

        return

    def do_POST(self):
        if re.search('/reset', self.path):
            global pnfs
            pnfs = 'Empty'
            _header_200_and_json(self)

        return

class AAIHandler(BaseHTTPRequestHandler):

    def do_PATCH(self):
        pnfs_name = '/aai/v12/network/pnfs/pnf/' + pnfs.decode()
        if re.search('wrong_aai_record', self.path):
            self.send_response(400)
            self.end_headers()
        elif re.search(pnfs_name, self.path):
            self.send_response(200)
            self.end_headers()
            
        return


def _header_200_and_json(self):
    self.send_response(200)
    self.send_header('Content-Type', 'application/json')
    self.end_headers()


def _main_(handler_class=AAIHandler, protocol="HTTP/1.0"):
    handler_class.protocol_version = protocol
    _thread.start_new_thread(_init_http_endpoints, (3333, AAIHandler))
    _thread.start_new_thread(_init_https_endpoints, (3334, AAIHandler))
    _thread.start_new_thread(_init_http_endpoints, (3335, AAISetup))
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
