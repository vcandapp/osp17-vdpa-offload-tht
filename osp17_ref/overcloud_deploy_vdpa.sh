#!/bin/bash

THT_PATH='/home/stack/osp17_ref'
DOCKER_IMAGES_ENV=''
if [[ ! -f "$THT_PATH/roles/roles_data.yaml" ]]; then
  [[ ! -d "$THT_PATH/roles" ]] && mkdir $THT_PATH/roles
  openstack overcloud roles generate -o $THT_PATH/roles/roles_data.yaml ControllerSriov ComputeSriov ComputeVdpa
fi

if [[ ! -f $THT_PATH/dvr_workarounds.sh ]]; then
    echo "Failed to locate ${THT_PATH}/dvr_workarounds.sh which is mandatory"
    exit 1
fi

#bash $THT_PATH/dvr_workarounds.sh

time openstack overcloud deploy --stack overcloud \
  --templates /usr/share/openstack-tripleo-heat-templates \
  --roles-file $THT_PATH/roles/roles_data_original.yaml \
  -n $THT_PATH/network/network_data_v2.yaml \
  --deployed-server \
  -e /home/stack/templates/overcloud-baremetal-deployed.yaml \
  -e /home/stack/templates/overcloud-networks-deployed.yaml \
  -e /home/stack/templates/overcloud-vip-deployed.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/ovs-hw-offload.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-ovn-sriov.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/disable-telemetry.yaml \
  -e /home/stack/containers-prepare-parameter.yaml \
  -e $THT_PATH/api-policies.yaml \
  -e $THT_PATH/sriov-config.yaml \
  -e $THT_PATH/vdpa-config.yaml \
  -e $THT_PATH/bridge-mappings.yaml \
  -e $THT_PATH/neutron-vlan-ranges.yaml \
  -e $THT_PATH/network-environment-vdpa.yaml \
  --ntp-server clock.redhat.com,time1.google.com,time2.google.com,time3.google.com,time4.google.com \
  --log-file overcloud_deployment.log

