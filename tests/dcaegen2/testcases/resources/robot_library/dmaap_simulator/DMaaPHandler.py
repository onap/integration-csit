'''
Created on Aug 15, 2017

@author: sw6830
'''
import os
import posixpath
import BaseHTTPServer
import urllib
import urlparse
import cgi
import sys
import shutil
import mimetypes
from robot_library import DcaeVariables

try:
    from cStringIO import StringIO
except ImportError:
    from StringIO import StringIO


class DMaaPHandler(BaseHTTPServer.BaseHTTPRequestHandler):

    def __init__(self, dmaap_simulator, *args):
        self.dmaap_simulator = dmaap_simulator
        BaseHTTPServer.BaseHTTPRequestHandler.__init__(self, *args)

    def do_POST(self):
        if 'POST' not in self.requestline:
            resp_code = 405
        else:
            resp_code = self.parse_the_posted_data()

        if resp_code == 0:
            self.send_successful_response()
        else:
            self.send_response(resp_code)

    def parse_the_posted_data(self):
        topic = self.extract_topic_from_path()
        content_len = self.get_content_length()
        post_body = self.rfile.read(content_len)
        post_body = self.get_json_part_of_post_body(post_body)
        event = "{\"" + topic + "\":" + post_body + "}"
        if self.dmaap_simulator.enque_event(event):
            resp_code = 0
        else:
            print "enque event fails"
            resp_code = 500
        return resp_code

    def get_json_part_of_post_body(self, post_body):
        indx = post_body.index("{")
        if indx != 0:
            post_body = post_body[indx:]
        return post_body

    def extract_topic_from_path(self):
        return self.path["/events/".__len__():]

    def get_content_length(self):
        return int(self.headers.getheader('content-length', 0))

    def send_successful_response(self):
        if 'clientThrottlingState' in self.requestline:
            self.send_response(204)
        else:
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write("{'count': 1, 'serverTimeMs': 3}")
            self.wfile.close()
