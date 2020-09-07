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

git clone "https://gerrit.o-ran-sc.org/r/nonrtric"

# Fix ownership. Mounted resources to consul changes ownership which prevents csit test cleanup
cd nonrtric/test/simulator-group/
sudo chown $(id -u):$(id -g) consul_cbs
sudo chown $(id -u):$(id -g) consul_cbs/consul/

AUTOTEST_ROOT=$WORKSPACE/archives/nonrtric/test/auto-test

# Temporary solution to setup the Non-RT RIC components to point to ONAP images and tags
# Shall be removed when the Non-RT RIC test env is moved/copied to ONAP
cp $WORKSPACE/plans/ccsdk-oran/polmansuite/test_env.sh $WORKSPACE/archives/nonrtric/test/common

# Temporary solution to not test with the SDNC image
cp $WORKSPACE/plans/ccsdk-oran/polmansuite/FTC1.sh $WORKSPACE/archives/nonrtric/test/auto-test/FTC1.sh

#Make the env vars availble to the robot scripts
ROBOT_VARIABLES="-b debug.log -v AUTOTEST_ROOT:${AUTOTEST_ROOT}"
