#!/bin/bash
#
# ============LICENSE_START=======================================================
#  Copyright (C) 2021 Nordix Foundation.
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

# @author Waqas Ikram (waqas.ikram@est.tech)

SCRIPT_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPT_NAME=$(basename $0)
CONFIG_DIR=$SCRIPT_HOME/config
ENV_FILE=$CONFIG_DIR/env
DOCKER_COMPOSE_FILE_PATH=$SCRIPT_HOME/docker-compose.yml

echo "Running $SCRIPT_HOME/$SCRIPT_NAME ..."
export $(egrep -v '^#' $ENV_FILE | xargs)

echo "Tearing down docker containers ..."
docker-compose -f $DOCKER_COMPOSE_FILE_PATH -p $PROJECT_NAME down
echo "Finished executing $SCRIPT_HOME/$SCRIPT_NAME"
