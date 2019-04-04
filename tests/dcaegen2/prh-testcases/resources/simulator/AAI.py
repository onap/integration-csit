import logging
import sys
import re
import time
from http.server import BaseHTTPRequestHandler
import httpServerLib

ch = logging.StreamHandler(sys.stdout)
handlers = [ch]
logging.basicConfig(
    level=logging.DEBUG,
    format='[%(asctime)s] {%(filename)s:%(lineno)d} %(levelname)s - %(message)s',
    handlers=handlers
)

logger = logging.getLogger('AAI-simulator-logger')

pnfs = 'Empty'

class AAISetup(BaseHTTPRequestHandler):

    def do_PUT(self):
        logger.info('AAI SIM Setup Put execution')
        if re.search('/set_pnfs', self.path):
            global pnfs
            content_length = int(self.headers['Content-Length'])
            pnfs = self.rfile.read(content_length)
            logger.info('Execution status 200')
            httpServerLib.header_200_and_json(self)

        return

    def do_POST(self):
        logger.info('AAI SIM Setup Post execution')
        if re.search('/reset', self.path):
            global pnfs
            pnfs = 'Empty'
            logger.info('Execution status 200')
            httpServerLib.header_200_and_json(self)

        return


class AAIHandler(BaseHTTPRequestHandler):

    def do_PATCH(self):
        logger.info('AAI SIM Patch execution')
        pnfs_name = '/aai/v12/network/pnfs/pnf/' + pnfs.decode()
        if re.search('wrong_aai_record', self.path):
            self.send_response(400)
            logger.info('Execution status 400')
            self.end_headers()
        elif re.search(pnfs_name, self.path):
            self.send_response(200)
            logger.info('Execution status 200')
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
