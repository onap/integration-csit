#!/bin/bash

configureEjbca() {
    ejbca.sh ca init My_ManagementCA "C=SE,O=PrimeKey,CN=My_ManagementCA" soft foo123 2048 RSA 365 --policy 2.5.29.32.0 SHA256WithRSA
    ejbca.sh ca editca --caname My_ManagementCA --field cmpRaAuthSecret --value mypassword
    ejbca.sh config cmp addalias --alias cmpRA
    ejbca.sh ca importprofiles -d /opt/primekey/certprofile
    ejbca.sh config cmp uploadfile --alias cmpRA --file /opt/primekey/scripts/cmp.cmpRA.dump
    ejbca.sh config cmp dumpalias --alias cmpRA
    ejbca.sh ca getcacert --caname My_ManagementCA -f /dev/stdout > cacert.pem
}

configureEjbca
