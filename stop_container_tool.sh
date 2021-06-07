#!/usr/bin/env bash
set -e

# Check current container
for id in $(docker ps -a --filter "name=tool" --format "{{.ID}}") ; do
  echo Info: Stop tool container: id=$id
  docker rm -f $id > /dev/null
done
