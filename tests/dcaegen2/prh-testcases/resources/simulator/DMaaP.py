import re
import time
from http.server import BaseHTTPRequestHandler
import lib

posted_event_from_prh = b'Empty'
received_event_to_get_method = b'Empty'


class DmaapSetup(BaseHTTPRequestHandler):

    def do_PUT(self):
        if re.search('/set_get_event', self.path):
            global received_event_to_get_method
            content_length = int(self.headers['Content-Length'])
            received_event_to_get_method = self.rfile.read(content_length)
            lib.header_200_and_json(self)

        return

    def do_GET(self):
        if re.search('/events/pnfReady', self.path):
            lib.header_200_and_json(self)
            self.wfile.write(posted_event_from_prh)

        return

    def do_POST(self):
        if re.search('/reset', self.path):
            global posted_event_from_prh
            global received_event_to_get_method
            posted_event_from_prh = b'Empty'
            received_event_to_get_method = b'Empty'
            lib.header_200_and_json(self)

        return


class DMaaPHandler(BaseHTTPRequestHandler):

    def do_POST(self):
        if re.search('/events/unauthenticated.PNF_READY', self.path):
            global posted_event_from_prh
            content_length = int(self.headers['Content-Length'])
            posted_event_from_prh = self.rfile.read(content_length)
            lib.header_200_and_json(self)

        return

    def do_GET(self):
        if re.search('/events/unauthenticated.VES_PNFREG_OUTPUT/OpenDcae-c12/c12', self.path):
            lib.header_200_and_json(self)
            self.wfile.write(received_event_to_get_method)

        return


def _main_(handler_class=DMaaPHandler, protocol="HTTP/1.0"):
    handler_class.protocol_version = protocol
    lib.start_http_endpoint(2222, DMaaPHandler)
    lib.start_https_endpoint(2223, DMaaPHandler)
    lib.start_http_endpoint(2224, DmaapSetup)
    while 1:
        time.sleep(10)


if __name__ == '__main__':
    _main_()
