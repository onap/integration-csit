import logging
import json
import sys
import re
import time
from http.server import BaseHTTPRequestHandler
from os.path import basename
import httpServerLib

ch = logging.StreamHandler(sys.stdout)
handlers = [ch]
logging.basicConfig(
    level=logging.DEBUG,
    format='[%(asctime)s] {%(filename)s:%(lineno)d} %(levelname)s - %(message)s',
    handlers=handlers
)

logger = logging.getLogger('AAI-simulator-logger')

AAI_RESOURCE_NOT_FOUND = b'{}'

pnf_entries = {}
patched_pnf = AAI_RESOURCE_NOT_FOUND
created_logical_link = AAI_RESOURCE_NOT_FOUND
service_instance = AAI_RESOURCE_NOT_FOUND

class AAISetup(BaseHTTPRequestHandler):

    def do_GET(self):
        try:
            if re.search('/setup/patched_pnf', self.path):
                httpServerLib.set_response_200_ok(self, payload = patched_pnf)
                logger.debug('AAISetup GET /setup/patched_pnf -> 200 OK')
            elif re.search('/verify/created_logical_link', self.path):
                httpServerLib.set_response_200_ok(self, payload = created_logical_link)
                logger.debug('AAISetup GET /setup/created_logical_link -> 200 OK')
            else:
                httpServerLib.set_response_404_not_found(self)
                logger.info('AAISetup GET ' + self.path + ' -> 404 Not found')
        except Exception as e:
            logger.error(e)
            httpServerLib.set_response_500_server_error(self)

    def do_PUT(self):
        try:
            if re.search('/setup/add_pnf_entry', self.path):
                pnf_entry = httpServerLib.get_payload(self)
                pnf_name = json.loads(pnf_entry).get("pnf-name")
                if pnf_name == None:
                    raise Exception("Invalid PNF entry, could not extract `pnf-name`")

                global pnf_entries
                pnf_entries[pnf_name] = pnf_entry

                httpServerLib.set_response_200_ok(self)
                logger.debug('AAISetup PUT /setup/add_pnf_entry [' + pnf_name + '] -> 200 OK')
            elif re.search('/setup/add_service_instace', self.path):
                service_instance_payload = httpServerLib.get_payload(self)
                global service_instance
                service_instance = json.loads(service_instance_payload)
                httpServerLib.set_response_200_ok(self)
                logger.debug('AAISetup PUT /setup/add_service_instace -> 200 OK')

            elif re.search('/set_pnf', self.path):
                pnf_name = httpServerLib.get_payload(self).decode()
                pnf_entries[pnf_name] = AAI_RESOURCE_NOT_FOUND
                httpServerLib.set_response_200_ok(self)
            else:
                httpServerLib.set_response_404_not_found(self)
                logger.info('AAISetup PUT ' + self.path + ' -> 404 Not found')
        except Exception as e:
            logger.error(e)
            httpServerLib.set_response_500_server_error(self)

    def do_POST(self):
        try:
            if re.search('/reset', self.path):
                global pnf_entries
                global patched_pnf
                global created_logical_link
                global service_instance
                pnf_entries = {}
                patched_pnf = AAI_RESOURCE_NOT_FOUND
                created_logical_link = AAI_RESOURCE_NOT_FOUND
                service_instance = AAI_RESOURCE_NOT_FOUND

                httpServerLib.set_response_200_ok(self)
                logger.debug('AAISetup POST /reset -> 200 OK')
            else:
                httpServerLib.set_response_404_not_found(self)
                logger.info('AAISetup POST ' + self.path + ' -> 404 Not found')
        except Exception as e:
            logger.error(e)
            httpServerLib.set_response_500_server_error(self)

class AAIHandler(BaseHTTPRequestHandler):

    def do_GET(self):
        try:
            if re.search('/aai/v12/network/pnfs/pnf/[^/]*$', self.path):
                pnf_name = basename(self.path)

                if re.search('/aai/v12/network/pnfs/pnf/business/customers/customer/service-subscriptions/service-subscription/service-instances/service-instance/', self.path):
                    httpServerLib.set_response_200_ok(self, payload = service_instance)
                    logger.debug('AAIHandler GET /aai/v12/network/pnfs/pnf/business/customers/customer/service-subscriptions/service-subscription/service-instances/service-instance/ -> 200 OK')

                elif pnf_name in pnf_entries:
                    httpServerLib.set_response_200_ok(self, payload = pnf_entries[pnf_name])
                    logger.debug('AAIHandler GET /aai/v12/network/pnfs/pnf/' + pnf_name + ' -> 200 OK')
                else:
                    httpServerLib.set_response_404_not_found(self)
                    logger.info('AAIHandler GET /aai/v12/network/pnfs/pnf/' + pnf_name + ' -> 404 Not found, actual entries: ' + str(pnf_entries.keys()))
             else:
                httpServerLib.set_response_404_not_found(self)
                logger.info('AAIHandler GET ' + self.path + ' -> 404 Not found')
        except Exception as e:
            logger.error(e)
            httpServerLib.set_response_500_server_error(self)

    def do_PATCH(self):
        try:
            if re.search('/aai/v12/network/pnfs/pnf/[^/]*$', self.path):
                pnf_name = basename(self.path)
                if pnf_name in pnf_entries:
                    global patched_pnf
                    patched_pnf = httpServerLib.get_payload(self)

                    httpServerLib.set_response_200_ok(self)
                    logger.debug('AAIHandler PATCH /aai/v12/network/pnfs/pnf/' + pnf_name + ' -> 200 OK')
                else:
                    httpServerLib.set_response_404_not_found(self)
                    logger.info('AAIHandler PATCH /aai/v12/network/pnfs/pnf/' + pnf_name + ' -> 404 Not found, actual entries: ' + str(pnf_entries.keys()))
            else:
                httpServerLib.set_response_404_not_found(self)
                logger.info('AAIHandler PATCH ' + self.path + ' -> 404 Not found')
        except Exception as e:
            logger.error(e)
            httpServerLib.set_response_500_server_error(self)

    def do_PUT(self):
        try:
            if re.search('/aai/v12/network/logical-links/logical-link/[^/]*$', self.path):
                global created_logical_link
                created_logical_link = httpServerLib.get_payload(self)

                httpServerLib.set_response_200_ok(self)

                logical_link_name = basename(self.path)
                logger.debug('AAIHandler PUT /aai/v12/network/logical-links/logical-link/' + logical_link_name + ' -> 200 OK')
            else:
                httpServerLib.set_response_404_not_found(self)
                logger.info('AAIHandler PUT ' + self.path + ' -> 404 Not found')
        except Exception as e:
            logger.error(e)
            httpServerLib.set_response_500_server_error(self)


def _main_(handler_class=AAIHandler, protocol="HTTP/1.0"):
    handler_class.protocol_version = protocol
    httpServerLib.start_https_endpoint(3334, AAIHandler, keyfile="certs/aai.key", certfile="certs/aai.crt", ca_certs="certs/root.crt")
    httpServerLib.start_http_endpoint(3335, AAISetup)
    while 1:
        time.sleep(10)


if __name__ == '__main__':
    _main_()