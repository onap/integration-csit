#!/bin/bash
#
# Copyright 2016-2017 Huawei Technologies Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Place the scripts in run order:
source ${WORKSPACE}/scripts/ccsdk/script1.sh

# CLI internet speed test
curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -

# Test download a 100 MB file to check network speed to nexus.onap.org
wget -O /dev/null https://nexus.onap.org/content/repositories/releases/org/onap/appc/appc-dg-shared-installer/1.3.0/appc-dg-shared-installer-1.3.0.zip

# Test download a 100 MB file to check network speed to nexus3.onap.org
wget -O /dev/null https://nexus3.onap.org/repository/docker.release/v2/-/blobs/sha256:04dc4b8163487bb1c40df1ce16f349b507c262d6e2f202baa2e66a42eb8c64a1

