import re
import time
from http.server import BaseHTTPRequestHandler
import httpServerLib


posted_event_from_bbs = b'[]'
received_event_to_get_method = b'[]'


class DmaapSetup(BaseHTTPRequestHandler):

    """
    This Handler is used by the test harness to prepare the buffers:
        test harness places VES events using PUT from the harness into the 
        "received_event buffer"
        test harness will write policy topics from the BBS us to the posted event buffer
    """
    def do_PUT(self):
        # Read the event from the test harness place it in the received event buffer
        if re.search('/set_get_event', self.path):
            content_length = int(self.headers['Content-Length'])
            global received_event_to_get_method
            received_event_to_get_method = self.rfile.read(content_length)
            httpServerLib.header_200_and_json(self)

        return

    def do_GET(self):
        # The test harness receives the policy triggers from the posted event
        # by issuing a get and receiving the response.
        if re.search('/events/dcaeClOutput', self.path):
            global posted_event_from_bbs
            httpServerLib.header_200_and_json(self)
            self.wfile.write(posted_event_from_bbs)

        return

    def do_POST(self):
        if re.search('/reset', self.path):
            global posted_event_from_bbs
            global received_event_to_get_method
            posted_event_from_bbs = b'[]'
            received_event_to_get_method = b'[]'
            httpServerLib.header_200_and_json(self)

        return


class DMaaPHandler(BaseHTTPRequestHandler):
    """
    This Handler is what the BBS uS connects to - The test library has posted the
    the VES events in the setup Handler which are then received by the BBS uS via
    this handler's do_GET function.
    Likewise the policy trigger posted by the BBS uS is received and placed in the
     in the posted event buffer which the test harness retrieves using the setup handler.
    """

    def do_POST(self):
        # Post of the policy triggers from the BBS uS
        if re.search('/events/unauthenticated.DCAE_CL_OUTPUT', self.path):
            global posted_event_from_bbs
            content_length = int(self.headers['Content-Length'])
            posted_event_from_bbs = self.rfile.read(content_length)
            httpServerLib.header_200_and_json(self)

        return

    def do_GET(self):
        # BBS uS issues a Get to receive VES and PNF UPdate event from DMAAP
        global received_event_to_get_method
        if re.search('/events/unauthenticated.PNF_UPDATE', self.path):
            httpServerLib.header_200_and_json(self)
            self.wfile.write(received_event_to_get_method)
        elif re.search('/events/unauthenticated_CPE_AUTHENTICATION/OpenDcae-c12/c12', self.path):
            httpServerLib.header_200_and_json(self)
            self.wfile.write(received_event_to_get_method)

        return


def _main_(handler_class=DMaaPHandler, protocol="HTTP/1.0"):
    handler_class.protocol_version = protocol
    httpServerLib.start_http_endpoint(2222, DMaaPHandler)
    httpServerLib.start_https_endpoint(2223, DMaaPHandler, keyfile="certs/org.onap.dmaap-bc.key", certfile="certs/dmaap_bc_topic_mgr_dmaap_bc.onap.org.cer", ca_certs="certs/ca_local_0.cer")
    httpServerLib.start_http_endpoint(2224, DmaapSetup)
    while 1:
        time.sleep(10)


if __name__ == '__main__':
    _main_()
