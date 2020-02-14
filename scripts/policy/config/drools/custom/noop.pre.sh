#!/bin/bash -x
# ============LICENSE_START=======================================================
# Copyright (C) 2020 AT&T Intellectual Property. All rights reserved.
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
# ============LICENSE_END=========================================================

sed -i "s/^dmaap/noop/g" \
    ${POLICY_HOME}/config/engine.properties \
    ${POLICY_HOME}/config/feature-lifecycle.properties

chmod 644 ${POLICY_HOME}/config/engine.properties ${POLICY_HOME}/config/feature-lifecycle.properties
