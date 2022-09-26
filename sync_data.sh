#!/usr/bin/env bash
set -e

function sync_dir {
    local target=$1
    local dir=$2
    ssh $target "mkdir -p $dir"
    rsync -ahzv --delete --progress $dir/* root@$target:$dir
}

eval $(ssh-agent)
ssh-add ~/.ssh/id_rsa

targets="aserv1 aserv2 aserv3 aserv4 aserv5 gserv1"
if [[ ! -z $* ]] ; then
    targets=$*
fi

for t in $targets; do
    if [[ $t != $(hostname -s) ]] ; then
        sync_dir $t /tools/repo
        sync_dir $t /tools/data
    fi
done
