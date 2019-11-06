#!/bin/bash
# This script is complatile with Al Alto release onwords.
# This script will setup required service for Bulk PM usecase in ONAP deployment.
# Run the script on kubectl server.
# Run as a root user.

# Installing 3GPP PM Mapper and DFC
sudo -i
cd /tmp/
mkdir blueprints
PMMAPPER_POD=$(kubectl -n onap get pods | sed 's/ .*//'| grep dcae-pm-mapper)
if [ -z ${PMMAPPER_POD} ]
then
    echo "Installing PM Mapper..."
    cd /tmp/blueprints
    wget https://git.onap.org/dcaegen2/services/pm-mapper/plain/dpo/blueprints/k8s-pm-mapper.yaml
    POD=$(kubectl -n onap get pods | sed 's/ .*//'| grep cloudify)
    echo 'client_password: demo123456!' > input.yaml
    kubectl -n onap cp input.yaml ${POD}:/tmp/
    kubectl -n onap cp k8s-pm-mapper.yaml ${POD}:/tmp/
    kubectl -n onap exec -it ${POD} -- cfy install --blueprint-id pmmapper-2 --deployment-id pmmapper-2 -i /tmp/input.yaml /tmp/k8s-pm-mapper.yaml
    echo "Waiting (120s)for PM Mapper service to come online."
    sleep 120
    POD_STATUS=$(kubectl -n onap get pods | grep dcae-pm-mapper | awk '{print $3}')
    if [ ${POD_STATUS} == "Running" ]
    then
        echo "PM Mapper successfully installed."
    else
        echo "PM Mapper installation failed. Check cloudify manager for more info."
    fi
else
    echo "PM Mapper is already installed"
fi
DFC_POD=$(kubectl -n onap get pods | sed 's/ .*//'| grep datafile-collector)
if [ -z ${DFC_POD} ]
then
    echo "Installing Data File Collector..."
    cd /tmp/blueprints
    wget https://git.onap.org/dcaegen2/collectors/datafile/plain/datafile-app-server/dpo/blueprints/k8s-datafile.yaml
    kubectl -n onap cp k8s-datafile.yaml ${POD}:/tmp/
    kubectl -n onap exec -it ${POD} -- cfy install --blueprint-id dfc --deployment-id dfc /tmp/k8s-datafile.yaml
    echo "Waiting (120s)for Data File Collector service to come online."
    sleep 180
    POD_STATUS=$(kubectl -n onap get pods | grep datafile-collector | awk '{print $3}')
    if [ ${POD_STATUS} == "Running" ]
    then
        echo "Data File Collector successfully installed."
    else
        echo "Data File Collector installation failed. Check cloudify manager for more info."
    fi
else
    echo "Data File Collector is already installed"
fi

# Installing docker-compose
apt-get update
curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Installing docker
curl https://releases.rancher.com/install-docker/19.03.sh | sh
touch /etc/docker/daemon.json
chmod 777 /etc/docker/daemon.json
bash -c "cat > /etc/docker/daemon.json <<EOF
{
  \"log-driver\": \"json-file\",
  \"log-opts\": {
      \"max-size\": \"20m\",
      \"max-file\": \"3\"
  }
}
EOF"
service docker restart
docker-compose --version

# Installing sftp server
mkdir /tmp/docker-compose
cd /tmp/docker-compose
echo 'version: "2.1"
services:
  sftp:
    container_name: sftp
    image: atmoz/sftp
    ports:
      - "2222:22"
    volumes:
      - /tmp/docker-compose:/home/admin
    command: admin:admin:1001' > docker-compose.yml
docker-compose up -d
sleep 2
SFTP_IP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $7}')
SFTP_PORT=2222

# Getting necessary files for 5G Bulkpm usecase
wget https://git.onap.org/integration/csit/plain/tests/dcaegen2-pmmapper/pmmapper/assets/A20181002.0000-1000-0015-1000_5G.xml.gz
wget https://git.onap.org/integration/csit/plain/tests/usecases/5G-bulkpm/assets/json_events/FileExistNotification.json
cp A20181002.0000-1000-0015-1000_5G.xml.gz A20181002.0000-1000-0015-1000_5G1.xml.gz
cp A20181002.0000-1000-0015-1000_5G.xml.gz A20181002.0000-1000-0015-1000_5G2.xml.gz
cp FileExistNotification.json FileExistNotification1.json
cp FileExistNotification.json FileExistNotification2.json
sed -i 's/sftpserver/'${SFTP_IP}'/g' FileExistNotification.json
sed -i 's/sftpport/'${SFTP_PORT}'/g' FileExistNotification.json
sed -i 's/5G/5G1/g' FileExistNotification1.json
sed -i 's/5G/5G2/g' FileExistNotification2.json
ROBOT_POD=$(kubectl -n onap get pods | sed 's/ .*//'| grep robot)
kubectl -n onap cp FileExistNotification.json ${ROBOT_POD}:/var/opt/ONAP/robot/assets/5gbulkpm/
kubectl -n onap cp FileExistNotification1.json ${ROBOT_POD}:/var/opt/ONAP/robot/assets/5gbulkpm/
kubectl -n onap cp FileExistNotification2.json ${ROBOT_POD}:/var/opt/ONAP/robot/assets/5gbulkpm/