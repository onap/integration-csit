import logging
import re
import sys
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

logger = logging.getLogger('DMaaP-simulator-logger')

DMAAP_EMPTY = b'[]'

ves_event = DMAAP_EMPTY
captured_prh_event = DMAAP_EMPTY

class DmaapSetup(BaseHTTPRequestHandler):

    def do_GET(self):
        try:
            if re.search('/verify/pnf_ready', self.path):
                global captured_prh_event
                httpServerLib.set_response_200_ok(self, payload = captured_prh_event)
                logger.debug('DmaapSetup GET /setup/pnf_ready -> 200 OK')
            else:
                httpServerLib.set_response_404_not_found(self)
                logger.info('DmaapSetup GET ' + self.path + ' -> 404 Not found')
        except Exception as e:
            logger.error(e)
            httpServerLib.set_response_500_server_error(self)

    def do_PUT(self):
        try:
            if re.search('/setup/ves_event', self.path):
                global ves_event
                ves_event = httpServerLib.get_payload(self)
                httpServerLib.set_response_200_ok(self)
                logger.debug('DmaapSetup PUT /setup/ves_event -> 200 OK, content: ' + ves_event.decode("utf-8"))
            else:
                httpServerLib.set_response_404_not_found(self)
                logger.info('DmaapSetup PUT ' + self.path + ' -> 404 Not found')
        except Exception as e:
            logger.error(e)
            httpServerLib.set_response_500_server_error(self)

    def do_POST(self):
        try:
            if re.search('/reset', self.path):
                global ves_event
                global captured_prh_event
                ves_event = DMAAP_EMPTY
                captured_prh_event = DMAAP_EMPTY
                httpServerLib.set_response_200_ok(self)
                logger.debug('DmaapSetup POST /reset -> 200 OK')
            else:
                httpServerLib.set_response_404_not_found(self)
                logger.info('DmaapSetup POST ' + self.path + ' -> 404 Not found')
        except Exception as e:
            logger.error(e)
            httpServerLib.set_response_500_server_error(self)

class DMaaPHandler(BaseHTTPRequestHandler):

    def do_POST(self):
        try:
            if re.search('/events/unauthenticated.PNF_READY', self.path):
                global captured_prh_event
                captured_prh_event = httpServerLib.get_payload(self)
                httpServerLib.set_response_200_ok(self)
                logger.debug('DMaaPHandler POST /events/unauthenticated.PNF_READY -> 200, content: '
                             + captured_prh_event.decode("utf-8"))
            else:
                httpServerLib.set_response_404_not_found(self)
                logger.info('DMaaPHandler POST ' + self.path + ' -> 404 Not found')
        except Exception as e:
            logger.error(e)
            httpServerLib.set_response_500_server_error(self)

    def do_GET(self):
        try:
            if re.search('/events/unauthenticated.VES_PNFREG_OUTPUT/OpenDCAE-c12/c12', self.path):
                global ves_event
                httpServerLib.set_response_200_ok(self, payload = ves_event)
                logger.debug(
                    'DMaaPHandler GET /events/unauthenticated.VES_PNFREG_OUTPUT/OpenDcae-c12/c12 -> 200, content: '
                    + ves_event.decode("utf-8"))
                ves_event = DMAAP_EMPTY
                logger.debug('DMaaPHandler GET /events/unauthenticated.VES_PNFREG_OUTPUT/OpenDcae-c12/c12 -> 200')
            else:
                httpServerLib.set_response_404_not_found(self)
                logger.info('DMaaPHandler GET ' + self.path + ' -> 404 Not found')
        except Exception as e:
            logger.error(e)
            httpServerLib.set_response_500_server_error(self)

def _main_(handler_class=DMaaPHandler, protocol="HTTP/1.0"):
    handler_class.protocol_version = protocol
    httpServerLib.start_https_endpoint(2223, DMaaPHandler, keyfile="certs/dmaap-mr.key", certfile="certs/dmaap-mr.crt", ca_certs="certs/root.crt")
    httpServerLib.start_http_endpoint(2224, DmaapSetup)
    while 1:
        time.sleep(10)

if __name__ == '__main__':
    _main_()