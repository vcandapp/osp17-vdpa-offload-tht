#!/bin/bash
###########################################################
# This script runs on the hypervisor node ################
###########################################################

set -ex

if [ "$#" -ne 1 ]; then
    echo "ERROR: Invalid Arguments"
    exit 1
fi

SERVER=$1

cd /root/infrared
source .venv/bin/activate
infrared virsh -vv --host-address ${SERVER} --host-key ~/.ssh/id_rsa --cleanup yes
