#!/bin/bash
#
# Copyright 2016-2017 Huawei Technologies Co., Ltd.
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
# Modifications copyright (c) 2017 AT&T Intellectual Property
#

docker cp sdnc_controller_container:/opt/opendaylight/data/log/karaf.log $WORKSPACE/archives/karaf.log
docker cp sdnc_controller_container:/opt/opendaylight/data/log/installCerts.log $WORKSPACE/archives/installCerts.log
kill-instance.sh sdnc_controller_container
kill-instance.sh sdnc_dgbuilder_container
kill-instance.sh sdnc_portal_container
kill-instance.sh sdnc_db_container
kill-instance.sh sdnc_ueblistener_container
kill-instance.sh sdnc_dmaaplistener_container
kill-instance.sh sdnc_ansible_container
# Commented out startup of PNF simulator due to permission issues.  Following lines can be uncommented
# when/if that problem is resolved.
#kill-instance.sh pnfsimulator_pnf-simulator_1
#kill-instance.sh pnfsimulator_mongo-express_1
#ill-instance.sh pnfsimulator_mongo_1

# $WORKSPACE/archives/appc deleted with archives folder when tests starts so we keep it at the end for debugging
