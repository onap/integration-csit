#!/bin/bash
#
# Copyright (C) 2020 Nokia. All rights reserved.
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
if [ $# -ne 1 ]; then
    echo "Incorrect number of parameters"
    exit 1
fi

LOCAL_COLLECTOR_PROPERTIES_PATH=$1
FILENAME=$(basename $LOCAL_COLLECTOR_PROPERTIES_PATH)
TEST_FILES_PATH=$2
ETC_PATH=/opt/app/VESCollector/etc
APP_CONTROLLER_PATH=/opt/app/VESCollector/bin/appController.sh

docker exec vesc $APP_CONTROLLER_PATH stop
sleep 2
docker cp $LOCAL_COLLECTOR_PROPERTIES_PATH vesc:$ETC_PATH
sleep 10
docker cp $TEST_FILES_PATH vesc:$ETC_PATH
sleep 10
docker exec vesc mv $ETC_PATH/$FILENAME $ETC_PATH/collector.properties
docker exec vesc $APP_CONTROLLER_PATH start
sleep 5
echo "VES Collector Restarted with overridden collector.properties"
