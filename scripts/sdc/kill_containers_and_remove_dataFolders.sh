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
# Modifications copyright (c) 2019 Samsung Electronics Co., Ltd.
#

echo "This is ${WORKSPACE}/scripts/sdc/kill_and_remove_dataFolders.sh"

# copy logs to archive

cp -rf ${WORKSPACE}/data/logs/ ${WORKSPACE}/archives/
cp -rf ${WORKSPACE}/data/logs/*tests*/ExtentReport/* ${WORKSPACE}/archives/
cp -rf ${WORKSPACE}/data/logs/*tests*/target/*.xml ${WORKSPACE}/archives/

ls -Rt ${WORKSPACE}/archives/

#kill and remove all sdc dockers
docker stop $(docker ps -a -q --filter="name=sdc")
docker rm $(docker ps -a -q --filter="name=sdc")

echo --- WHO AM I? ---
whoami
echo --- DATA DIRECTORY PERMISSIONS

ls -la ${WORKSPACE}/data/
ls -la ${WORKSPACE}/data/*

echo --- can I fix them?
chmod -R 777 ${WORKSPACE}/data

#delete data folder
rm -rf ${WORKSPACE}/data/*
