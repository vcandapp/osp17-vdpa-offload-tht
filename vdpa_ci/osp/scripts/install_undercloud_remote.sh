#!/bin/bash
###########################################################
# This script runs on the hypervisor node ################
###########################################################

set -ex

if [ "$#" -ne 3 ]; then
    echo "ERROR: Invalid Arguments"
    exit 1
fi

RELEASE=$1
BUILD=$2
SERVER=$3

cd /root/infrared
source .venv/bin/activate

echo "OSP rel. $RELEASE, build: $BUILD"

SSL=""
REPO=""
# Use undercloud SSL only with OSP16 onwards
if [[ ${RELEASE} != "13" ]]; then
    # Facing error after installing shift-on-stack, fix it before enabling it
    SSL="--ssl no --tls-ca https://password.corp.redhat.com/RH-IT-Root-CA.crt"
    REPO="--repos-urls http://download.eng.pek2.redhat.com/rcm-guest/puddles/OpenStack/17.1-RHEL-9/latest-RHOS-17.1-RHEL-9.2/compose/OpenStack/x86_64/os/"
fi

local_ip=$(awk -F "=" '/^local_ip/{print $2}' /root/infrared/undercloud.conf | xargs)
undercloud_public_host=$(awk -F "=" '/^undercloud_public_host/{print $2}' /root/infrared/undercloud.conf | xargs)
undercloud_admin_host=$(awk -F "=" '/^undercloud_admin_host/{print $2}' /root/infrared/undercloud.conf | xargs)
cidr=$(awk -F "=" '/^cidr/{print $2;exit}' /root/infrared/undercloud.conf | xargs)
dhcp_start=$(awk -F "=" '/^dhcp_start/{print $2;exit}' /root/infrared/undercloud.conf | xargs)
dhcp_end=$(awk -F "=" '/^dhcp_end/{print $2;exit}' /root/infrared/undercloud.conf | xargs)
gateway=$(awk -F "=" '/^gateway/{print $2;exit}' /root/infrared/undercloud.conf | xargs)
inspection_iprange=$(awk -F "=" '/^inspection_iprange/{print $2;exit}' /root/infrared/undercloud.conf | xargs)

#--repos-urls http://download.devel.redhat.com/rcm-guest/puddles/OpenStack/17.0-RHEL-8/latest-RHOS-17.0-RHEL-8.4/compose/OpenStack/x86_64/os/ \

infrared tripleo-undercloud -vv \
    -o undercloud.yml --mirror "brq2" \
    --version $RELEASE --build ${BUILD} \
    --boot-mode "uefi" \
    --images-task=rpm --images-update no ${SSL} \
    ${REPO} \
    --config-file /root/infrared/undercloud.conf \
    --config-options DEFAULT.undercloud_timezone=UTC \
    --ntp-pool clock.corp.redhat.com \
    --tls-ca 'https://password.corp.redhat.com/RH-IT-Root-CA.crt'


infrared ssh undercloud-0 "sudo yum install -y wget tmux vim"
infrared ssh undercloud-0 "echo 'set-window-option -g xterm-keys on' >~/.tmux.conf"

# Copy authorized keys of hypervisor to undercloud to allow ssh via proxy
OPT="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
scp $OPT /root/.ssh/authorized_keys stack@undercloud-0:~/hypervisor.authorized_keys
infrared ssh undercloud-0 "cat ~/hypervisor.authorized_keys >>~/.ssh/authorized_keys"


