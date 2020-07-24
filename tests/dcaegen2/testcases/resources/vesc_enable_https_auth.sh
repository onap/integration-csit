#!/bin/bash
#
# Copyright 2016-2017 Huawei Technologies Co., Ltd.
# Copyright 2020 Nokia
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

docker cp ${WORKSPACE}/tests/dcaegen2/testcases/resources/collector.properties vesc:/opt/app/VESCollector/etc
docker restart vesc
echo "VES Collector Restarted with certBasicAuth"
