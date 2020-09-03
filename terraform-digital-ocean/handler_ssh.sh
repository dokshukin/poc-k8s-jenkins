#!/bin/sh
set -eu

STDIN=$(cat -)

SSH_KEY_FILE=`echo $STDIN | jq -rc .pub_key`

if [ -f "${SSH_KEY_FILE}" ] ; then
  MD5=`ssh-keygen -E md5 -lf ${SSH_KEY_FILE} | awk '{print $2}' | sed 's/^...://'`
else
  exit 1
fi

jq -n --arg ssh_md5 "${MD5}" '{"ssh_md5":$ssh_md5}'
