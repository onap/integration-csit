#!/bin/bash
#
# ============LICENSE_START=======================================================
# ONAP CLAMP
# ================================================================================
# Copyright (C) 2017 AT&T Intellectual Property. All rights
#                             reserved.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============LICENSE_END============================================
# ===================================================================
# ECOMP is a trademark and service mark of AT&T Intellectual Property.
#

echo "VVP-Engagement-Manager health-Check:"
echo ""
echo ""
res=`curl -s -X GET -H "Accept: application/json" -H "Content-Type: application/json" "http://localhost:9090/vvp/v1/engmgr/vendors" | wc -w`
if [ ${res} == 0 ]; then
    echo "Error [${res}] while performing vvp engagement manager vendor existance check"
    exit 1
fi
echo "check vvp engagement manager vendor existance: OK [${res}]"
