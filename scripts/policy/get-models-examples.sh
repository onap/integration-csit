#!/bin/bash
#
# ============LICENSE_START===================================================
#  Copyright (C) 2020 AT&T Intellectual Property. All rights reserved.
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
# ============LICENSE_END=====================================================
#

source ${SCRIPTS}/policy/config/policy-csit.conf

rm -rf ${WORKSPACE}/models
mkdir ${WORKSPACE}/models
cd ${WORKSPACE}

# download models examples
git clone --depth 1 https://gerrit.onap.org/r/policy/models -b ${GERRIT_BRANCH}
