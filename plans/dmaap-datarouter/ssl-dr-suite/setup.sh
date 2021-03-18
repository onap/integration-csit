#!/bin/bash
# ============LICENSE_START===================================================
#  Copyright (C) 2019-2021 Nordix Foundation.
# ============================================================================
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
# ============LICENSE_END=====================================================

source ${WORKSPACE}/scripts/dmaap-datarouter/datarouter-launch.sh
# Launch DR. If true is passed, 2 subscriber containers are also deployed, else false.
dmaap_dr_launch true
cd ${WORKSPACE}/scripts/dmaap-datarouter/robot_ssl
# Add the root CA to robot framework. This is then removed on teardown.
python -c 'import update_ca; update_ca.add_onap_ca_cert()'