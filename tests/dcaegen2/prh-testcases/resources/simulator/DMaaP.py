import logging
import re
import sys
import time
import json
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

event_ves = DMAAP_EMPTY
event_pnf_ready = DMAAP_EMPTY
event_pnf_update = DMAAP_EMPTY

class DmaapSetup(BaseHTTPRequestHandler):

    def do_GET(self):
        try:
            if re.search('/verify/pnf_ready', self.path):
                global event_pnf_ready
                httpServerLib.set_response_200_ok(self, payload = event_pnf_ready)
                logger.debug('DmaapSetup GET /verify/pnf_ready -> 200 OK')
            elif re.search('/verify/pnf_update', self.path):
                global event_pnf_update
                httpServerLib.set_response_200_ok(self, payload = event_pnf_update)
                logger.debug('DmaapSetup GET /verify/pnf_ready -> 200 OK')
            else:
                httpServerLib.set_response_404_not_found(self)
                logger.info('DmaapSetup GET ' + self.path + ' -> 404 Not found')
        except Exception as e:
            logger.error(e)
            httpServerLib.set_response_500_server_error(self)

    def do_PUT(self):
        try:
            if re.search('/setup/ves_event', self.path):
                global event_ves
                event_ves = httpServerLib.get_payload(self)
                httpServerLib.set_response_200_ok(self)
                logger.debug('DmaapSetup PUT /setup/ves_event -> 200 OK, content: ' + event_ves.decode("utf-8"))
            else:
                httpServerLib.set_response_404_not_found(self)
                logger.info('DmaapSetup PUT ' + self.path + ' -> 404 Not found')
        except Exception as e:
            logger.error(e)
            httpServerLib.set_response_500_server_error(self)

    def do_POST(self):
        try:
            if re.search('/reset', self.path):
                global event_ves
                global event_pnf_ready
                global event_pnf_update
                event_ves = DMAAP_EMPTY
                event_pnf_ready = DMAAP_EMPTY
                event_pnf_update = DMAAP_EMPTY
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
                global event_pnf_ready
                event_pnf_ready = httpServerLib.get_payload(self)
                httpServerLib.set_response_200_ok(self)
                logger.debug('DMaaPHandler POST /events/unauthenticated.PNF_READY -> 200, content: '
                             + event_pnf_ready.decode("utf-8"))
            elif re.search('/events/unauthenticated.PNF_UPDATE', self.path):
                global event_pnf_update
                event_pnf_update = httpServerLib.get_payload(self)
                httpServerLib.set_response_200_ok(self)
                logger.debug('DMaaPHandler POST /events/unauthenticated.PNF_READY -> 200, content: '
                             + event_pnf_update.decode("utf-8"))
            else:
                httpServerLib.set_response_404_not_found(self)
                logger.info('DMaaPHandler POST ' + self.path + ' -> 404 Not found')
        except Exception as e:
            logger.error(e)
            httpServerLib.set_response_500_server_error(self)

    def do_GET(self):
        try:
            if re.search('/events/unauthenticated.VES_PNFREG_OUTPUT/OpenDCAE-c12/c12', self.path):
                global event_ves
                httpServerLib.set_response_200_ok(self, payload=self.pack_event_json_as_quoted_string_into_array(event_ves))
                logger.debug(
                    'DMaaPHandler GET /events/unauthenticated.VES_PNFREG_OUTPUT/OpenDcae-c12/c12 -> 200, content: '
                    + event_ves.decode("utf-8"))
                event_ves = DMAAP_EMPTY
                logger.debug('DMaaPHandler GET /events/unauthenticated.VES_PNFREG_OUTPUT/OpenDcae-c12/c12 -> 200')
            else:
                httpServerLib.set_response_404_not_found(self)
                logger.info('DMaaPHandler GET ' + self.path + ' -> 404 Not found')
        except Exception as e:
            logger.error(e)
            httpServerLib.set_response_500_server_error(self)

    def pack_event_json_as_quoted_string_into_array(self, event):
        if event == DMAAP_EMPTY:
            return DMAAP_EMPTY
        else:
            decoded = event_ves.decode("utf-8")
            packed = '[' + json.dumps(decoded) + ']'
            logger.info("prepared response: " + packed)
            return packed.encode()
        

def _main_(handler_class=DMaaPHandler, protocol="HTTP/1.0"):
    handler_class.protocol_version = protocol
    httpServerLib.start_https_endpoint(2223, DMaaPHandler, keyfile="certs/dmaap-mr.key", certfile="certs/dmaap-mr.crt", ca_certs="certs/root.crt")
    httpServerLib.start_http_endpoint(2224, DmaapSetup)
    while 1:
        time.sleep(10)

if __name__ == '__main__':
    _main_()