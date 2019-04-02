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
import requests
from robot.api import logger

valid_status_codes = [
    requests.codes.ok,
    requests.codes.accepted
]


def session_without_env():
    session = requests.Session()
    session.trust_env = False
    return session


def checkStatusCode(status_code, server_name):
    if status_code not in valid_status_codes:
        logger.error("Response status code from " + server_name + ": " + str(status_code))
        raise (Exception(server_name + " returned status code " + str(status_code)))
