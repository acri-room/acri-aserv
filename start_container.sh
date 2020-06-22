#!/usr/bin/env bash
set -e

cur=$(dirname $(readlink -f $0))

# Get ID
if [[ $# -ne 1 ]] ; then
  echo Usage: $0 ID
  exit 1
fi
id=$1; shift

# Get user
hostname=$(printf "as%03d" $id)
user=$(ruby $cur/olb-read.rb $hostname)
if [[ $user == "" ]] ; then
  echo no user
  user=ando
fi

ip=172.16.6.$id
repo=acri-as
tag=14
#repo=ubuntu
#tag=18.04
name="user-$user"
#cmd="/bin/bash"
cmd="docker-entrypoint.sh"

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

# Check current container
container_exist=0
for id in $(docker ps -a --filter "name=user-" --format "{{.ID}}") ; do
  tmp=$(docker ps -a --filter "id=$id" --format "{{.Names}}")
  if [[ $tmp != "$name" ]] ; then
    echo Info: Stop user container: id=$id, name=$tmp
    docker rm -f $id
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

  # Create scratch area
  mkdir -p /scratch/$user
  chown $user /scratch/$user

  # Create sshd_config
  sshd_config=$(mktemp --suffix=.sshd_config)
  cp $cur/sshd_config.base $sshd_config
  echo AllowUsers $user >> $sshd_config

  # Create xrdp.ini
  xrdp_ini=$(mktemp --suffix=.xrdp.ini)
  chmod 644 $xrdp_ini
  sed "s/%USER%/$user/" $cur/xrdp.ini.base > $xrdp_ini

  docker run \
    -dit \
    --network net \
    --ip $ip \
    --name "$name" \
    --hostname $hostname \
    -v /scratch/$user:/scratch \
    -v /home/$user:/home/$user \
    -v /tools:/tools \
    -v $sshd_config:/etc/ssh/sshd_config \
    -v $xrdp_ini:/etc/xrdp/xrdp.ini \
    --device=$xclmgmt:$xclmgmt \
    --device=$xocl:$xocl \
    --cpus=14.000 \
    --memory 120g \
    $repo:$tag \
    $cmd
fi
