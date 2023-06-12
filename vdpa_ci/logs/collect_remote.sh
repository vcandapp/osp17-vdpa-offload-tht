#!/bin/bash

set -ex

if [[ $# != 2 ]]; then
    echo "Usage: ./collect_remote.sh /root/logs/output <JOB_NAME>"
    exit 1
fi

OUT=$1
JOB=$2

HOSTS='/root/infrared/.workspaces/active/hosts'
if [ ! -f $HOSTS ]; then
    echo "Infrared Hosts file (${HOSTS}) is missing!"
    exit 1
fi

cd /root/logs/
source /root/infrared/.venv/bin/activate

touch $OUT
# TODO(skramaja): Add a check for OSP or OCP
if [ -f "plays/osp_common.yml" ]; then
    ansible-playbook -i $HOSTS plays/osp_common.yml -e output_file=$OUT -vv
fi

if [ -f "plays/${JOB}.yml" ]; then
    ansible-playbook -i $HOSTS "plays/${JOB}.yml" -e output_file=$OUT -vv
fi
