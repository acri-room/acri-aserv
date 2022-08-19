#!/usr/bin/env bash
set -e

function sync_dir {
  local target=$1
  local dir=$2
  ssh $target "mkdir -p $dir"
  rsync -ahzv --progress $dir/* root@$target:$dir
}

eval $(ssh-agent)
ssh-add ~/.ssh/id_rsa

for t in aserv2 aserv3 aserv4 aserv5 gserv1; do
  sync_dir $t /tools/repo
  sync_dir $t /tools/data
done
