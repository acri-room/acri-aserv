#!/usr/bin/env bash
set -e

VALID_ARGS=$(getopt -o h --long help,dry-run,server:,share -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1;
fi

cur=$(dirname $(readlink -f $0))
host=$(hostname -s)
args_server=
args_share=
dry_run=0

eval set -- "$VALID_ARGS"
while [ : ]; do
    case "$1" in
        --server)
            args_server=$2 ; shift 2 ;;
        --share)
            args_share=true ; shift ;;
        --dry-run)
            dry_run=1 ; shift ;;
        -h | --help)
            echo "$0 [-h|--help] [--dry-run] [--server SERVER] [--share]" ; exit ;;
        --)
            shift ; break ;;
    esac
done

function stop_container() {
    server=$1

    # lxc
    LXC=/snap/bin/lxc

    if [[ $dry_run -eq 0 ]] ; then
        $LXC stop $server --force > /dev/null 2>&1 || true
        $LXC delete $server --force > /dev/null 2>&1 || true
    else
        echo $LXC stop $server --force
        echo $LXC delete $server --force
    fi
}

if [[ $(cat container_config.yml | yq ".$host") != "null" ]] ;then
    # Stop servers
    for server in $(cat container_config.yml | yq -r ".$host.servers | keys[]") ; do
	share=$(cat container_config.yml | yq -r ".$host.servers | .$server | .share")

	if [[ -z $args_server ]] || [[ $args_server == $server ]] ; then
	    if [[ -z $args_share ]] || [[ $args_share == $share ]] ; then
	        stop_container $server
	    fi
	fi
    done
fi

