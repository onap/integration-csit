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


#
# add here below the killing of all docker containers used for optf/has CSIT testing
#

#
# optf/has scripts docker containers killing";
#
echo "# optf/has has scripts calling";
source ${WORKSPACE}/scripts/optf-has/has/has_teardown_script.sh

echo "# optf/has simulator scripts calling";
source ${WORKSPACE}/scripts/optf-has/has/simulator_teardown_script.sh

echo "# optf/has music scripts calling";
source ${WORKSPACE}/scripts/optf-has/has/music_teardown_script.sh

