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

# All started containers stopped and removed  by the test case


# Fix ownership. Mounted resources to consul changes ownership which prevents csit test cleanup
cd $WORKSPACE/archives/nonrtric/test/simulator-group/
sudo chown $(id -u):$(id -g) consul_cbs
sudo chown $(id -u):$(id -g) consul_cbs/consul

