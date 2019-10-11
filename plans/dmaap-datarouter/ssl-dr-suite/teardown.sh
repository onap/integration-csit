#!/bin/bash

cd $WORKSPACE/archives/dmaapdr/datarouter/datarouter-docker-compose/src/main/resources
sudo sed -i".bak" '/dmaap-dr-prov/d' /etc/hosts
sudo sed -i".bak" '/dmaap-dr-node/d' /etc/hosts
#docker-compose rm -sf
python $WORKSPACE/scripts/dmaap-datarouter/remove_cert_from_ca.py
