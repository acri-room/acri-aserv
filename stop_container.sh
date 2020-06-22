#!/usr/bin/env bash
set -e

# Check current container
for id in $(docker ps -a --filter "name=user-" --format "{{.ID}}") ; do
  echo Info: Stop user container: id=$id
  docker rm -f $id
done

rm -f /tmp/*.sshd_config
rm -f /tmp/*.xrdp.ini
