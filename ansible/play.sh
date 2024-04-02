#!/usr/bin/env bash
cur=$(dirname $(readlink -f $0))

if [[ -z $SSH_AGENT_PID ]] ; then
    eval $(ssh-agent)
    ssh-add ~/.ssh/id_rsa
fi

function exit_handler() {
    rm $cur/staging.tmp
    iptables -P FORWARD DROP
    exit
}
trap exit_handler ERR EXIT

iptables -P FORWARD ACCEPT
sed "s/%ADDRESS%/$($cur/get_ip.sh)/" $cur/staging > $cur/staging.tmp
ansible-playbook -i $cur/staging.tmp $cur/site.yml

