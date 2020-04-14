#!/bin/bash

configureEjbca() {
    ejbca.sh ca init My_ManagementCA "C=SE,O=PrimeKey,CN=My_ManagementCA" soft foo123 2048 RSA 365 --policy 2.5.29.32.0 SHA256WithRSA
    ejbca.sh ca editca --caname My_ManagementCA --field cmpRaAuthSecret --value mypassword
    ejbca.sh config cmp addalias --alias cmpRA
    ejbca.sh ca importprofiles -d /opt/primekey/certprofile
    ejbca.sh config cmp updatealias --alias cmpRA --key operationmode --value ra
    ejbca.sh config cmp updatealias --alias cmpRA --key responseprotection --value pbe
    ejbca.sh config cmp updatealias --alias cmpRA --key ra.endentityprofile --value My_EndEntity
    ejbca.sh config cmp updatealias --alias cmpRA --key ra.certificateprofile --value MY_ENDUSER
    ejbca.sh config cmp updatealias --alias cmpRA --key ra.caname --value My_ManagementCA
    ejbca.sh config cmp updatealias --alias cmpRA --key allowautomatickeyupdate --value true
    ejbca.sh config cmp dumpalias --alias cmpRA
    ejbca.sh ca getcacert --caname My_ManagementCA -f /dev/stdout > cacert.pem
}

configureEjbca
