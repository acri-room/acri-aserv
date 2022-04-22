#!/usr/bin/env bash

# Usage
if [[ $# -lt 2 ]] ; then
  echo Usage: $0 HOSTNAME IP [USER [NAME]]
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
  exit 1
fi
function error_handler() {
  #echo error handler
  rmdir $lockfile
  exit 1
}
trap error_handler ERR

# Exit on error
set -e

# Get user
cur=$(dirname $(readlink -f $0))
user=${1:-$(ruby $cur/olb-read.rb $hostname)};
name=${2:-"user-$user"};
if [[ $user == "" ]] ; then
  # echo Info: No user for the next time slot
  name="no-user"
fi

repo=acri-as
tag=${TAG:-"latest"}
#repo=ubuntu
#tag=18.04
#cmd="/bin/bash"
cmd="docker-entrypoint.sh"
scratch_max_size=$((256*1024*1024*1024)) # 256GB

container_exist=0
if [[ $name =~ ^user-.*$ ]] || [[ $user == "" ]] ; then
  # Check existing container and stop
  for id in $(docker ps -a --filter "name=user-" --format "{{.ID}}") ; do
    tmp=$(docker ps -a --filter "id=$id" --format "{{.Names}}")
    if [[ $tmp != "$name" ]] ; then
      echo Info: Stop user container: id=$id, name=$tmp, date=$(date)
      docker rm -f $id > /dev/null
    else
      stat=$(docker inspect --format='{{.State.Status}}' $id)
      if [[ $stat == "running" ]] ; then
        #echo Info: User container is already running: id=$id, name=$tmp
	container_exist=1
      else
        echo Info: Remove exited user container : id=$id, name=$tmp, date=$(date)
	docker rm -f $id > /dev/null
      fi
    fi
  done
fi

# No need to start container
if [ $container_exist -eq 1 ] ; then
  exit
fi

# No user
if [[ $user == "" ]] ; then
  exit
fi

# Start container
echo Info: Start user container: image=$repo:$tag, hostname=$hostname, ip=$ip, user=$user, name=$name, date=$(date)

# Clean
if [[ $name =~ ^user-.*$ ]] ; then
  # Clean scratch area
  mkdir -p /scratch
  while [ $(du -s /scratch | awk '{print $1}') -gt $scratch_max_size ] ; do
    rmdir=/scratch/$(ls -1rt /scratch | head -n 1)
    echo Info: Remove $rmdir
    rm -r $rmdir
    sleep 1
  done
  
  # Clean
  rm -f /tmp/*.sshd_config
  rm -f /tmp/*.xrdp.ini

  # Reset FPGA
  /usr/sbin/rmmod xclmgmt || true
  /usr/sbin/rmmod xocl || true
  /usr/sbin/modprobe xclmgmt
  /usr/sbin/modprobe xocl
  for addr in $(lspci -D -d 10ee: -s .0 | awk '{print $1}') ; do
    /opt/xilinx/xrt/bin/xbmgmt reset --device $addr --force > /dev/null
  done
  for addr in $(lspci -D -d 10ee: -s .1 | awk '{print $1}') ; do
    /opt/xilinx/xrt/bin/xbutil reset --device $addr --force > /dev/null
  done
fi

# Mount user home
ls /home/$user > /dev/null 2>&1 || true

# Create scratch area
mkdir -p /scratch/$user
chown $user /scratch/$user
chmod 700 /scratch/$user
touch /scratch/$user/.start

# Create sshd_config
sshd_config=$(mktemp --suffix=.sshd_config)
cp $cur/sshd_config.base $sshd_config
echo AllowUsers $user >> $sshd_config

# Create xrdp.ini
xrdp_ini=$(mktemp --suffix=.xrdp.ini)
chmod 644 $xrdp_ini
sed "s/%USER%/$user/" $cur/xrdp.ini.base > $xrdp_ini

# Find driver
xocl=$(/opt/xilinx/xrt/bin/xbutil examine | grep "xilinx_[uv]" | sed -r 's/^.*inst=([0-9]*).*/\1/')
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

xvc=$(ls -1 /dev/xvc_* 2> /dev/null | head -n 1)
if [[ ! -e $xvc ]] ; then
  xvc=
else
  xvc="--device=$xvc"
fi

devices=""
for f in /dev/xfpga/* ; do
  devices="$devices --device=$f"
done

# Memory
if [[ $mem == "" ]] ; then
  mem=120
fi

# CPU
if [[ $cpu == "" ]] ; then
  # Default: Available cores - 2
  cpu=$(printf %.3f $(($(fgrep 'processor' /proc/cpuinfo | wc -l)-2)))
fi

# for gserv1
mounts=
if [[ -e /tools2/Xilinx ]] ; then
  mounts="$mounts -v /tools2/Xilinx:/tools2/Xilinx"
fi

docker run \
  -dit \
  --network net \
  --ip $ip \
  --name "$name" \
  --hostname $hostname \
  --cap-add=SYS_PTRACE \
  --security-opt="seccomp=unconfined" \
  -v /scratch/$user:/scratch \
  -v /home/$user:/home/$user \
  -v /tools:/tools \
  -v /opt/xilinx/platforms:/opt/xilinx/platforms \
  $mounts \
  -v $sshd_config:/etc/ssh/sshd_config \
  -v $xrdp_ini:/etc/xrdp/xrdp.ini \
  -v $cur/docker-entrypoint.sh:/usr/local/bin/docker-entrypoint.sh \
  -e LOGIN_USER=$user \
  -e LOGIN_USER_UID=$(id -u $user) \
  -e LOGIN_USER_GID=$(id -g $user) \
  --device=$xclmgmt \
  --device=$xocl \
  $xvc \
  $devices \
  -v /dev/xfpga:/dev/xfpga \
  --cpus=$cpu \
  --memory ${mem}g \
  --shm-size=2g \
  $repo:$tag \
  > /dev/null

echo Info: Started, date=$(date)

rmdir $lockfile
