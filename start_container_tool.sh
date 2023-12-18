#!/usr/bin/env bash

# Usage
if [[ $# -lt 2 ]] ; then
    echo Usage: $0 HOSTNAME IP
    exit 1
fi

# Arguments
hostname=$1; shift
ip=$1; shift

# Lock
lockfile=/tmp/$hostname.lock
mkdir $lockfile > /dev/null 2>&1
if [ $? -ne 0 ] ; then
    #echo lock fail
    exit
fi
function exit_handler() {
    #echo exit handler
    rmdir $lockfile
    exit
}
trap exit_handler ERR EXIT

# Exit on error
set -e

# Get user
cur=$(dirname $(readlink -f $0))

# lxc
LXC=/snap/bin/lxc

# Check running container
container_status=$($LXC ls -f json | jq -rj ".[] | select(.name == \"$hostname\") | .status")

# Check if container is already running
if [[ $container_status == "Running" ]] ; then
    exit
elif [[ -n $container_status ]] ; then
    echo Info: Stop tool container: name=$hostname, date=$(date)
    $LXC stop $hostname --force > /dev/null 2>&1 || true
    $LXC delete $hostname --force > /dev/null 2>&1 || true
fi

# Start container
echo Info: Start tool container: hostname=$hostname, ip=$ip, date=$(date)

# Memory
if [[ $mem == "" ]] ; then
    mem=60
fi

# CPU
if [[ $cpu == "" ]] ; then
    # Default: Available cores / 2
    cpu=$(printf %.3f $(($(fgrep 'processor' /proc/cpuinfo | wc -l)/2)))
fi

$LXC init as $hostname

$LXC config set $hostname user.user-data - < $cur/cloud-init/user-data.yml

# network
$LXC config device add $hostname eth0 nic nictype=macvlan parent=$if

echo "network: {config: disabled}" > /tmp/$hostname.99-disable-network-config.cfg
$LXC file push /tmp/$hostname.99-disable-network-config.cfg $hostname/etc/cloud/cloud.cfg.d/99-disable-network-config.cfg

sed "s/%ADDRESS%/$ip/" $cur/cloud-init/50-cloud-init.yaml > /tmp/$hostname.50-cloud-init.yaml
$LXC file push /tmp/$hostname.50-cloud-init.yaml $hostname/etc/netplan/50-cloud-init.yaml

# idmap for users
cat << EOF | $LXC config set $hostname raw.idmap -
uid 30000-40000 30000-40000
uid 50000-60000 50000-60000
gid 30000 30000
gid 50000 50000
EOF

# mount disks
for dir in tools scratch opt/xilinx/platforms data ; do
    if [[ -e /$dir ]] ; then
        $LXC config device add $hostname $(basename $dir) disk source=$(readlink -f /$dir) path=/$dir
    fi
done

# mount autofs home
$LXC config device add $hostname home disk source=/home path=/home recursive=true

# for Docker
$LXC config set $hostname security.nesting=true security.syscalls.intercept.mknod=true security.syscalls.intercept.setxattr=true

# limit resource
$LXC config set $hostname limits.cpu $cpu
$LXC config set $hostname limits.memory ${mem}GB
$LXC config set $hostname limits.memory.enforce soft

# ssh host keys
key_dir=$cur/ssh-host-keys.$hostname
mkdir -p $key_dir
for t in rsa dsa ecdsa ed25519 ; do
    if [[ ! -e $key_dir/ssh_host_${t}_key ]] ; then
        ssh-keygen -q -t $t -f $key_dir/ssh_host_${t}_key -C "" -N ""
    fi
    $LXC file push $key_dir/ssh_host_${t}_key     $hostname/etc/ssh/ssh_host_${t}_key
    $LXC file push $key_dir/ssh_host_${t}_key.pub $hostname/etc/ssh/ssh_host_${t}_key.pub
done

$LXC start $hostname

echo Info: Started, date=$(date)

# Update /etc/subuid and /etc/subgid for rootless Docker
sleep 60
$LXC exec $hostname /usr/local/bin/update_subugids

