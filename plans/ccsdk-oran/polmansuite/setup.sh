#!/bin/bash

#  ============LICENSE_START===============================================
#  Copyright (C) 2021 Nordix Foundation. All rights reserved.
#  ========================================================================
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#  ============LICENSE_END=================================================


cd $WORKSPACE/archives

POLMAN_PLANS=$WORKSPACE/plans/ccsdk-oran/polmansuite
ARCHIVES=$WORKSPACE/archives

#Copy test script
cp $POLMAN_PLANS/docker-compose.yml $WORKSPACE/archives/docker-compose.yml
cp -rf $POLMAN_PLANS/config/ $WORKSPACE/archives/config/
cp -rf $POLMAN_PLANS/data/ $WORKSPACE/archives/data/
cp -rf $POLMAN_PLANS/test/ $WORKSPACE/archives/test/
cp -rf $POLMAN_PLANS/sdnc/ $WORKSPACE/archives/sdnc/

#Make the env vars availble to the robot scripts
ROBOT_VARIABLES="-b debug.log -v ARCHIVES:${ARCHIVES}"

