#!/usr/bin/env bash
set -e

cur=$(dirname $(dirname $(readlink -f $0)))
host=$(hostname -s)

if [[ $(cat $cur/container_config.yml | yq -oj | jq ".$host") != "null" ]] ;then
    if=$(cat $cur/container_config.yml | yq -oj | jq -r ".$host.config | .if")

    lxc init as staging
    lxc config set staging security.nesting=true
    #lxc config device add staging eth0 nic nictype=macvlan parent=$if
    lxc start staging
    sleep 1
    lxc list
fi

