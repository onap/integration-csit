#!/bin/bash

#  ============LICENSE_START===============================================
#  Copyright (C) 2020 Nordix Foundation. All rights reserved.
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

git clone "https://gerrit.o-ran-sc.org/r/nonrtric" -b cherry

AUTOTEST_ROOT=$WORKSPACE/archives/nonrtric/test/auto-test
POLMAN_PLANS=$WORKSPACE/plans/ccsdk-oran/polmansuite

#Copy test script, adapted to ONAP images
cp $POLMAN_PLANS/FTC1.sh $WORKSPACE/archives/nonrtric/test/auto-test/FTC1.sh
cp $POLMAN_PLANS/FTC150.sh $WORKSPACE/archives/nonrtric/test/auto-test/FTC150.sh

TEST_ENV=$POLMAN_PLANS/test_env-${GERRIT_BRANCH}.sh

#Make the env vars availble to the robot scripts
ROBOT_VARIABLES="-b debug.log -v AUTOTEST_ROOT:${AUTOTEST_ROOT} -v TEST_ENV:${TEST_ENV}"

