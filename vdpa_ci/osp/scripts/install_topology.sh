#!/bin/bash

set -ex

echo "Server is $server"

if [ -z $server ]; then
    echo "Server($server) is invalid"
    exit 1
fi

if [[ $server == "---" ]]; then
    echo "Server($server) is invalid"
    exit 1
fi

OPT="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

scp $OPT vdpa_ci/osp/scripts/install_topology_remote.sh root@${server}:/root/
CMD="bash /root/install_topology_remote.sh ${release} ${server} ${IR_NET_CONFIG}"
ssh $OPT root@${server} "echo ${CMD}>>/root/auto-cmd-history"
ssh $OPT root@${server} ${CMD}
