###################################################################################################################
By executing the below commands it will change the CSIT test from executing on a docker envirnoment to an ONAP one.
###################################################################################################################

1) Login to an ONAP instance, switch user and verify that the command kubectl executes before proceeding .
# sudo -s
# kubectl get svc -n onap| grep dcae

2) Clone the csit repositry 
# git clone https://gerrit.onap.org/r/integration/csit

3) Install docker-compose 
# sudo apt-get update
# sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
# sudo chmod +x /usr/local/bin/docker-compose
# docker-compose --version    

4) Install the packages required for the RobotFramework.		
# apt install python-pip
# sudo apt install python-pip virtualenv unzip sshuttle netcat libffi-dev libssl-dev
# sudo pip install robotframework
# sudo pip install -U requests
# sudo pip install -U robotframework-requests

5) Expose the Ves-collector
# kubectl expose svc dcae-ves-collector --type=LoadBalancer --name=vesc -n onap
	service "vesc" exposed

6) Verify the Ves-collector is exposed
# kubectl get svc -n onap | grep vesc
	vesc	LoadBalancer   10.43.203.47    10.209.63.55	8080:31835/TCP		1m

7) Modify the file setup.sh and make the below change
# cd csit
# vi plans/usecases/5G-bulkpm/setup.sh 
CSIT=TRUE
 to
CSIT=FALSE

8) Excute the Bulk PM e2e csit.
# ./run-csit.sh plans/usecases/5G-bulkpm/

--> Troubleshooting
--------------------
If the Test case "Verify Default Feed And File Consumer Subscription On Datarouter" is hanging, quit the test and execute the below
Get the DR-PROV IP address  
# kubectl -n onap -o=wide get pods | grep dmaap-dr-prov | awk '{print $6}'
 10.42.123.76
Make sure there are no feeds
# curl -k https://10.42.123.76:8443/internal/prov

If there are feeds delete them
curl -X DELETE -H "Content-Type:application/vnd.att-dr.subscription" -H "X-ATT-DR-ON-BEHALF-OF:dradmin" -k https://10.42.123.76:8443/subs/XX

Where XX is the number of the feeds in the previous command.
