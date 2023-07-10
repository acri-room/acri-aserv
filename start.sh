#!/usr/bin/env bash
set -e

cur=$(dirname $(readlink -f $0))
host=$(hostname -s)

# Alveo container
args=$(grep $host $cur/container_config.txt | cut -d " " -f 2-3)
cpu=$(grep $host $cur/container_config.txt | cut -d " " -f 4)
mem=$(grep $host $cur/container_config.txt | cut -d " " -f 5)
if=$(grep $host $cur/container_config.txt | cut -d " " -f 6)

if [[ $args != "" ]] ; then
  mem=$mem cpu=$cpu if=$if $cur/start_container.sh $args
fi

# Tool container
args=$(grep $host $cur/container_config_tool.txt | cut -d " " -f 2-3)
cpu=$(grep $host $cur/container_config_tool.txt | cut -d " " -f 4)
mem=$(grep $host $cur/container_config_tool.txt | cut -d " " -f 5)
if=$(grep $host $cur/container_config_tool.txt | cut -d " " -f 6)

if [[ $args != "" ]] ; then
  mem=$mem cpu=$cpu if=$if $cur/start_container_tool.sh $args
fi

