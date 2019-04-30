#!/bin/bash
# Deployment script for SO lab
# ===================================================
# Available parameters :
#
# env DOCKER_HOST (optional)
#     | sets the docker host to be used if not local unix socket
#
# env MSO_CONFIG_UPDATES (optional)
#     | json structure that matches volumes/mso/chef-config/mso-docker.json
#     | elements whose value needs to be updated before the deployment
#     | phase.
#
# env MSO_DOCKER_IMAGE_VERSION
#     | json structure that matches volumes/mso/chef-config/mso-docker.json
#     | elements whose value needs to be updated before the deployment
#     | phase.
################################### Functions definition ################################

NEXUS=1
if [ "$#" = 0 ]; then
    echo "Deploying with local images, not pulling them from Nexus."
    NEXUS=0
fi

if [ "$#" -ne 6 ] && [ $NEXUS -eq 1 ]; then
        echo "Usage: deploy.sh <NEXUS_HOST_MSO:NEXUS_PORT_MSO> <NEXUS_LOGIN_MSO> <NEXUS_PASSWORD_MSO> <NEXUS_HOST_MARIADB:NEXUS_PORT_MARIADB> <NEXUS_LOGIN_MARIADB> <NEXUS_PASSWORD_MARIADB>
              - env DOCKER_HOST (optional) 
                 sets the docker host to be used if not local unix socket 
     
              - env MSO_DOCKER_IMAGE_VERSION (required)
                 sets the mso docker image version
     
              - env MSO_CONFIG_UPDATES (optional) 
                json structure that matches volumes/mso/chef-config/mso-docker.json 
                elements whose value needs to be updated before the deployment 
                phase."
        
        exit 1
fi

if [ -z "$MSO_DOCKER_IMAGE_VERSION" ] && [ $NEXUS -eq 1 ]; then
        echo "Env variable MSO_DOCKER_IMAGE_VERSION must be SET to a version before running this script" 
        exit 1
fi

NEXUS_DOCKER_REPO_MSO=$1
NEXUS_USERNAME_MSO=$2
NEXUS_PASSWD_MSO=$3
NEXUS_DOCKER_REPO_MARIADB=$4
NEXUS_USERNAME_MARIADB=$5
NEXUS_PASSWD_MARIADB=$6



function init_docker_command() {
    if [ -z ${DOCKER_HOST+x} ];
    then
        DOCKER_CMD="docker"
        LBL_DOCKER_HOST="local docker using unix socket"
    else
        DOCKER_CMD="docker -H ${DOCKER_HOST}"
        LBL_DOCKER_HOST="(remote) docker using ${DOCKER_HOST}"  
    fi

    if [ -f "/opt/docker/docker-compose" ];
    then
        DOCKER_COMPOSE_CMD="/opt/docker/docker-compose"
    else
        DOCKER_COMPOSE_CMD="docker-compose"
    fi

    echo "docker command: ${LBL_DOCKER_HOST}"
}

function container_name() {
    SERVICE=$1
    BASE=$(echo $(basename `pwd`) | sed "s/[^a-z0-9]//i" | tr [:upper:] [:lower:])
    echo ${BASE}_${SERVICE}_1
}

