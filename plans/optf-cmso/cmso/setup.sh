#!/bin/bash
#
# -------------------------------------------------------------------------
#   Copyright (c) 2018 AT&T Intellectual Property
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
# -------------------------------------------------------------------------
#

#
# Place the scripts in run order:

source ${WORKSPACE}/scripts/optf-cmso/cmso/clone_cmso_and_change_dockercompose.sh

source ${WORKSPACE}/scripts/optf-cmso/cmso/start_cmso_containers.sh

# Pass any variables required by Robot test suites in ROBOT_VARIABLES
#ROBOT_VARIABLES="-v TEST:${TEST}"
