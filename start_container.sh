#!/usr/bin/env bash
set -x

# Usage
if [[ $# -lt 2 ]] ; then
    echo Usage: $0 HOSTNAME IP [USER]
    exit 1
fi

cur=$(dirname $(readlink -f $0))

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
user=
if [[ $share != "true" ]] ; then
    user=${1:-$(ruby $cur/olb-read.rb $hostname)};
fi

# Scratch area size
if [[ -z $scratch_gb ]] ; then
    scratch_gb=256
fi
scratch_max_size=$(($scratch_gb*1024*1024*1024))

# lxc
LXC=/snap/bin/lxc

# Check running container
container_status=$($LXC ls -f json | jq -rj ".[] | select(.name == \"$hostname\") | .status")
container_user=$($LXC ls -f json | jq -rj ".[] | select(.name == \"$hostname\") | .config[\"user.acri-user\"]")

# Check if container is already running
if [[ $container_status == "Running" ]] && [[ $share == "true" ]] ; then
    #echo Info: Tool container is already running
    exit
elif [[ $container_status == "Running" ]] && [[ $container_user == $user ]] ; then
    #echo Info: User container is already running
    exit
elif [[ -n $container_status ]] ; then
    echo Info: Stop user container: name=$hostname, date=$(date)
    $LXC stop $hostname --force > /dev/null 2>&1 || true
    $LXC delete $hostname --force > /dev/null 2>&1 || true
fi

# No user for this timeslot
if [[ $share != "true" ]] && [[ -z $user ]] ; then
    exit
fi

# Start container
echo Info: Start container: image=$hostname, hostname=$hostname, ip=$ip, user=$user, date=$(date)

if [[ $share != "true" ]] ; then
    # Check XRT version
    if [[ $driver == "xrt" ]] ; then
        xrt_ver=$(/opt/xilinx/xrt/bin/xbutil --version | grep -i version | head -n 1 | awk '{print $NF}')
        if [[ $xrt_ver = "`echo -e \"$xrt_ver\n2.11.634\" | sort -V | head -n 1`" ]] ; then
            # <= 2021.1
            xrt_ver=1
        else
            # >= 2021.2
            xrt_ver=2
        fi
    fi

    # Clean scratch area
    mkdir -p /scratch
    while [ $(du -s /scratch | awk '{print $1}') -gt $scratch_max_size ] ; do
        rmdir=/scratch/$(ls -1rt /scratch | head -n 1)
        echo Info: Remove $rmdir
        rm -r $rmdir
        sleep 1
    done

    # Reset FPGA
    LSPCI=/usr/bin/lspci
    if [[ ! -e $LSPCI ]] ; then
        LSPCI=/usr/sbin/lspci
    fi
    
    if [[ $driver == "xrt" ]] ; then
        if [[ -z $SKIP_FPGA_RESET ]] ; then
            if [[ $(hostname -s) != aserv5 ]] ; then
                /usr/sbin/rmmod xocl || true
                /usr/sbin/rmmod xclmgmt || true
                /usr/sbin/modprobe xclmgmt
            
                if [[ $xrt_ver -eq 1 ]] ; then
                    /usr/sbin/modprobe xocl
                    yes | /opt/xilinx/xrt/bin/xbutil reset > /dev/null
                else
                    for addr in $($LSPCI -D -d 10ee: -s .0 | awk '{print $1}') ; do
                        /opt/xilinx/xrt/bin/xbmgmt reset --device $addr --force > /dev/null
                    done
                    /usr/sbin/modprobe xocl
                    for addr in $($LSPCI -D -d 10ee: -s .1 | awk '{print $1}') ; do
                        /opt/xilinx/xrt/bin/xbutil reset --device $addr --force > /dev/null
                    done
                fi
            else
                for addr in $($LSPCI -D -d 10ee: -s .1 | awk '{print $1}') ; do
                    /opt/xilinx/xrt/bin/xbutil reset --device $addr --force > /dev/null
                done
            fi
        fi
    fi

    # Create scratch area
    mkdir -p /scratch/$user
    chown $user /scratch/$user
    chmod 700 /scratch/$user
    touch /scratch/$user/.start

    # Create sshd_config
    cp $cur/sshd_config /tmp/$hostname.sshd_config
    echo AllowUsers $user >> /tmp/$hostname.sshd_config
    
    # Create xrdp.ini
    sed "s/%USER%/$user/" $cur/xrdp.ini | sed "s/%HOST%/$hostname/" > /tmp/$hostname.xrdp.ini
    chmod 644 /tmp/$hostname.xrdp.ini
    
    # Find driver
    if [[ $driver == "xrt" ]] ; then
        if [[ $xrt_ver -eq 1 ]] ; then
            xocl=$(/opt/xilinx/xrt/bin/xbutil scan | grep "xilinx_[uv]" | sed -r 's/^.*inst=([0-9]*).*/\1/')
        else
            xocl=$(/opt/xilinx/xrt/bin/xbutil examine | grep "xilinx_[uv]" | sed -r 's/^.*inst=([0-9]*).*/\1/')
        fi
        xocl="/dev/dri/renderD$xocl"
        if [[ ! -e $xocl ]] ; then
            echo "Error: can't find xocl"
            exit 1
        fi
        
        xclmgmt=$(ls -1 /dev/xclmgmt* | head -n 1)
        if [[ ! -e $xclmgmt ]] ; then
            echo "Error: can't find xclmgmt"
            exit 1
        fi
    fi
fi

# Memory
if [[ -z $mem ]] ; then
    mem=120
fi

# CPU
if [[ -z $cpu ]] ; then
    # Default: Available cores - 2
    cpu=$(printf %.3f $(($(fgrep 'processor' /proc/cpuinfo | wc -l)-2)))
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
render_gid=$(getent group render | awk -F: '{print $3}')
video_gid=$(getent group video | awk -F: '{print $3}')
cat << EOF | $LXC config set $hostname raw.idmap -
uid 30000-40000 30000-40000
uid 50000-60000 50000-60000
gid $render_gid 110
gid $video_gid 44
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

# mount devices
if [[ $driver == "xrt" ]] ; then
    $LXC config device add $hostname xfpga   disk      source=/dev/xfpga path=/dev/xfpga
    $LXC config device add $hostname xocl    unix-char source=$xocl path=$xocl mode=0666
    $LXC config device add $hostname xclmgmt unix-char source=$xclmgmt path=$xclmgmt mode=0666
elif [[ $driver == "rocm" ]] ; then
    $LXC config device add $hostname kfd disk source=/dev/kfd path=/dev/kfd
    $LXC config device add $hostname dri disk source=/dev/dri path=/dev/dri
fi

# for Docker
$LXC config set $hostname security.nesting=true security.syscalls.intercept.mknod=true security.syscalls.intercept.setxattr=true

# limit resource
$LXC config set $hostname limits.cpu $cpu
$LXC config set $hostname limits.memory ${mem}GB
$LXC config set $hostname limits.memory.enforce soft

if [[ $share != "true" ]] ; then
    # limit login user
    $LXC file push /tmp/$hostname.sshd_config $hostname/etc/ssh/sshd_config
    $LXC file push /tmp/$hostname.xrdp.ini $hostname/etc/xrdp/xrdp.ini
fi

# set config
$LXC config set $hostname user.acri-user "$user"

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

# Add environment variables
$LXC file pull $hostname/etc/environment /tmp/$hostname.environment
echo 'PIP_INDEX_URL="http://172.16.2.9:3141/root/pypi/+simple/"' >> /tmp/$hostname.environment
echo 'PIP_TRUSTED_HOST=172.16.2.9' >> /tmp/$hostname.environment
echo 'PIP_NO_CACHE_DIR=1' >> /tmp/$hostname.environment
$LXC file push /tmp/$hostname.environment $hostname/etc/environment

# Wait
sleep 60

# Add user to render and video group
if [[ $driver == "rocm" ]] ; then
    $LXC exec $hostname -- usermod -a -G render,video $user
fi

# Update /etc/subuid and /etc/subgid for rootless Docker
$LXC file push ./ansible/roles/docker/files/update_subugids.py $hostname/usr/local/bin/update_subugids
$LXC exec $hostname -- rm /etc/subuid
$LXC exec $hostname -- rm /etc/subgid
$LXC exec $hostname -- touch /etc/subuid
$LXC exec $hostname -- touch /etc/subgid
# Map render group
$LXC exec $hostname -- /usr/local/bin/update_subugids --gid-maps 110:109

$LXC exec $hostname -- mkdir -p /opt/xilinx/dsa
$LXC exec $hostname -- mkdir -p /opt/xilinx/overlaybins

