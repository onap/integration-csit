#!/bin/bash -x
#
# Copyright 2016-2017 Huawei Technologies Co., Ltd.
# Modification Copyright 2019 © Samsung Electronics Co., Ltd.
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
# $1 project/functionality
# $2 robot options

function docker_stats(){
    #General memory details
    echo "> top -bn1 | head -3"
    top -bn1 | head -3
    echo

    echo "> free -h"
    free -h
    echo

    #Memory details per Docker
    echo "> docker ps"
    docker ps
    echo

    echo "> docker stats --no-stream"
    docker stats --no-stream
    echo
}

if [ $# -eq 0 ]
then
    echo 
    echo "Usage: $0 plans/<project>/<functionality> [<robot-options>]"
    echo
    echo "    <project>, <functionality>, <robot-options>:  "
    echo "        The same values as for the '{project}-csit-{functionality}' JJB job template."
    echo
    exit 1
fi

if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi

rm -rf $WORKSPACE/archives
mkdir -p $WORKSPACE/archives

if [ -f ${WORKSPACE}/${1}/testplan.txt ]; then
    export TESTPLAN="${1}"
else
    echo "testplan not found: ${WORKSPACE}/${TESTPLAN}/testplan.txt"
    exit 2
fi

export TESTOPTIONS="${2}"

TESTPLANDIR=${WORKSPACE}/${TESTPLAN}

# Assume that if env.properties is set, installation prerequirements are fulfilled
# env.properties needs to be sourced for ROBOT_VENV
if [ -f ${WORKSPACE}/env.properties ]; then
    source ${WORKSPACE}/env.properties
else
    source ${WORKSPACE}/prepare-csit.sh
fi

WORKDIR=`mktemp -d --suffix=-robot-workdir`
cd ${WORKDIR}

set +u
set -x

# Add csit scripts to PATH
export PATH=${PATH}:${WORKSPACE}/docker/scripts:${WORKSPACE}/scripts:${ROBOT_VENV}/bin
export SCRIPTS=${WORKSPACE}/scripts
export ROBOT_VARIABLES=

# Sign in to nexus3 docker repo
docker login -u anonymous -p anonymous nexus3.onap.org:10001

# Run setup script plan if it exists
cd ${TESTPLANDIR}
SETUP=${TESTPLANDIR}/setup.sh
if [ -f ${SETUP} ]; then
    echo "Running setup script ${SETUP}"
    source ${SETUP}
fi

# show memory consumption after all docker instances initialized
docker_stats | tee $WORKSPACE/archives/_sysinfo-1-after-setup.txt

# Run test plan
cd $WORKDIR
echo "Reading the testplan:"
cat ${TESTPLANDIR}/testplan.txt | egrep -v '(^[[:space:]]*#|^[[:space:]]*$)' | sed "s|^|${WORKSPACE}/tests/|" > testplan.txt
cat testplan.txt
SUITES=$( xargs -a testplan.txt )

echo ROBOT_VARIABLES=${ROBOT_VARIABLES}
echo "Starting Robot test suites ${SUITES} ..."
set +e
python -m robot.run -N ${TESTPLAN} -v WORKSPACE:/tmp ${ROBOT_VARIABLES} ${TESTOPTIONS} ${SUITES}
RESULT=$?
set -e
echo "RESULT: " $RESULT
rsync -av $WORKDIR/ $WORKSPACE/archives

# Record list of active docker containers
docker ps --format "{{.Image}}" > $WORKSPACE/archives/_docker-images.log

# show memory consumption after all docker instances initialized
docker_stats | tee $WORKSPACE/archives/_sysinfo-2-after-robot.txt

# Run teardown script plan if it exists
cd ${TESTPLANDIR}
TEARDOWN=${TESTPLANDIR}/teardown.sh
if [ -f ${TEARDOWN} ]; then
    echo "Running teardown script ${TEARDOWN}"
    source ${TEARDOWN}
fi

# TODO: do something with the output

exit $RESULT
