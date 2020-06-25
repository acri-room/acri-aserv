#!/usr/bin/env bash
set -e

cur=$(dirname $(readlink -f $0))

# Get ID
if [[ $# -lt 1 ]] ; then
  echo Usage: $0 ID [USER [NAME]]
  exit 1
fi
id=$1; shift

# Get user
hostname=$(printf "as%03d" $id)
user=${1:-$(ruby $cur/olb-read.rb $hostname)};
if [[ $user == "" ]] ; then
  echo No user
  exit
fi

ip=172.16.6.$id
repo=acri-as
tag=17
#repo=ubuntu
#tag=18.04
name=${2:-"user-$user"};
#cmd="/bin/bash"
cmd="docker-entrypoint.sh"
scratch_max_size=$((512*1024*1024*1024)) # 512GB

echo Info: $(date)
echo Info: image=$repo:$tag, hostname=$hostname, ip=$ip, user=$user, name=$name

# Check current container
container_exist=0
for id in $(docker ps -a --filter "name=user-" --format "{{.ID}}") ; do
  tmp=$(docker ps -a --filter "id=$id" --format "{{.Names}}")
  if [[ $tmp != "$name" ]] ; then
    echo Info: Stop user container: id=$id, name=$tmp
    docker rm -f $id > /dev/null
  else
    echo Info: User container is already running: id=$id, name=$tmp
    container_exist=1
  fi
done

# Start container
if [ $container_exist -eq 0 ] ; then
  echo Info: Start user container: name=$name

  # Mount user home
  ls /home/$user > /dev/null

  # Clean scratch area
  mkdir -p /scratch
  while [ $(du -s /scratch | awk '{print $1}') -gt $scratch_max_size ] ; do
    rmdir=/scratch/$(ls -1rt /scratch | head -n 1)
    echo Info: Remove $rmdir
    rm -r $rmdir
    sleep 1
  done

  # Create scratch area
  mkdir -p /scratch/$user
  chown $user /scratch/$user
  touch /scratch/$user/.start

  # Clean
  rm -f /tmp/*.sshd_config
  rm -f /tmp/*.xrdp.ini

  # Create sshd_config
  sshd_config=$(mktemp --suffix=.sshd_config)
  cp $cur/sshd_config.base $sshd_config
  echo AllowUsers $user >> $sshd_config

  # Create xrdp.ini
  xrdp_ini=$(mktemp --suffix=.xrdp.ini)
  chmod 644 $xrdp_ini
  sed "s/%USER%/$user/" $cur/xrdp.ini.base > $xrdp_ini

  # Reset FPGA
  rmmod xclmgmt
  rmmod xocl
  modprobe xclmgmt
  modprobe xocl
  yes | /opt/xilinx/xrt/bin/xbutil reset > /dev/null

  # Find driver
  xocl=$(/opt/xilinx/xrt/bin/xbutil scan | grep "xilinx_u" | sed -r 's/^.*inst=([0-9]*).*/\1/')
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

  docker run \
    -dit \
    --network net \
    --ip $ip \
    --name "$name" \
    --hostname $hostname \
    -v /scratch/$user:/scratch \
    -v /home/$user:/home/$user \
    -v /tools:/tools \
    -v /opt/xilinx/platforms:/opt/xilinx/platforms \
    -v $sshd_config:/etc/ssh/sshd_config \
    -v $xrdp_ini:/etc/xrdp/xrdp.ini \
    --device=$xclmgmt:$xclmgmt \
    --device=$xocl:$xocl \
    --cpus=14.000 \
    --memory 120g \
    $repo:$tag \
    $cmd > /dev/null

  echo Info: Started
fi
