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
from robot.api import logger
import HttpRequests

CONSUL_NAME = "Consul"

class ConsulLibrary:

    def publish_hv_ves_configuration_in_consul(self, consul_url, consul_configuration_filepath):
        logger.info("Reading consul configuration file from: " + consul_configuration_filepath)
        file = open(consul_configuration_filepath, "rb")
        data = file.read()
        file.close()

        logger.info("PUT at: " + consul_url)
        resp = HttpRequests.session_without_env().put(consul_url, data=data, timeout=5)
        HttpRequests.checkStatusCode(resp.status_code, CONSUL_NAME)