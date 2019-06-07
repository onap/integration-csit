#!/bin/bash -x
#
# Copyright 2019 AT&T Intellectual Property. All rights reserved.
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

if [ "$#" -lt 2 ]; then
    echo "Insufficient number of arguments"
    echo "Needs gerrit branch name and at least one project name."
    exit -1
fi

GERRIT_BRANCH=$1
shift; # consuming first argument 

# the directory of the script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo ${DIR}

# the temp directory used, within $DIR
# omit the -p parameter to create a temporal directory in the default location
WORK_DIR=`mktemp -d -p "$DIR"`
echo ${WORK_DIR}

cd ${WORK_DIR}

# check if tmp dir was created
if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
  echo "Could not create temp dir"
  exit 1
fi

# Download Maven
mkdir maven
cd maven
curl -O http://apache.claz.org/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
tar -xzvf apache-maven-3.3.9-bin.tar.gz
ls -l
export PATH=${PATH}:${WORK_DIR}/maven/apache-maven-3.3.9/bin
${WORK_DIR}/maven/apache-maven-3.3.9/bin/mvn -v
cd ..


# Declare indexed array
declare -a PROJECT_VERSIONS

for PROJ in "$@" # Iterate
do
  echo "Downloading Project: ${PROJ}"
  curl "https://gerrit.onap.org/r/gitweb?p=policy/${PROJ}.git;a=blob_plain;f=pom.xml;hb=refs/heads/${GERRIT_BRANCH}" >pom.xml
  PROJECT_VERSIONS+=($(printf 'VERSION=${project.version}\n0\n' | mvn -N -fn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate | grep '^VERSION' | cut -d "=" -f 2))
  #Display full array every time.
  echo "${PROJECT_VERSIONS[@]}"
done

# Delete the temp directory.
rm -fr "${WORK_DIR}"
