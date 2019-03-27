import re
import time
from http.server import BaseHTTPRequestHandler
import httpServerLib

import json

pnfs = []
services = []
pnf_not_found = '[{}]'

class AAISetup(BaseHTTPRequestHandler):

    def do_PUT(self):
        global pnfs
        global services
        global pnf_not_found
        if re.search('/set_pnfs', self.path):
            content_length = int(self.headers['Content-Length'])
            pnfs = self.rfile.read(content_length)
            pnfs = pnfs.decode()
            httpServerLib.header_200_and_json(self)
        elif re.search('/set_services', self.path):
            content_length = int(self.headers['Content-Length'])
            services = self.rfile.read(content_length)
            services = services.decode()
            httpServerLib.header_200_and_json(self)
        elif re.search('/set_pnf_not_found', self.path):
            content_length = int(self.headers['Content-Length'])
            pnf_not_found = self.rfile.read(content_length)
            pnf_not_found = pnf_not_found.decode()
            httpServerLib.header_200_and_json(self)

        return

    def do_POST(self):
        if re.search('/reset', self.path):
            httpServerLib.header_200_and_json(self)

        return


class AAIHandler(BaseHTTPRequestHandler):

    def do_GET(self):
        global pnfs
        global services
        global pnf_not_found
        pnf_path = '/aai/v14/network/pnfs/pnf/'
        service_path = '/aai/v14/nodes/service-instances/service-instance/'
        found_resource = None
        if re.search(pnf_path, self.path):
            try:
                python_pnfs = json.loads(pnfs)
            except AttributeError:
                python_pnfs = []
            for pnf_instance in python_pnfs:
                try:
                    pnf_name = pnf_path + pnf_instance.get("pnf-name")
                except AttributeError:
                    pnf_name = "PNF not found"
                if re.search(pnf_name, self.path):
                    found_resource = pnf_instance
                    break
        elif re.search(service_path, self.path):
            try:
                python_services = json.loads(services)
            except AttributeError:
                python_services = []
            for service_instance in python_services:
                try:
                    service_name = service_path + service_instance.get("service-instance-id")
                except AttributeError:
                    pnf_name = "Service not found"
                if re.search(service_name, self.path):
                    found_resource = service_instance
                    break

        if found_resource is not None:
            # Prepare the response for DMaaP (byte encoded JSON Object)
            found_resource = json.dumps(found_resource)
            found_resource = found_resource.encode()
            httpServerLib.header_200_and_json(self)
            self.wfile.write(found_resource)
        else:
            # Send a 404 message for not found
            pnf_resp = pnf_not_found
            # We have to replace the request line data
            err_pnf_template = "nodes/pnfs/pnf/Wrong-PNF-Name"
            pnf_resp = pnf_resp.replace(err_pnf_template, self.path)
            pnf_resp = pnf_resp.encode()
            httpServerLib.header_404_and_json(self)
            self.wfile.write(pnf_resp)

            
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
