# ============LICENSE_START=======================================================
# INTEGRATION CSIT
# ================================================================================
# Copyright (C) 2018 Nokia Intellectual Property. All rights reserved.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============LICENSE_END=========================================================

import json
import logging
from functools import partial
from sys import argv
from http.server import BaseHTTPRequestHandler, HTTPServer

DEFAULT_PORT = 8443


class SOHandler(BaseHTTPRequestHandler):
    def __init__(self, expected_requests, expected_responses, requests, responses, *args, **kwargs):

        self._expected_requests = expected_requests
        self._expected_responses = expected_responses
        self._requests = requests["requests"]
        self._responses = responses["responses"]
        self._known_endpoints = self._get_known_endpoints()
        super().__init__(*args, **kwargs)

    def do_POST(self):
        logging.info(
            'POST called. Expected POST REQUEST: ' + json.dumps(
                self._expected_requests["post"]) + '\nExpected POST response: ' +
            json.dumps(self._expected_responses["post"]))
        self.send_response(200)
        self._set_headers()

        self.wfile.write(json.dumps(self._expected_responses["post"]).encode("utf-8"))
        return

    def do_GET(self):
        if self._does_path_exist_as_endpoint():
            expected_response = self._get_response_by_endpoint(self.path)
            if not expected_response:
                self.send_response(expected_response["responseCode"])
                self._set_headers()
                self.wfile.write(json.dumps(expected_response["body"]).encode("utf-8"))
            else:
                response_body = "{\"message:\" \"no response for endpoint\"}"
                self.send_response(400)
                self._set_headers()
                self.wfile.write(json.dumps(response_body).encode("utf-8"))
        else:
            logging.info('GET called. Expected GET REQUEST: '
                         + json.dumps(self._expected_requests["get"])
                         + '\nExpected GET response: '
                         + json.dumps(self._expected_responses["get"]))
            self.send_response(200)
            self._set_headers()
            self.wfile.write(json.dumps(self._expected_responses["get"]).encode("utf-8"))

    def do_PUT(self):
        request_body_json = self._get_request_body()
        if request_body_json is not None:
            self._apply_expected_data(request_body_json)
            logging.info("EXPECTED RESPONSES: " + str(self._expected_responses))
            logging.info("EXPECTED REQUESTS: " + str(self._expected_requests))
            response_status = 200
        else:
            response_status = 400
        self.send_response(response_status)
        self._set_headers()

    def _get_request_body(self):
        content_len = int(self.headers['Content-Length'], 0)
        parsed_req_body = None
        if content_len > 0:
            body = self.rfile.read(content_len)
            body_decoded = body.decode('utf8')
            logging.info("BODY: %s type: %s  body decoded: %s type: %s", str(body), type(body), str(body_decoded),
                         type(body_decoded))
            parsed_req_body = json.loads(body_decoded)
        return parsed_req_body

    def _apply_expected_data(self, request_body_json):
        if self.path == '/setResponse':
            logging.info("IN PUT /setResponse: " + str(request_body_json))
            self._expected_responses.update(request_body_json)
        elif self.path == '/setRequest':
            logging.info("IN PUT /setRequest: " + str(request_body_json))
            self._expected_requests.update(request_body_json)

    def _set_headers(self):
        self.send_header('Content-Type', 'application/json')
        self.end_headers()

    def _get_response_by_endpoint(self, endpoint):
        for response in self._responses:
            if response["path"] == endpoint:
                return response

    def _does_path_exist_as_endpoint(self):
        does_exist = False
        for ep in self._known_endpoints:
            if ep == self.path:
                does_exist = True
                break
        return does_exist

    def _create_path_from_request(self, request):
        base_uri = request["path"]
        query_params = request["queryParams"]
        final_path = base_uri
        if query_params:
            final_path += '?'
            final_path = self._add_query_params_to_path(final_path, query_params)
        return final_path

    def _get_known_endpoints(self):
        endpoints = []
        for request in self._requests:
            endpoints.append(self._create_path_from_request(request))
        return endpoints

    @staticmethod
    def _add_query_params_to_path(base_uri, query_params):
        expected_uri = base_uri
        for param in query_params:
            expected_uri += param + '=' + query_params.get(param, '') + '&'
        expected_uri = expected_uri[:-1]
        return expected_uri


class JsonFileToDictReader(object):

    @staticmethod
    def read_expected_test_data(expected_responses_filename):
        with open(expected_responses_filename, 'r') as file:
            return json.load(file)


def init_so_simulator():
    requests = JsonFileToDictReader.read_expected_test_data("test_data_assets/requests.json")
    responses = JsonFileToDictReader.read_expected_test_data("test_data_assets/responses.json")

    expected_so_requests = JsonFileToDictReader.read_expected_test_data(argv[1])
    expected_so_responses = JsonFileToDictReader.read_expected_test_data(argv[2])
    logging.basicConfig(level=logging.INFO)
    handler = partial(SOHandler, expected_so_requests, expected_so_responses, requests, responses)
    handler.protocol_version = "HTTP/1.0"
    httpd = HTTPServer(('', DEFAULT_PORT), handler)
    logging.info("serving on: " + str(httpd.socket.getsockname()))
    httpd.serve_forever()


if __name__ == '__main__':
    init_so_simulator()
