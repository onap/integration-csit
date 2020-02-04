#!/bin/bash
#
# Copyright 2017 ZTE Corporation.
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
#Make sure python-uuid is installed



AAFCERT_IMAGE=onap-dev-local.esisoj70.emea.nsn-net.net/kasperki/cert-service:1.0.0

echo AAFCERT_IMAGE=${AAFCERT_IMAGE}

# Start AAF Cert Srevice
docker run -p 8080:8080 -d --name aafcert ${AAFCERT_IMAGE}

AAFCERT_IP=`get-instance-ip.sh aafcert`
export AAFCERT_IP=${AAFCERT_IP}


#pip install jsonschema uuid
# Wait container ready
sleep 5

