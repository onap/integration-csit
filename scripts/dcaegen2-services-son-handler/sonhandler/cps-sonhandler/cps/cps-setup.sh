#!/bin/bash
    
#Building cps-tbdmt image
git clone "https://gerrit.onap.org/r/cps/cps-tbdmt"
mvn -f cps-tbdmt/ -Dmaven.test.skip clean install --settings settings.xml
sudo rm -r cps-tbdmt/

#Creating containers for cps and cps-tbdmt
docker-compose up -d

sleep 80
 
# Uploading data to cps & cps-tbdmt
CPS_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' cps-and-ncmp )
echo $CPS_IP
CPS_TBDMT_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' cps-tbdmt )
echo $CPS_TBDMT_IP

echo "Creating dataspace: "
curl --location --user cpsuser:cpsr0cks! -H "Accept: application/json" -H "Content-Type: application/json" \
	--request POST \
	http://$CPS_IP:8080/cps/api/v1/dataspaces?dataspace-name=sondataspace
sleep 5

echo "\nCreating schema sets: "
curl --location --user cpsuser:cpsr0cks! \
	--request POST \
	http://$CPS_IP:8080/cps/api/v1/dataspaces/sondataspace/schema-sets --form 'file=@"ran-network.zip"' --form 'schema-set-name="ran-network-schemaset"'

curl --location --user cpsuser:cpsr0cks! \
	--request POST \
	http://$CPS_IP:8080/cps/api/v1/dataspaces/sondataspace/schema-sets --form 'file=@"cps-ran-updated.zip"' --form 'schema-set-name="cps-ran-schemaset"'
sleep 5

echo "\nCreating anchor: "
curl --location --user cpsuser:cpsr0cks!  --request POST \
	http://$CPS_IP:8080/cps/api/v1/dataspaces/sondataspace/anchors?schema-set-name=ran-network-schemaset \
	-d anchor-name=ran-network-anchor

curl --location --user cpsuser:cpsr0cks!  --request POST \
	http://$CPS_IP:8080/cps/api/v1/dataspaces/sondataspace/anchors?schema-set-name=cps-ran-schemaset \
	-d anchor-name=cps-ran-anchor
sleep 5

echo "\nUploading cps payload "
curl --location --user cpsuser:cpsr0cks! --request POST \
	http://$CPS_IP:8080/cps/api/v1/dataspaces/sondataspace/anchors/ran-network-anchor/nodes \
	--header 'Content-Type: application/json' \
	-d @sim-data/payload-ran-network.json
sleep 5

curl --location --user cpsuser:cpsr0cks! --request POST \
	http://$CPS_IP:8080/cps/api/v1/dataspaces/sondataspace/anchors/cps-ran-anchor/nodes \
	--header 'Content-Type: application/json' \
	-d @sim-data/payload-cps-ran.json
sleep 5 
 
echo "\nUploading tbdmt-templates"

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
	--header 'Content-Type: application/json' \
	--data-raw '{"templateId": "get-cell","model": "cps-ran-schemaset","requestType": "query-cps-path","xpathTemplate": "//NRCellCU[@idNRCellCU='\''{{cellId}}'\'']//ancestor::Regions","includeDescendants": true, "transformParam":"Regions"}'

sleep 3

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
	--header 'Content-Type: application/json' \
	--data-raw '{"templateId": "get-pnf","model": "ran-network-schemaset","requestType": "query-cps-path","xpathTemplate": "//NRCellDU[@idNRCellDU='\''{{cellId}}'\'']/ancestor::GNBDUFunction","includeDescendants": true,"transformParam":"ietf-inet-types:GNBDUFunction"}'

sleep 3

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
	--header 'Content-Type: application/json' \
	--data-raw '{"templateId": "get-pci","model": "ran-network-schemaset","requestType": "query-cps-path","xpathTemplate": "//NRCellDU[@idNRCellDU='\''{{cellId}}'\'']","includeDescendants": true,"transformParam":"ietf-inet-types:NRCellDU,attributes"}'

sleep 3

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
	--header 'Content-Type: application/json' \
	--data-raw '{"templateId": "get-nbr-list","model": "cps-ran-schemaset","requestType": "get","xpathTemplate": "/cps-ran-schema/Regions[@regionId='\''{{10000000}}'\'']/cps-region-cell-mapping/NRCellCU[@idNRCellCU='\''{{cellId}}'\'']","includeDescendants": true, "transformParam":"cps-ran-schema-model:NRCellCU"}'

sleep 3

