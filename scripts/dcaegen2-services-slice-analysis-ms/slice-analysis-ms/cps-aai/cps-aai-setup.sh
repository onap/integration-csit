#!/bin/bash

#Building cps-tbdmt image
git clone "https://gerrit.onap.org/r/cps/cps-tbdmt"
mvn -f cps-tbdmt/ -Dmaven.test.skip clean install --settings settings.xml
sudo rm -r cps-tbdmt/

#Creating containers for cps, cps-tbdmt & aai-resources
docker-compose up -d

sleep 50

# uploading data to cps & cps-tbdmt 
CPS_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' cps-and-ncmp )
echo $CPS_IP
CPS_TBDMT_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' cps-tbdmt )
echo $CPS_TBDMT_IP

echo "Creating dataspace: "
curl --location --user cpsuser:cpsr0cks! -H "Accept: application/json" -H "Content-Type: application/json" \
--request POST \
http://$CPS_IP:8080/cps/api/v1/dataspaces?dataspace-name=E2EDemo

echo "\nCreating schema set: "
curl --location --user cpsuser:cpsr0cks! \
--request POST \
http://$CPS_IP:8080/cps/api/v1/dataspaces/E2EDemo/schema-sets --form 'file=@"ran-network.zip"' --form 'schema-set-name="ran-network"'

echo "\nCreating anchor: "
curl --location --user cpsuser:cpsr0cks!  --request POST \
http://$CPS_IP:8080/cps/api/v1/dataspaces/E2EDemo/anchors?schema-set-name=ran-network \
-d anchor-name=ran-network-anchor

echo "\nUploading cps payload "
curl --location --user cpsuser:cpsr0cks! --request POST \
http://$CPS_IP:8080/cps/api/v1/dataspaces/E2EDemo/anchors/ran-network-anchor/nodes \
--header 'Content-Type: application/json' \
-d @sim-data/payload-ran-network.json


echo "\nuploading tbdmt-templates"
curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header 'Content-Type: application/json' \
--data-raw '{"templateId": "get-nearrtric-config","model": "ran-network","requestType": "query-cps-path","xpathTemplate": "//sNSSAIList[@sNssai='\''{{sNssai}}'\'']/ancestor::NearRTRIC","includeDescendants": true}'

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header 'Content-Type: application/json' \
--data-raw '{"templateId": "get-gnbdufunction-by-snssai","model": "ran-network","requestType": "query-cps-path","xpathTemplate": "//sNSSAIList[@sNssai='\''{{sNssai}}'\'']/ancestor::GNBDUFunction","includeDescendants": true}'

curl --location --request POST \
http://$CPS_TBDMT_IP:8080/templates \
--header 'Content-Type: application/json' \
--data-raw '{"templateId": "get-nrcelldu-by-snssai","model": "ran-network","requestType": "query-cps-path","xpathTemplate": "//sNSSAIList[@sNssai='\''{{sNssai}}'\'']/ancestor::NearRTRIC","includeDescendants": true}'


##Uploading aai data
AAI_RESOURCES_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' aai-resources )

echo "\nUploading data to aai-resources"
curl --request PUT -H "X-FromAppId:AAI " -H  "X-TransactionId:get_aai_subscr" -H "Accept:application/json" -H "Content-Type:application/json" -k \
https://$AAI_RESOURCES_IP:8447/aai/v21/business/customers/customer/5GCustomer \
-d @sim-data/customers.json

curl --request PUT -H "X-FromAppId:AAI " -H  "X-TransactionId:get_aai_subscr" -H "Accept:application/json" -H "Content-Type:application/json" -k \
https://$AAI_RESOURCES_IP:8447/aai/v21/business/customers/customer/5GCustomer/service-subscriptions/service-subscription/5G \
-d @sim-data/service_subscriptions.json

curl --request PUT -H "X-FromAppId:AAI " -H  "X-TransactionId:get_aai_subscr" -H "Accept:application/json" -H "Content-Type:application/json" -k \
https://$AAI_RESOURCES_IP:8447/aai/v21/business/customers/customer/5GCustomer/service-subscriptions/service-subscription/5G/service-instances/service-instance/3f2f23fa-c567-4dd8-8f15-f95ae3e6fd84 \
-d @sim-data/service_instances.json

curl --request PUT -H "X-FromAppId:AAI " -H  "X-TransactionId:get_aai_subscr" -H "Accept:application/json" -H "Content-Type:application/json" -k \
https://$AAI_RESOURCES_IP:8447/aai/v24/business/customers/customer/5GCustomer/service-subscriptions/service-subscription/5G/service-instances/service-instance/3f2f23fa-c567-4dd8-8f15-f95ae3e6fd84/slice-profiles/slice-profile/684hf846f-863b-4901-b202-0ab86a638555 \
-d @sim-data/slice_profile.json