function pull_docker_images() {
    echo "Using Nexus for MSO: $NEXUS_DOCKER_REPO_MSO (user "$NEXUS_USERNAME_MSO")"
    # login to nexus
    $DOCKER_CMD login -u $NEXUS_USERNAME_MSO -p $NEXUS_PASSWD_MSO $NEXUS_DOCKER_REPO_MSO
    $DOCKER_CMD login -u $NEXUS_USERNAME_MARIADB -p $NEXUS_PASSWD_MARIADB $NEXUS_DOCKER_REPO_MARIADB
    
    # get images
    $DOCKER_CMD pull $NEXUS_DOCKER_REPO_MSO/onap/so/api-handler-infra:$MSO_DOCKER_IMAGE_VERSION
    $DOCKER_CMD tag $NEXUS_DOCKER_REPO_MSO/onap/so/api-handler-infra:$MSO_DOCKER_IMAGE_VERSION onap/so/api-handler-infra:latest
    
    $DOCKER_CMD pull $NEXUS_DOCKER_REPO_MSO/onap/so/bpmn-infra:$MSO_DOCKER_IMAGE_VERSION
    $DOCKER_CMD tag $NEXUS_DOCKER_REPO_MSO/onap/so/bpmn-infra:$MSO_DOCKER_IMAGE_VERSION onap/so/bpmn-infra:latest
    
    $DOCKER_CMD pull $NEXUS_DOCKER_REPO_MSO/onap/so/sdc-controller:$MSO_DOCKER_IMAGE_VERSION
    $DOCKER_CMD tag $NEXUS_DOCKER_REPO_MSO/onap/so/sdc-controller:$MSO_DOCKER_IMAGE_VERSION onap/so/sdc-controller:latest
    
    $DOCKER_CMD pull $NEXUS_DOCKER_REPO_MSO/onap/so/vfc-adapter:$MSO_DOCKER_IMAGE_VERSION
    $DOCKER_CMD tag $NEXUS_DOCKER_REPO_MSO/onap/so/vfc-adapter:$MSO_DOCKER_IMAGE_VERSION onap/so/vfc-adapter:latest
        
    $DOCKER_CMD pull $NEXUS_DOCKER_REPO_MSO/onap/so/openstack-adapter:$MSO_DOCKER_IMAGE_VERSION
    $DOCKER_CMD tag $NEXUS_DOCKER_REPO_MSO/onap/so/openstack-adapter:$MSO_DOCKER_IMAGE_VERSION onap/so/openstack-adapter:latest
    
    $DOCKER_CMD pull $NEXUS_DOCKER_REPO_MSO/onap/so/catalog-db-adapter:$MSO_DOCKER_IMAGE_VERSION
    $DOCKER_CMD tag $NEXUS_DOCKER_REPO_MSO/onap/so/catalog-db-adapter:$MSO_DOCKER_IMAGE_VERSION onap/so/catalog-db-adapter:latest
    
    $DOCKER_CMD pull $NEXUS_DOCKER_REPO_MSO/onap/so/request-db-adapter:$MSO_DOCKER_IMAGE_VERSION
    $DOCKER_CMD tag $NEXUS_DOCKER_REPO_MSO/onap/so/request-db-adapter:$MSO_DOCKER_IMAGE_VERSION onap/so/request-db-adapter:latest
    
    $DOCKER_CMD pull $NEXUS_DOCKER_REPO_MSO/onap/so/sdnc-adapter:$MSO_DOCKER_IMAGE_VERSION
    $DOCKER_CMD tag $NEXUS_DOCKER_REPO_MSO/onap/so/sdnc-adapter:$MSO_DOCKER_IMAGE_VERSION onap/so/sdnc-adapter:latest
    
    echo "Using Nexus for MARIADB: $NEXUS_DOCKER_REPO_MARIADB (user "$NEXUS_USERNAME_MARIADB")"
    $DOCKER_CMD pull $NEXUS_DOCKER_REPO_MARIADB/mariadb:10.1.11
    $DOCKER_CMD tag  $NEXUS_DOCKER_REPO_MARIADB/mariadb:10.1.11  mariadb:10.1.11

}

function wait_for_mariadb() {
    CONTAINER_NAME=$1
   
    TIMEOUT=600
    
    # wait for the real startup
    AMOUNT_STARTUP=$($DOCKER_CMD logs ${CONTAINER_NAME} 2>&1 | grep 'mysqld: ready for connections.' | wc -l)
    while [[ ${AMOUNT_STARTUP} -lt 1 ]];
    do
    echo "Waiting for '$CONTAINER_NAME' deployment to finish ..."
    AMOUNT_STARTUP=$($DOCKER_CMD logs ${CONTAINER_NAME} 2>&1 | grep 'mysqld: ready for connections.' | wc -l)
    if [ "$TIMEOUT" = "0" ];
    then
        echo "ERROR: Mariadb deployment failed."
        exit 1
    fi
    let TIMEOUT-=5
    sleep 5
    done
}

################################### Script entry - Starting CODE ################################
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

init_docker_command
if [ $NEXUS -eq 1 ]; then
    pull_docker_images
fi

# don't remove the containers,no cleanup
#$DOCKER_COMPOSE_CMD stop 
#$DOCKER_COMPOSE_CMD rm -f -v

#brought in the down to stop and remove the images created by up
$DOCKER_COMPOSE_CMD down

# deploy
#Running docker-compose up -d starts the containers in the background and leaves them running.
#If there are existing containers for a service, and the service’s configuration or image was changed after the container’s creation, docker-compose up picks up the changes by stopping and recreating the containers (preserving mounted volumes). To prevent Compose from picking up changes, use the --no-recreate flag.
#If you want to force Compose to stop and recreate all containers, use the --force-recreate flag.
$DOCKER_COMPOSE_CMD up -d --no-recreate mariadb 
CONTAINER_NAME=$(container_name mariadb)
wait_for_mariadb $CONTAINER_NAME
#adding the detach mode (run in background)
$DOCKER_COMPOSE_CMD up -d
