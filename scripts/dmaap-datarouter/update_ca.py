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

import certifi
import os

cafile = certifi.where()
dir_path = os.path.dirname(os.path.realpath(__file__))
datarouter_ca = dir_path + '/datarouterCA.crt'
with open(datarouter_ca, 'rb') as infile:
    customca = infile.read()

with open(cafile, 'ab') as outfile:
    outfile.write(customca)

print("Added DR Cert to CA")
