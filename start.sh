#!/usr/bin/env bash
set -e

VALID_ARGS=$(getopt -o h --long help,dry-run,server:,user: -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1;
fi

cur=$(dirname $(readlink -f $0))
host=$(hostname -s)
test_server=
test_user=
dry_run=0

YQ=/snap/bin/yq

eval set -- "$VALID_ARGS"
while [ : ]; do
    case "$1" in
        --server)
            test_server=$2 ; shift 2 ;;
        --user)
            test_user=$2 ; shift 2 ;;
        --dry-run)
            dry_run=1 ; shift ;;
        -h | --help)
            echo "$0 [-h|--help] [--dry-run] [--server SERVER] [--user USER]" ; exit ;;
        --)
            shift ; break ;;
    esac
done

if [[ $(cat $cur/container_config.yml | $YQ -oj | jq ".$host") != "null" ]] ;then

    # Host config
    for config in $(cat $cur/container_config.yml | $YQ -oj | jq -r ".$host.config | keys[]") ; do
	for key in "if" scratch_gb ; do
            eval $key=$(cat $cur/container_config.yml | $YQ -oj | jq -r ".$host.config | .$key")
	    #eval echo $key = \$$key
        done
    done

    # Start servers
    for server in $(cat $cur/container_config.yml | $YQ -oj | jq -r ".$host.servers | keys[]") ; do
	for key in ip cpu mem driver share ; do
            eval $key=$(cat $cur/container_config.yml | $YQ -oj | jq -r ".$host.servers | .$server | .$key")
	    #eval echo $key = \$$key
        done

	if [[ -z $test_server ]] || [[ $test_server == $server ]] ; then
	    if [[ $dry_run -eq 0 ]] ; then
                mem=$mem cpu=$cpu if=$if driver=$driver scratch_gb=$scratch_gb \
		share=$share \
    		$cur/start_container.sh $server $ip $test_user
	    else
                echo mem=$mem cpu=$cpu if=$if driver=$driver scratch_gb=$scratch_gb \
		share=$share \
    		$cur/start_container.sh $server $ip $test_user
	    fi
	fi
    done
fi
