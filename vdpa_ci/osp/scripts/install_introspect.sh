#!/bin/bash

set -ex

if [ -z $repo_url ]; then
    echo "ERROR: Template repo url is not provided"
    exit 1
fi

if [ -z $release ]; then
    echo "ERROR: OSP Release Version is not provided"
    exit 1
fi

THT_URL="${repo_url}"
TMPL_DIR="osp${release%.*}_ref"

THT_BASE=`basename $THT_URL`
THT_DIR="${THT_BASE%.git}"
THT_PATH="${THT_DIR}/${TMPL_DIR}"

OPT="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

scp $OPT vdpa_ci/osp/scripts/install_introspect_remote.sh root@${server}:/root/
CMD="bash /root/install_introspect_remote.sh ${release} ${THT_PATH}"
ssh $OPT root@${server} "echo ${CMD}>>/root/auto-cmd-history"
ssh $OPT root@${server} ${CMD}
