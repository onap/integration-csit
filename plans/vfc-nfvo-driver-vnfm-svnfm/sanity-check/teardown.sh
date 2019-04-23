#!/bin/bash
#
# Copyright 2017 Huawei Technologies Co., Ltd.
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

# print log for ztevnfmdriver
docker cp vfc-ztevnfmdriver:/service/vfc/nfvo/driver/vnfm/svnfm/zte/vmanager/logs/runtime_ztevnfmdriver.log ./
cat runtime_ztevnfmdriver.log

# This script is sourced by run-csit.sh after Robot test completion.
kill-instance.sh msb_internal_apigateway
kill-instance.sh msb_discovery
kill-instance.sh msb_consul
kill-instance.sh  vfc-ztevnfmdriver

kill-instance.sh vfc-svnfm-huawei
