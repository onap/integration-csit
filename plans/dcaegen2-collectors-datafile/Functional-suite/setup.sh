#!/bin/bash

#Stop all running containers
docker kill "$(docker ps -q -a)"
docker rm "$(docker ps -q -a)"

# Clone Simulators for DFC from integration repo.
mkdir -p $WORKSPACE/archives/dfc
cd $WORKSPACE/archives/dfc
git clone --depth 1 https://gerrit.onap.org/r/integration -b dublin

#Location of all individual simulators for DFC
SIM_ROOT=$WORKSPACE/archives/dfc/integration/test/mocks/datafilecollector-testharness
#Location of the above simulators when run as a group. For start+config and stop.
SIMGROUP_ROOT=$SIM_ROOT/simulator-group

#Default IP for all containers
SIM_IP="127.0.0.1"
#Location of script to start and stop dfc
DFC_ROOT=$WORKSPACE/scripts/dcaegen2-collectors-datafile/dfc-management

#Make the env vars availble to the robot scripts
ROBOT_VARIABLES="-v SIMGROUP_ROOT:${SIMGROUP_ROOT} -v SIM_IP:${SIM_IP} -v DFC_ROOT:${DFC_ROOT}"

#Build needed simulator images. DR and MR simulators

cd $SIM_ROOT/mr-sim

docker build -t mrsim:latest .

cd $SIM_ROOT/dr-sim

docker build -t drsim_common:latest .

#Prepare the ftp simulator files.

cd $SIMGROUP_ROOT

#Copy ftp config for the ftp servers
cp -r ../ftps-sftp-server/configuration .
cp -r ../ftps-sftp-server/tls .

#All containers will be started and stopped via the robot tests.

