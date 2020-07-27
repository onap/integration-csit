#!/bin/bash

#Stop all running containers
docker kill "$(docker ps -q -a)"
docker rm "$(docker ps -q -a)"
docker system prune -f

# Clone Simulators for DFC from integration repo.
mkdir -p $WORKSPACE/archives/dfc
cd $WORKSPACE/archives/dfc


if [ -z "$SIM_ROOT" ]
then
	git clone --depth 1 https://gerrit.onap.org/r/integration -b master
	#Location of all individual simulators for DFC
	echo "Determine SIM_ROOT based on the WORKSPACE"
	SIM_ROOT=$WORKSPACE/archives/dfc/integration/test/mocks/datafilecollector-testharness

	rm $SIM_ROOT/simulator-group/consul/consul/cbs_localhost_config.hcl || true
else
	echo "Using SIM_ROOT from environmental variable: " $SIM_ROOT
fi

#Location of the above simulators when run as a group. For start+config and stop.
SIMGROUP_ROOT=$SIM_ROOT/simulator-group

#Default IP for all containers
SIM_IP="127.0.0.1"
#Location of script to start and stop dfc
DFC_ROOT=$WORKSPACE/scripts/dcaegen2-collectors-datafile/dfc-management

#Make the env vars availble to the robot scripts
ROBOT_VARIABLES="-b debug.log -v SIMGROUP_ROOT:${SIMGROUP_ROOT} -v SIM_IP:${SIM_IP} -v DFC_ROOT:${DFC_ROOT}"





#Build needed simulator images. DR and MR simulators

cd $SIM_ROOT/mr-sim

docker build -t mrsim:latest .

cd $SIM_ROOT/dr-sim

docker build -t drsim_common:latest .

#Prepare the ftp simulator files.

cd $SIMGROUP_ROOT

#Copy ftp config for the ftp servers
cp -r ../ftpes-sftp-server/configuration .
cp -r ../ftpes-sftp-server/tls .

cd ../ftpes-sftp-server
docker build -t ftpes_vsftpd:latest -f Dockerfile-ftpes .


#All containers will be started and stopped via the robot tests.

