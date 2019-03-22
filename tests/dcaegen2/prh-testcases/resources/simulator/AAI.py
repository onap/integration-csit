import logging
import re
import sys
import time
from http.server import BaseHTTPRequestHandler

import httpServerLib
import json

pnfs = 'Empty'

ch = logging.StreamHandler(sys.stdout)
handlers = [ch]
logging.basicConfig(
    level=logging.DEBUG,
    format='[%(asctime)s] {%(filename)s:%(lineno)d} %(levelname)s - %(message)s',
    handlers=handlers
)

logger = logging.getLogger('LOGGER_NAME')


class AAISetup(BaseHTTPRequestHandler):

  def do_PUT(self):
    logger.info('PUT execution')
    if re.search('/set_pnfs', self.path):
      global pnfs

      pnfsFromRequest = None
      pnfAsJson = None
      try:
        content_length = int(self.headers['Content-Length'])
        pnfsFromRequest = self.rfile.read(content_length).decode('utf-8')
        logger.info('Received request %s ',pnfsFromRequest)
        #logger.info('Attempt to convert request to string')
        #pnfsFromRequestAsStr = str(pnfsFromRequest)
        #logger.info('Attempt to convert request to string doine with success')

        #ogger.info('Attempt tp creat JSON from request %s ',pnfsFromRequestAsStr)
        #pnfAsJson = json.loads(pnfsFromRequest)
        #logger.info('Reading JSON %s', pnfAsJson)
        #for key, value in pnfAsJson.items():
        #  pnfs = value
        #logger.info('PUT execution status 200')
        logger.info('pnfs %s', pnfs)
        httpServerLib.header_200_and_json(self)
      except:
        logger.info('Problems in parsing input for PUT')
        logger.info('pnfsFromRequest %s', pnfsFromRequest)
        logger.info('pnfAsJson %s', pnfAsJson)
        httpServerLib.header_400_and_json(self)

    return

  def do_POST(self):
    logger.info('POST')
    if re.search('/reset', self.path):
      global pnfs
      pnfs = 'Empty'
      httpServerLib.header_200_and_json(self)

    return


class AAIHandler(BaseHTTPRequestHandler):

  def do_PATCH(self):

    try:
      logger.info('PATCH execution')
      logger.info('self.path %s', self.path)
      logger.info('pnfs %s', pnfs)
      pnfs_name = '/aai/v12/network/pnfs/pnf/' + pnfs
      logger.info('pnfs_name %s', pnfs_name)

      if re.search('wrong_aai_record', self.path):
        self.send_response(400)
        self.end_headers()
        logger.info('PATCH execution 400')
      elif re.search(pnfs_name, self.path):
        self.send_response(200)
        self.end_headers()
        logger.info('PATCH execution 200')
      else:
        logger.info('PATCH execution unknown ')

    except:
      logger.info('Patch something went wrong')

    return


def _main_(handler_class=AAIHandler, protocol="HTTP/1.0"):
  logger.info('Main started')
  handler_class.protocol_version = protocol
  httpServerLib.start_http_endpoint(3333, AAIHandler)
  httpServerLib.start_https_endpoint(3334, AAIHandler,
                                     keyfile="certs/org.onap.aai.key",
                                     certfile="certs/aai_aai.onap.org.cer",
                                     ca_certs="certs/ca_local_0.cer")
  httpServerLib.start_http_endpoint(3335, AAISetup)
  logger.info('Main looping')
  while 1:
    time.sleep(10)


if __name__ == '__main__':
  _main_()
