#!/bin/bash
#
# ============LICENSE_START=======================================================
#  Copyright (C) 2019 Nordix Foundation.
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

cd $WORKSPACE/archives/dmaapdr/datarouter/datarouter-docker-compose/src/main/resources
sudo sed -i".bak" '/dmaap-dr-prov/d' /etc/hosts
sudo sed -i".bak" '/dmaap-dr-node/d' /etc/hosts
docker-compose rm -sf
python -c 'import update_ca; update_ca.remove_onap_ca_cert()'
