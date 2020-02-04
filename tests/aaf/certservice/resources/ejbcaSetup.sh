#!/bin/bash
echo
echo
d=`date '+%Y-%m-%d %H:%M:%S'`
echo $d
echo -e "\033[0m"
#
#
#
#
function startup() {
echo -e "\033[0;32m"
echo ---------------------------------------------------------------------------------------------------------------------
echo  "✪ ✪  Getting EJBCA-CA Image  ✪ ✪ "
echo ---------------------------------------------------------------------------------------------------------------------
echo -e "\033[0m"
IMAGE='primekey/ejbca-ce'
docker pull $IMAGE 
IMAGEID=$(docker images primekey/ejbca-ce --format "{{.ID}}")
echo "Image ID of primekey/ejbca-ce is : " $IMAGEID
echo
echo
runcontainer
}
#
#
#
#
function runcontainer(){
echo -e "\033[0;32m"
echo ---------------------------------------------------------------------------------------------------------------------
echo  "✪ ✪  Run the Container ✪ ✪  "
echo ---------------------------------------------------------------------------------------------------------------------
echo -e "\033[0m"
IMAGE='primekey/ejbca-ce'
echo $d
echo "Running the container in the background" 
docker run -it --rm -d -p 80:8080 -p 443:8443 -h mycahostname --name mycontainer $IMAGE
docker logs mycontainer > runoutput.txt
echo "✪ ✪ ✪ ✪ ✪ ✪ ✪ ✪ ✪ ✪ ✪ ✪ ✪ ✪ ✪ ✪ "
echo $d
echo "...... ✪✪✪✪waiting 30 seconds✪✪✪✪ ...... "
sleep 30
runcommands
}
#
#
#
#
function runcommands(){
echo ---------------------------------------------------------------------------------------------------------------------
echo "❖ ❖  Running EJBCA Commands ❖ ❖ "
echo ---------------------------------------------------------------------------------------------------------------------
echo -e "\033[0m"
docker ps
MYCONTAINTER=$(docker ps -aqf "name=mycontainer")
echo CONTAINER ID of primekey/ejbca-ce is : = $MYCONTAINTER

docker exec $MYCONTAINTER ejbca.sh config cmp addalias --alias cmpRA
docker exec $MYCONTAINTER ejbca.sh config cmp updatealias --alias cmpRA --key operationmode --value ra
docker exec $MYCONTAINTER ejbca.sh ca editca --caname ManagementCA --field cmpRaAuthSecret --value mypassword
docker exec $MYCONTAINTER ejbca.sh config cmp dumpalias --alias cmpRA

docker exec $MYCONTAINTER ejbca.sh config cmp addalias --alias cmp
docker exec $MYCONTAINTER ejbca.sh config cmp updatealias --alias cmp --key allowautomatickeyupdate --value true
docker exec $MYCONTAINTER ejbca.sh ra addendentity --username Node123 --dn "CN=Node123" --caname ManagementCA --password mypassword --type 1 --token USERGENERATED
docker exec $MYCONTAINTER ejbca.sh ra setclearpwd --username Node123 --password mypassword
docker exec $MYCONTAINTER ejbca.sh config cmp updatealias --alias cmp --key extractusernamecomponent --value CN
docker exec $MYCONTAINTER ejbca.sh config cmp dumpalias --alias cmp

echo "Running getcacert"
docker exec $MYCONTAINTER ejbca.sh ca getcacert --caname ManagementCA -f /dev/stdout > cacert.pem
echo
echo
echo "collecting logs...... waiting 30 seconds ..."
sleep 30
echo "docker run output sent to >> runoutput.txt"
echo
docker logs mycontainer > runoutput.txt
USERNAME=$(awk '/Username:/ {print $8}' runoutput.txt)
echo "Username: " $USERNAME
PASSWORD=$(awk '/Password:/ {print $8}' runoutput.txt | tail -1 |tr -d '/r')
echo "Password: " $PASSWORD
docker exec $MYCONTAINTER ejbca.sh ra getendentitycert --username $PASSWORD --clipassword $PASSWORD
connection
#clean_up
exit 0
}
#
#
#
#
function connection(){
echo ---------------------------------------------------------------------------------------------------------------------
echo  "❖ ❖  Establish a Connection ❖ ❖ "
echo ---------------------------------------------------------------------------------------------------------------------
echo -e "\033[0m"
echo
echo "See runoutput.txt for Username/password, P12 import information"
echo "Launch the following URL"
echo
echo "https://127.0.0.1/ejbca/enrol/keystore.jsp"
#
##to fix## - error:  URL: command not found
#URL =https://127.0.0.1/ejbca/enrol/keystore.jsp
#[[ -x $BROWSER ]] && exec "$BROWSER" "$URL"
#path=$(which xdg-open || which gnome-open) && exec "$path" "$URL"
#echo "Can't find browser"
}
#
#
#
#
VALUE=$(docker ps -aqf "name=mycontainer")
echo "Value " = $VALUE
if [ -z "$VALUE" ] ;
	then
	echo "Container ID of primekey/ejbca-ce is : NULL"
	startup
else
	 runcontainer
fi
