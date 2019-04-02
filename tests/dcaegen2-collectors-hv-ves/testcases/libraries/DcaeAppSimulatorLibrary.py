# ============LICENSE_START=======================================================
# csit-dcaegen2-collectors-hv-ves
# ================================================================================
# Copyright (C) 2018 NOKIA
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
from robot.api import logger

DCAE_APP_NAME = "DCAE App"


class DcaeAppSimulatorLibrary:

    def configure_dcae_app_simulator_to_consume_messages_from_topics(self, app_url, topics):
        data = {'topics': topics}
        logger.info("PUT " + str(data) +  " at: " + app_url)
        resp = HttpRequests.session_without_env().put(app_url, data=data, timeout=10)
        HttpRequests.checkStatusCode(resp.status_code, DCAE_APP_NAME)

    def assert_DCAE_app_consumed(self, app_url, expected_messages_amount):
        logger.info("GET at: " + app_url)
        resp = HttpRequests.session_without_env().get(app_url, timeout=10)
        HttpRequests.checkStatusCode(resp.status_code, DCAE_APP_NAME)

        assert int(resp.content) == int(expected_messages_amount), \
            "Messages consumed by simulator: " + str(resp.content) + " expecting: " + str(expected_messages_amount)

    def assert_DCAE_app_consumed_less_equal_than(self, app_url, messages_threshold):
        logger.info("GET at: " + app_url)
        resp = HttpRequests.session_without_env().get(app_url, timeout=10)
        HttpRequests.checkStatusCode(resp.status_code, DCAE_APP_NAME)

        logger.debug("Messages consumed by simulator: " + resp.content +
                     " expecting more than 0 and less/equal than " + messages_threshold)

        assert 0 < int(resp.content) <= int(messages_threshold), \
            "Messages consumed by simulator: " + str(resp.content) + \
            " expecting more than 0 and less/equal than " + str(messages_threshold)

    def reset_DCAE_app_simulator(self, app_url):
        logger.info("DELETE at: " + app_url)
        resp = HttpRequests.session_without_env().delete(app_url, timeout=10)
        HttpRequests.checkStatusCode(resp.status_code, DCAE_APP_NAME)

    def assert_DCAE_app_consumed_proper_messages(self, app_url, message_filepath):
        logger.info("POST at: " + app_url)
        file = open(message_filepath, "rb")
        data = file.read()
        file.close()

        resp = HttpRequests.session_without_env().post(app_url, data=data, timeout=10)
        HttpRequests.checkStatusCode(resp.status_code, DCAE_APP_NAME)
