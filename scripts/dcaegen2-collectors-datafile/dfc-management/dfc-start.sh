#!/bin/bash

#function to load sftp servers keys to dfc app depending on KNOWN_HOSTS environment variable
# when KNOWN_HOSTS == "all_hosts_keys" or is not set, public keys of all sftp servers are loaded
# when KNOWN_HOSTS == "known_hosts_empty", empty known hosts file is created
# for other strings known hosts file is not created
function load-sftp-servers-keys() {
  if [ -z "$KNOWN_HOSTS" ] || [ "$KNOWN_HOSTS" == "all_hosts_keys" ]; then
    SFTP_SERVERS="$(docker ps -q --filter='name=dfc_sftp')"

    for SFTP_SERVER in $SFTP_SERVERS; do
      HOST_NAMES=$(docker inspect -f '{{ join .NetworkSettings.Networks.dfcnet.Aliases ","}}' $SFTP_SERVER)
      KEY_ENTRY=$(echo $HOST_NAMES "$(docker exec $SFTP_SERVER cat /etc/ssh/ssh_host_rsa_key.pub)" |
        sed -e 's/\w*@\w*$//')
      docker exec -u root dfc_app0 sh -c "echo $KEY_ENTRY >> /home/datafile/.ssh/known_hosts"
    done
  elif [ "$KNOWN_HOSTS" == "known_hosts_empty" ]; then
    docker exec -u root dfc_app0 sh -c "touch /home/datafile/.ssh/known_hosts"
  fi
}

set -x

cp $SIMGROUP_ROOT/../ftpes-sftp-server/tls/* $SIMGROUP_ROOT/tls/

#Start DFC app
DOCKER_SIM_NWNAME="dfcnet"
echo "Creating docker network $DOCKER_SIM_NWNAME, if needed"
docker network ls | grep $DOCKER_SIM_NWNAME >/dev/null || docker network create $DOCKER_SIM_NWNAME

if [ $HTTP_TYPE = "HTTPS" ]
	then
    mkdir $SIMGROUP_ROOT/tls/external
	  cp $SIMGROUP_ROOT/../certservice/generated/dfc-p12/* $SIMGROUP_ROOT/tls/external/
    docker run \
      --name oom-certservice-post-processor \
      --env-file $SIMGROUP_ROOT/../certservice/merger/merge-certs.env \
      --mount type=bind,src=$SIMGROUP_ROOT/tls,dst=/opt/app/datafile/etc/cert \
      nexus3.onap.org:10001/onap/org.onap.oom.platform.cert-service.oom-certservice-post-processor:latest
fi

docker-compose up -d

DFC_APP="$(docker ps -q --filter='name=dfc_app0')"

#Wait for initialization of docker containers for dfc app and all simulators
for i in {1..10}; do
  if [ $(docker inspect --format '{{ .State.Running }}' $DFC_APP) ]; then
    echo "DFC app Running"

    load-sftp-servers-keys

    # enable TRACE logging of DFC
    docker exec $DFC_APP /bin/sh -c " sed -i 's/org.onap.dcaegen2.collectors.datafile: WARN/org.onap.dcaegen2.collectors.datafile: TRACE/g' /opt/app/datafile/config/application.yaml"

    #enable TRACE logging of spring-framework
    docker exec $DFC_APP /bin/sh -c " sed -i 's/org.springframework.data: ERROR/org.springframework.data: TRACE/g' /opt/app/datafile/config/application.yaml"

    docker restart $DFC_APP
    sleep 10

    break
  else
    echo sleep $i
    sleep $i
  fi
done
