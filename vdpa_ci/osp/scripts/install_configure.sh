#!/bin/bash

set -ex

THT_URL="${repo_url}"
TMPL_DIR="osp${release%.*}_ref"
CMD_FILE="overcloud_deploy_${deploy_type}.sh"
COMMON_NET_DATA="vdpa_ci/osp/network_data_v2/${server}"

THT_BASE=`basename $THT_URL`
THT_DIR="${THT_BASE%.git}"
THT_PATH="${THT_DIR}/${TMPL_DIR}"

if [ -d $THT_DIR ]; then
    rm -rf $THT_DIR
fi
# Cloning to jenkins workspace folder
git clone --depth=1 $THT_URL

OPT="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

if [ ! -f "${THT_PATH}/${CMD_FILE}" ]; then
    echo "ERROR: Deploy file ${THT_PATH}/${CMD_FILE} is not available"
    exit 1
fi
cp ${THT_PATH}/${CMD_FILE} overcloud_deploy_vdpa.sh
scp ${OPT} overcloud_deploy_vdpa.sh root@${server}:/root/infrared/

ssh ${OPT} root@${server} "cd infrared/;rm -rf ${THT_DIR}; git clone $THT_URL"

VLAN_CONFIG=50

cp $COMMON_NET_DATA ${THT_PATH}/network_data.yaml
awk -v var="$VLAN_CONFIG" 'BEGIN{x=var+1;FS="\\n"}/vlan:/{gsub(/vlan:.*/,"vlan: "x++)} {print}' ${THT_PATH}/network_data.yaml > network_data.yaml
scp ${OPT} network_data.yaml root@${server}:/root/infrared/
scp ${OPT} network_data.yaml root@${server}:/root/infrared/${THT_PATH}/

awk -v var="$VLAN_CONFIG" 'BEGIN{x=var;FS="\\n"} /NeutronNetworkVLANRanges:/{gsub("NeutronNetworkVLANRanges:.*","NeutronNetworkVLANRanges: dpdk1:"x+5":"x+10",dpdk2:"x+5":"x+10",sriov1:"x+5":"x+10",sriov2:"x+5":"x+10)} {print}' ${THT_PATH}/network-environment-vdpa.yaml > network-environment-vdpa.yaml
scp ${OPT} network-environment-vdpa.yaml root@${server}:/root/infrared/${THT_PATH}

cp ${THT_PATH}/undercloud.conf undercloud.conf
scp $OPT undercloud.conf root@${server}:/root/infrared/

if [ -z $ipmipass ]; then
    echo "ERROR: IPMI password it not provided"
    exit 1
fi
export ipmi_password=$ipmipass
envsubst < $THT_URL/${server} >instack.json
cat instack.json
scp $OPT instack.json root@${server}:/root/infrared/

