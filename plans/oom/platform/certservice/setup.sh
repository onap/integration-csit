#!/bin/bash
#
# Copyright 2020 Nokia.
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

# ------------------------------------
# Resolve path to script's directory and cmp servers configuration

SCRIPT=`realpath $0`
CURRENT_WORKDIR_PATH=`dirname $SCRIPT`
PROJECT_DIRECTORY="plans/oom/platform/certservice"

SCRIPTS_DIRECTORY="scripts"

JENKINS_SCRIPTS_PATH="$CURRENT_WORKDIR_PATH/$PROJECT_DIRECTORY/$SCRIPTS_DIRECTORY"
LOCAL_SCRIPTS_PATH="$CURRENT_WORKDIR_PATH/$SCRIPTS_DIRECTORY"

# ------------------------------------
#Prepare enviroment for client
#install docker sdk
echo "Uninstall docker-py and reinstall docker."
pip uninstall -y docker-py
pip uninstall -y docker
pip install -U docker==2.7.0

#reinstall pyopenssl library
echo "Reinstall pyopenssl library."
pip uninstall pyopenssl -y
pip install pyopenssl==17.5.0

#install pyjks for .jks files management
pip install pyjks

#Disable proxy - for local run
unset http_proxy https_proxy

#export container name
export ClientContainerName=CertServiceClient
# ------------------------------------

if test -d "$JENKINS_SCRIPTS_PATH"; then
    SCRIPTS_PATH=$JENKINS_SCRIPTS_PATH
else test -f "$LOCAL_SCRIPTS_PATH";
    SCRIPTS_PATH=$LOCAL_SCRIPTS_PATH
fi
echo "Use scripts from: $SCRIPTS_PATH"

CONFIGURATION_FILE="cmpServers.json"

JENKINS_CONFIGURATION_PATH="$CURRENT_WORKDIR_PATH/$PROJECT_DIRECTORY/$CONFIGURATION_FILE"
LOCAL_CONFIGURATION_PATH="$CURRENT_WORKDIR_PATH/$CONFIGURATION_FILE"

if test -f "$JENKINS_CONFIGURATION_PATH"; then
    CONFIGURATION_PATH="$JENKINS_CONFIGURATION_PATH"
else test -f "$LOCAL_CONFIGURATION_PATH";
    CONFIGURATION_PATH=$LOCAL_CONFIGURATION_PATH
fi
echo "Use configuration from: $CONFIGURATION_PATH"

# -------------------------------------

export CONFIGURATION_PATH=${CONFIGURATION_PATH}
export SCRIPTS_PATH=${SCRIPTS_PATH}

#Generate keystores, truststores, certificates and keys
mkdir -p ${WORKSPACE}/tests/oom/platform/certservice/assets/certs/
make all -C ./certs/
cp ${WORKSPACE}/plans/oom/platform/certservice/certs/root.crt ${WORKSPACE}/tests/oom/platform/certservice/assets/certs/root.crt
echo "Generated keystores"
openssl pkcs12 -in ${WORKSPACE}/plans/oom/platform/certservice/certs/certServiceServer-keystore.p12 -clcerts -nokeys -password pass:secret | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ${WORKSPACE}/tests/oom/platform/certservice/assets/certs/certServiceServer.crt
echo "Generated server certificate"
openssl pkcs12 -in ${WORKSPACE}/plans/oom/platform/certservice/certs/certServiceServer-keystore.p12 -nocerts -nodes -password pass:secret| sed -ne '/-BEGIN PRIVATE KEY-/,/-END PRIVATE KEY-/p' > ${WORKSPACE}/tests/oom/platform/certservice/assets/certs/certServiceServer.key
echo "Generated server key"

docker-compose up -d

OOMCERT_IP='none'
# Wait container ready
for i in {1..9}
do
   OOMCERT_IP=`get-instance-ip.sh oomcert-service`
   RESP_CODE=$(curl -s https://localhost:8443/actuator/health --cacert ./certs/root.crt --cert-type p12 --cert ./certs/certServiceServer-keystore.p12 --pass secret | \
   python2 -c 'import json,sys;obj=json.load(sys.stdin);print obj["status"]')
   if [[ "$RESP_CODE" == "UP" ]]; then
       echo 'OOM Cert Service is ready'
       export OOMCERT_IP=${OOMCERT_IP}
       docker exec oomcert-ejbca /opt/primekey/scripts/ejbca-configuration.sh
       break
   fi
   echo 'Waiting for OOM Cert Service to start up...'
   sleep 30s
done

if [ "$OOMCERT_IP" == 'none' -o "$OOMCERT_IP" == '' ]; then
    echo "OOM Cert Service is not ready!"
    exit 1 # Return error code
fi
