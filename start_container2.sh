#!/usr/bin/env bash
set -e

echo Info: $(date)

cur=$(dirname $(readlink -f $0))

# Get ID
if [[ $# -lt 2 ]] ; then
  echo Usage: $0 HOSTNAME IP [USER [NAME]]
  exit 1
fi
hostname=$1; shift
ip=$1; shift

# Get user
user=${1:-$(ruby $cur/olb-read.rb $hostname)};
name=${2:-"user-$user"};
if [[ $user == "" ]] ; then
  echo Info: No user for the next time slot
  name="no-user"
fi

repo=acri-as
tag=latest
#repo=ubuntu
#tag=18.04
#cmd="/bin/bash"
cmd="docker-entrypoint.sh"
scratch_max_size=$((256*1024*1024*1024)) # 256GB

container_exist=0
if [[ $name != "maintenance" ]] ; then
  # Check existing container and stop
  for id in $(docker ps -a --filter "name=user-" --format "{{.ID}}") ; do
    tmp=$(docker ps -a --filter "id=$id" --format "{{.Names}}")
    if [[ $tmp != "$name" ]] ; then
      echo Info: Stop user container: id=$id, name=$tmp
      docker rm -f $id > /dev/null
    else
      stat=$(docker inspect --format='{{.State.Status}}' $id)
      if [[ $stat == "running" ]] ; then
        echo Info: User container is already running: id=$id, name=$tmp
	container_exist=1
      else
        echo Info: Remove exited user container : id=$id, name=$tmp
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
echo Info: Start user container: image=$repo:$tag, hostname=$hostname, ip=$ip, user=$user, name=$name

# Clean
if [[ $name != "maintenance" ]] ; then
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
  /usr/sbin/rmmod xclmgmt
  /usr/sbin/rmmod xocl
  /usr/sbin/modprobe xclmgmt
  /usr/sbin/modprobe xocl
  yes | /opt/xilinx/xrt/bin/xbutil reset > /dev/null
fi

# Mount user home
ls /home/$user > /dev/null 2>&1 || true

# Create scratch area
mkdir -p /scratch/$user
chown $user /scratch/$user
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
  -v $cur/docker-entrypoint2.sh:/usr/local/bin/docker-entrypoint.sh \
  -e LOGIN_USER=$user \
  -e LOGIN_USER_UID=$(id -u $user) \
  -e LOGIN_USER_GID=$(id -g $user) \
  --device=$xclmgmt:$xclmgmt \
  --device=$xocl:$xocl \
  --cpus=$(printf %.3f $(($(fgrep 'processor' /proc/cpuinfo | wc -l)-2))) \
  --memory 120g \
  $repo:$tag

echo Info: Started
