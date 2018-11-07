import re
import time
from http.server import BaseHTTPRequestHandler
import httpServerLib

pnfs = 'Empty'


class AAISetup(BaseHTTPRequestHandler):

    def do_PUT(self):
        if re.search('/set_pnfs', self.path):
            global pnfs
            content_length = int(self.headers['Content-Length'])
            pnfs = self.rfile.read(content_length)
            httpServerLib.header_200_and_json(self)

        return

    def do_POST(self):
        if re.search('/reset', self.path):
            global pnfs
            pnfs = 'Empty'
            httpServerLib.header_200_and_json(self)

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


def _main_(handler_class=AAIHandler, protocol="HTTP/1.0"):
    handler_class.protocol_version = protocol
    httpServerLib.start_http_endpoint(3333, AAIHandler)
    httpServerLib.start_https_endpoint(3334, AAIHandler, keyfile="certs/org.onap.aai.key", certfile="certs/aai_aai.onap.org.cer", ca_certs="certs/ca_local_0.cer")
    httpServerLib.start_http_endpoint(3335, AAISetup)
    while 1:
        time.sleep(10)


if __name__ == '__main__':
    _main_()
