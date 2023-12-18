#!/usr/bin/env bash
set -e

cur=$(dirname $(readlink -f $0))
host=$(hostname -s)

# Get hostname
hostname=$(grep $host $cur/container_config_tool.txt | cut -d " " -f 2)

# lxc
LXC=/snap/bin/lxc

$LXC stop $hostname --force > /dev/null 2>&1 || true
$LXC delete $hostname --force > /dev/null 2>&1 || true
