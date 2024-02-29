#!/usr/bin/env bash
set -e

cur=$(dirname $(readlink -f $0))
host=$(hostname -s)

#test=ando

# Alveo container
if [[ $(cat container_config.yml | yq ".$host") != "null" ]] ;then
    for server in $(cat container_config.yml | yq -r ".$host | keys[]") ; do
        #echo $server
	for key in ip cpu mem "if" driver ; do
            eval $key=$(cat container_config.yml | yq -r ".$host | .$server | .$key")
	    #eval echo $key = \$$key
        done

        mem=$mem cpu=$cpu if=$if driver=$driver $cur/start_container.sh $server $ip $test
    done
fi
