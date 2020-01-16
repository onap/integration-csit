#!/bin/bash -xv
# ============LICENSE_START=======================================================
#  Copyright (C) 2020 AT&T Intellectual Property. All rights reserved.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================

for db in policyadmin operationshistory
do
     mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" --execute "CREATE DATABASE IF NOT EXISTS ${db};"
     mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" --execute "GRANT ALL PRIVILEGES ON \`${db}\`.* TO '${MYSQL_USER}'@'%' ;"
done

mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" --execute "FLUSH PRIVILEGES;"
