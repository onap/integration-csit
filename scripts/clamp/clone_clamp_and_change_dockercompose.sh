#!/bin/bash
#
# ============LICENSE_START=======================================================
# ONAP CLAMP
# ================================================================================
# Copyright (C) 2017 AT&T Intellectual Property. All rights
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

echo "This is ${WORKSPACE}/scripts/clamp/clone_clamp_and_change_dockercompose.sh"

firefox --version
which firefox


# Clone Clamp repo to get extra folder that has all needed to run docker with docker-compose to start DB and Clamp
mkdir -p $WORKSPACE/archives/clamp-clone
cd $WORKSPACE/archives/clamp-clone
git clone --depth 1 http://gerrit.onap.org/r/clamp -b $GERRIT_BRANCH
cd clamp/extra/docker/clamp/

# Pull the Clamp docker image from nexus instead of local image by default in the docker-compose.yml
sed -i '/image: onap\/clamp-backend/c\    image: nexus3.onap.org:10001\/onap\/clamp-backend:4.1-STAGING-latest' docker-compose.yml

# Add the sql to create template so it is played by docker-compose later
cp ../../../src/test/resources/sql/loop-examples.sql ../../sql/bulkload/
echo 'mysql -uroot -p$MYSQL_ROOT_PASSWORD -f < loop-examples.sql' >> ../../sql/load-sql-files-tests-automation.sh
