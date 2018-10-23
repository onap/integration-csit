#!/bin/sh
#
# ============LICENSE_START==========================================
# ===================================================================
# Copyright © 2017 AT&T Intellectual Property. All rights reserved.
# ===================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============LICENSE_END============================================
#
# ECOMP and OpenECOMP are trademarks
# and service marks of AT&T Intellectual Property.
#

echo "Creating camundabpmn database . . ."

mysql -uroot -p$MYSQL_ROOT_PASSWORD << 'EOF' || exit 1
DROP DATABASE IF EXISTS `camundabpmn`;
CREATE DATABASE `camundabpmn`;
DELETE FROM mysql.user WHERE User='camundauser';
CREATE USER 'camundauser';
GRANT ALL on camundabpmn.* to 'camundauser' identified by 'camunda123' with GRANT OPTION;
FLUSH PRIVILEGES;
EOF

cd /docker-entrypoint-initdb.d/db-sql-scripts/camunda || exit 1
mysql -uroot -p$MYSQL_ROOT_PASSWORD -f < mariadb_engine_7.8.0-ee.sql || exit 1
mysql -uroot -p$MYSQL_ROOT_PASSWORD -f < mariadb_create_camunda_admin.sql || exit 1
