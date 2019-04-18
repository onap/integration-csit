#!/bin/bash
#
# Copyright (C) 2019 Nokia Intellectual Property. All rights reserved.
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
# Place the scripts in run order:

/usr/bin/Xvfb :0 -screen 0 1024x768x24&
export DISPLAY=:0

source ${SCRIPTS}/common_functions.sh
source ${WORKSPACE}/scripts/vid/clone_and_setup_vid_data.sh
source ${WORKSPACE}/scripts/vid/start_vid_containers.sh

echo "Obtaining ip of VID server..."
VID_IP=`get-instance-ip.sh vid-server`
SO_SIMULATOR_IP=`get-instance-ip.sh so-simulator`

bypass_ip_address ${VID_IP}
bypass_ip_address ${SO_SIMULATOR_IP}

echo VID_IP=${VID_IP}
echo SO_SIMULATOR_IP=${SO_SIMULATOR_IP}


# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v VID_IP:${VID_IP} -v SO_SIMULATOR_IP:${SO_SIMULATOR_IP}"

pip install assertpy
pip install requests