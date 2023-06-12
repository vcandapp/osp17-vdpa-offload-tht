#!/bin/bash
###########################################################
# This script runs on the hypervisor node ################
###########################################################

set -ex

if [ "$#" -lt 2 ]; then
    echo "ERROR: Invalid Arguments"
    exit 1
fi

RELEASE=$1
SERVER=$2
#ARGS="${@:3}"

# Modify based on OSP release changes
#####################################
VERSION16_1="8.2.0"
VERSION16_2="8.4"
VERSION17_0="8.4"
VERSION17_0_RHEL9="9.0"
#####################################

echo "Deploying OSP version $RELEASE"
MAJ=${RELEASE%.*}
if echo $RELEASE | grep -qe '\.' ; then
    MIN=${RELEASE#*.}
else
    MIN=""
fi

echo "Deploying OSP Major (${MAJ}) and Minor (${MIN}) Version"

BASE8="http://download.eng.brq.redhat.com/rhel-8/rel-eng/RHEL-8/latest-RHEL-@VERSION@/compose/BaseOS/x86_64/images"
BASE9="http://download.eng.brq.redhat.com/rhel-9/rel-eng/RHEL-9/latest-RHEL-@VERSION@/compose/BaseOS/x86_64/images"

if [[ $MAJ -lt 16 ]]; then
    BASE=${BASE7/@VERSION@/$VERSION13}
elif [[ $MAJ -eq 16 ]]; then
    if [[ $MIN -eq 1 || $MIN -eq 2 ]]; then
        if [[ $MIN -eq 2  ]]; then
            BASE=${BASE8/@VERSION@/$VERSION16_2}
        elif [[ $MIN -eq 1 ]]; then
            BASE=${BASE8/@VERSION@/$VERSION16_1}
        fi
    else
        echo "Unsupported release - ${RELEASE}"
        exit 1
    fi
elif [[ $MAJ -eq 17 ]]; then
    BASE=${BASE9/@VERSION@/$VERSION17_0_RHEL9}
fi

MD5="$BASE/MD5SUM"
LINE=$(curl -s $MD5 | grep 'guest-image')
LINE=${LINE%:*}
LINE=${LINE#\# }
IMG="${BASE}/${LINE}"

IMG="https://rhos-qe-mirror-brq.usersys.redhat.com/rhel-9/nightly/RHEL-9/latest-RHEL-9.2/compose/BaseOS/x86_64/images/rhel-guest-image-9.2-20230531.18.x86_64.qcow2"
echo "Base OS Image used - ${IMG}"

# Verify if the URL is valid
# curl -s --head $IMG | grep -q "200 OK"

UCIDR=`cat /root/infrared/undercloud.conf |grep ^local_ip|awk 'BEGIN{FS=OFS="="} {print $2}'|sed "s/ //g"`
UIP=${UCIDR%/*}
echo "UIP from network data - ${UIP}"
UIP_PREFIX=${UIP%.*}
echo "UIP_PREFIX - ${UIP_PREFIX}"

CNTRL_ARGS=" -e  override.networks.net1.ip_address=${UIP_PREFIX}.150 "
echo "UIP from undercloud - ${CNTRL_ARGS}"

ECIDR=$(cat /root/infrared/network_data.yaml |awk 'BEGIN{RS="-";FS=""}{print}'|awk -v var="name_lower: external" 'BEGIN{RS="\\n\\n";FS="\\n"} $0~var{print }'|awk 'BEGIN{FS="";}/ip_subnet:/{print}'|awk 'BEGIN{FS=OFS=":"} {print $2}'|sed "s/'//g"|sed "s/ //g")
EIP=${ECIDR%/*}
EIP=${EIP%.*}
echo "EIP from network data - ${EIP}"

NET_ARGS=" -e  override.networks.net4.ip_address=$EIP.1 -e  override.networks.net4.dhcp.range.start=$EIP.2  -e  override.networks.net4.dhcp.range.end=$EIP.100  -e  override.networks.net4.dhcp.subnet_cidr=$EIP.0/24  -e  override.networks.net4.dhcp.subnet_gateway=$EIP.1   -e  override.networks.net4.floating_ip.start=$EIP.101 -e  override.networks.net4.floating_ip.end=$EIP.151 "

BOOT_MODE="uefi"

echo "Setting boot mode ($BOOT_MODE) for ($SERVER)"

cd /root/infrared
source .venv/bin/activate


infrared virsh -vv --topology-nodes undercloud:1,controller:3 --topology-network 11_nets_3_bridges_hybrid  --host-address ${SERVER} --host-key ~/.ssh/id_rsa --image-url ${IMG} --host-memory-overcommit False --collect-ansible-facts False  --host-mtu-size 9000 --bootmode "uefi"  -e override.controller.memory=25600 -e override.undercloud.memory=25600  -e override.controller.cpu=6   -e override.undercloud.cpu=6   -e override.networks.net1.nic=ens1f1  ${CNTRL_ARGS}  -e override.networks.net2.nic=ens1f2 -e override.networks.net3.nic=ens1f0 -e override.controller.disks.disk1.size=100G  --virtopts "--console pty" -o provision.yml
