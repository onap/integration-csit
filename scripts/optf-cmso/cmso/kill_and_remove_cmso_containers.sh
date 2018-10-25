#!/bin/bash
#
# ============LICENSE_START=======================================================
# ONAP CMSO
# ================================================================================
# Copyright (C) 2018 AT&T Intellectual Property. All rights
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

echo "This is ${WORKSPACE}/scripts/optf-cmso/cmso/kill_and_remove_dataFolder.sh"

kill-instance.sh cmso-service
kill-instance.sh cmso-mariadb
kill-instance.sh cmso-db-init

#delete cmso-clone folder

rm -rf ${WORKSPACE}archives/cmso-clone


