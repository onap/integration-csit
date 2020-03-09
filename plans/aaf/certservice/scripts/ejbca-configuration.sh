#!/bin/bash

waitForEjbcaStartUp() {
    
    # Wait container ready
    for i in {1..5}
    do
    RESP_CODE=$(curl -I -s -o /dev/null -w "%{http_code}"  https://localhost:8443/ejbca/publicweb/healthcheck/ejbcahealth)
    if [[ "$RESP_CODE" == '200' ]]; then
        echo 'Ejbca is ready'
        break
    fi 
    echo 'Waiting for Ejbca to start up...'
    sleep 10s
    done
}

configureEjbca() {
    ejbca.sh config cmp addalias --alias cmpRA
    ejbca.sh config cmp updatealias --alias cmpRA --key operationmode --value ra
    ejbca.sh ca editca --caname ManagementCA --field cmpRaAuthSecret --value mypassword
    ejbca.sh config cmp updatealias --alias cmpRA --key responseprotection --value pbe
    ejbca.sh config cmp dumpalias --alias cmpRA
    ejbca.sh config cmp addalias --alias cmp
    ejbca.sh config cmp updatealias --alias cmp --key allowautomatickeyupdate --value true
    ejbca.sh config cmp updatealias --alias cmp --key responseprotection --value pbe
    ejbca.sh ra addendentity --username Node123 --dn "CN=Node123" --caname ManagementCA --password mypassword --type 1 --token USERGENERATED
    ejbca.sh ra setclearpwd --username Node123 --password mypassword
    ejbca.sh config cmp updatealias --alias cmp --key extractusernamecomponent --value CN
    ejbca.sh config cmp dumpalias --alias cmp
    ejbca.sh ca getcacert --caname ManagementCA -f /dev/stdout > cacert.pem
}

waitForEjbcaStartUp
configureEjbca
