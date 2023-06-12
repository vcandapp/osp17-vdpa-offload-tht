#!/bin/bash

set -ex

echo "server is ${server}"
if [ -z ${server} ]; then
    echo "Nothing to do, as server is not provided."
    exit 0
fi

NAME=${JOB_NAME#*/}
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
ssh $OPTS root@${server} 'mkdir -p /root/logs'
scp $OPTS logs/collect_remote.sh root@${server}:/root/logs/
scp $OPTS -r logs/plays root@${server}:/root/logs/
CMD="bash /root/logs/collect_remote.sh /root/logs/output ${NAME}"
ssh $OPTS root@${server} ${CMD}
scp $OPTS root@${server}:/root/logs/output .
