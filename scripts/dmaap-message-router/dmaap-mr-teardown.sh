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
# Modifications copyright (c) 2018 AT&T Intellectual Property
#

function dmaap_mr_teardown() {
#
# the default prefix for docker containers is the directory name containing the docker-compose.yml file.
# It can be over-written by an env variable COMPOSE_PROJECT_NAME.  This env var seems to be set in the Jenkins CSIT environment
COMPOSE_PREFIX=${COMPOSE_PROJECT_NAME:-dockercompose}
COMPOSE_PROJECT_NAME=$COMPOSE_PREFIX
echo "COMPOSE_PROJECT_NAME=$COMPOSE_PROJECT_NAME"
echo "COMPOSE_PREFIX=$COMPOSE_PREFIX"
kill-instance.sh ${COMPOSE_PREFIX}_dmaap_1 
kill-instance.sh ${COMPOSE_PREFIX}_kafka_1 
kill-instance.sh ${COMPOSE_PREFIX}_zookeeper_1
}
