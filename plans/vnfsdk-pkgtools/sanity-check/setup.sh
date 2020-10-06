#!/bin/bash
#
# Copyright 2016-2017 Intel Corp., Ltd.
# Modifications copyright (c) 2017 AT&T Intellectual Property
# Modifications copyright (c) 2020 Nokia
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


# Clone vnfsdk/pkgtools repo and install it
PKGTOOLS=$WORKSPACE/archives/pkgtools

mkdir -p "$PKGTOOLS"
git clone -b master --single-branch https://gerrit.onap.org/r/vnfsdk/pkgtools.git "$PKGTOOLS"
python "$PKGTOOLS"/setup.py egg_info
pip install -r "$PKGTOOLS"/requirements.txt

# Pass any variables required by Robot test suites in ROBOT_VARIABLES
export ROBOT_VARIABLES="-v SCRIPTS:${SCRIPTS}"

