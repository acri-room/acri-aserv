#!/usr/bin/env bash
set -e

cur=$(dirname $(dirname $(readlink -f $0)))
host=$(hostname -s)

if [[ $(cat $cur/container_config.yml | yq ".$host") != "null" ]] ;then
    if=$(cat $cur/container_config.yml | yq -r ".$host.config | .if")

    lxc init as staging
    lxc config set staging security.nesting=true
    lxc start staging
    sleep 1
    lxc list
fi

