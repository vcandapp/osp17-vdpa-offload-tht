#!/usr/bin/env bash

#THT_PATH='/home/stack/ospd-16.2-geneve-ovn-dvr-hw-offload-ctlplane-dataplane-bonding-hybrid'
THT_PATH='/home/stack/osp17_ref'

# Update roles file
# configuring external interface for computes
if [[ ! -f  $THT_PATH/roles/roles_data.yaml ]];then
    echo "Failed to locate ${THT_PATH}/roles/roles_data.yaml which is mandatory"
    exit 1
fi
if [[ ! -f $THT_PATH/roles/roles_data_original.yaml ]];then
   cp $THT_PATH/roles/roles_data.yaml $THT_PATH/roles/roles_data_original.yaml
fi
update_yaml=$(cat << EOF
import yaml

with open("$THT_PATH/roles/roles_data.yaml", 'r') as file:
    data = yaml.safe_load(file)

for item in data:
    if "External" not in item['networks'].keys():
        item['networks']['External'] = {'subnet': 'external_subnet'}

with open("$THT_PATH/roles/roles_data.yaml", 'w') as file:
    yaml.safe_dump(data, file)
EOF
)
python3 -c "${update_yaml}"

# configure networks interfaces in undercloud
if [[ ! -f  $THT_PATH/undercloud_vlans_network.json ]];then
    echo "Failed to locate ${THT_PATH}/undercloud_vlans_network.json which is mandatory"
    exit 1
fi

# Backup os-net-config configuration
if [[ ! -f /etc/os-net-config/config_original.json ]];then
   sudo cp /etc/os-net-config/config.json /etc/os-net-config/config_original.json
fi
# Merge files
sudo jq -n '{ network_config: [ inputs.network_config ] | add }' \
        /etc/os-net-config/config_original.json  \
        ${THT_PATH}/undercloud_vlans_network.json | sudo tee \
        /etc/os-net-config/config.json > /dev/null
#Update config
sudo os-net-config --debug --verbose -c /etc/os-net-config/config.json

#Route to internet
if [[ ! -f ${THT_PATH}/set_route_internet.sh ]];then
    echo "Failed to locate ${THT_PATH}/set_route_internet.sh which is mandatory"
    exit 1
fi
bash ${THT_PATH}/set_route_internet.sh
