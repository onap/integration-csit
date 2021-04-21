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
#docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $1
CONTAINER_ID=$(docker run --name multi-tenancy -d registry-dev.nso.lab-services.ca/nso-image/multi-tenancy-test-suite:latest)
docker exec -it CONTAINER_ID  /bin/sh
mvn gatling:test


