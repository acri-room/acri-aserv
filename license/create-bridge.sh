#!/usr/bin/env bash

cfg=$(echo "
aserv2 eno1      172.16.6.202 172.16.6.2 172.16.6.102
aserv5 enp0s31f6 172.17.6.205 172.17.6.5 172.17.6.105
" | grep $(hostname))

if=$(echo $cfg | awk '{print $2}')
lic_ip=$(echo $cfg | awk '{print $3}')
as0xx_ip=$(echo $cfg | awk '{print $4}')
as1xx_ip=$(echo $cfg | awk '{print $5}')

bridge=$(ip a | grep macvlan-bridge)

if [[ -z $bridge ]] ; then
    ip link add macvlan-bridge link $if type macvlan mode bridge
    ip addr add $lic_ip/32 dev macvlan-bridge
    ip link set macvlan-bridge up
    ip route add $as0xx_ip/32 dev macvlan-bridge
    ip route add $as1xx_ip/32 dev macvlan-bridge
fi
