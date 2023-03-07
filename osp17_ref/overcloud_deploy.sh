#!/bin/bash

THT_PATH='/home/stack/osp17_ref'

openstack overcloud roles generate -o $THT_PATH/roles/roles_data.yaml ControllerSriov ComputeSriov ComputeVdpa

echo "Deploying pre-provisioned overcloud nodes...."
openstack overcloud deploy $PARAMS \
    --templates /usr/share/openstack-tripleo-heat-templates \
    --ntp-server clock.redhat.com,time1.google.com,time2.google.com,time3.google.com,time4.google.com \
    --stack overcloud \
    -r /home/stack/osp17_ref/roles/roles_data.yaml \
    -n /home/stack/osp17_ref/network/network_data_v2.yaml \
    --deployed-server \
    -e /home/stack/templates/overcloud-baremetal-deployed.yaml \
    -e /home/stack/templates/overcloud-networks-deployed.yaml \
    -e /home/stack/templates/overcloud-vip-deployed.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-ovn-ha.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-ovn-sriov.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/disable-telemetry.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/debug.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/config-debug.yaml \
    -e $THT_PATH/os-net-config-mappings.yaml \
    -e /home/stack/osp17_ref/environment.yaml \
    -e /home/stack/osp17_ref/network-environment-offload.yaml \
    -e /home/stack/osp17_ref/bridge-mappings.yaml \
    -e /home/stack/osp17_ref/vdpa-config.yaml \
    -e /home/stack/containers-prepare-parameter.yaml \
    --log-file overcloud_deployment.log
