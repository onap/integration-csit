# ============LICENSE_START=======================================================
#  Copyright (C) 2023 Nordix Foundation.
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
#
# SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================
#
# @author Waqas Ikram (waqas.ikram@est.tech)

from robot.api import logger
from kubernetes import client, config
from robot.api.deco import library


@library(scope="GLOBAL", auto_keywords=True)
class KubernetesClient:
    def __init__(self):
        self.api_client = None

    def create_api_client(self, config_file):
        logger.console("Initializing api client ..")
        self.api_client = config.new_client_from_config(config_file)

    def get_number_of_stateful_set_in_namespace(self, namespace="default", label_selector=""):
        self.check_if_api_client_is_initialized()
        api_client = client.AppsV1Api(api_client=self.api_client)
        result = api_client.list_namespaced_stateful_set(namespace, watch=False, label_selector=label_selector)
        if result.items is None:
            return 0
        return len(result.items)

    def get_number_of_services_in_namespace(self, namespace="default", label_selector=""):
        self.check_if_api_client_is_initialized()
        api_client = client.CoreV1Api(api_client=self.api_client)
        result = api_client.list_namespaced_service(namespace, watch=False, label_selector=label_selector)
        if result.items is None:
            return 0
        return len(result.items)

    def get_number_of_deployments_in_namespace(self, namespace="default", label_selector=""):
        self.check_if_api_client_is_initialized()
        api_client = client.AppsV1Api(api_client=self.api_client)
        result = api_client.list_namespaced_deployment(namespace, watch=False, label_selector=label_selector)
        if result.items is None:
            return 0
        return len(result.items)

    def check_if_api_client_is_initialized(self):
        if self.api_client is None:
            raise TypeError("'api_client' is null")
