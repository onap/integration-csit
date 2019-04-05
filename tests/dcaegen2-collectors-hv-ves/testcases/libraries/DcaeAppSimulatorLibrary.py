# ============LICENSE_START=======================================================
# csit-dcaegen2-collectors-hv-ves
# ================================================================================
# Copyright (C) 2018-2019 NOKIA
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
import HttpRequests
from VesHvContainersUtilsLibrary import VesHvContainersUtilsLibrary
from robot.api import logger
import json

DCAE_APP_NAME = "DCAE App Simulator"

DCAE_APP_HOST = "dcae-app-simulator"
DCAE_APP_PORT = "6063"
DCAE_APP_ADDRESS = VesHvContainersUtilsLibrary().get_dcae_app_api_access_url("http://", DCAE_APP_HOST, DCAE_APP_PORT)

TOPIC_CONFIGURATION_PATH = DCAE_APP_ADDRESS + "/configuration/topics"

MESSAGES_PATH = "/messages/%s"
MESSAGES_RESET_PATH = DCAE_APP_ADDRESS + MESSAGES_PATH
MESSAGES_COUNT_PATH = DCAE_APP_ADDRESS + MESSAGES_PATH + "/count"
MESSAGES_VALIDATION_PATH = DCAE_APP_ADDRESS + MESSAGES_PATH + "/validate"


class DcaeAppSimulatorLibrary:

    def configure_dcae_app_simulator_to_consume_messages_from_topics(self, topics):
        app_url = TOPIC_CONFIGURATION_PATH
        logger.info("PUT " + str(topics) + " at: " + app_url)
        resp = HttpRequests.session_without_env().put(app_url, data=self.not_escaped(topics), timeout=10)
        HttpRequests.checkStatusCode(resp.status_code, DCAE_APP_NAME)

    def not_escaped(self, data):
        return json.dumps(data)

    def assert_DCAE_app_consumed(self, topic, expected_messages_amount):
        app_url = MESSAGES_COUNT_PATH % topic
        logger.info("GET at: " + app_url)
        resp = HttpRequests.session_without_env().get(app_url, timeout=10)
        HttpRequests.checkStatusCode(resp.status_code, DCAE_APP_NAME)

        assert int(resp.content) == int(expected_messages_amount), \
            "Messages consumed by simulator: " + str(resp.content) + " expecting: " + str(expected_messages_amount)

    def reset_DCAE_app_simulator(self, topic):
        app_url = MESSAGES_RESET_PATH % topic
        logger.info("DELETE at: " + app_url)
        resp = HttpRequests.session_without_env().delete(app_url, timeout=10)
        HttpRequests.checkStatusCode(resp.status_code, DCAE_APP_NAME)

    def assert_DCAE_app_consumed_proper_messages(self, topic, message_filepath):
        app_url = MESSAGES_VALIDATION_PATH % topic
        file = open(message_filepath, "rb")
        data = file.read()
        file.close()
        logger.info("POST " + str(data) + "at: " + app_url)

        resp = HttpRequests.session_without_env().post(app_url, data=data, timeout=10)
        HttpRequests.checkStatusCode(resp.status_code, DCAE_APP_NAME)
