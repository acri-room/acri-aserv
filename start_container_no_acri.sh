#!/usr/bin/env bash
set -ex

cur=$(dirname $(readlink -f $0))

hostname=${1:-"xilinx"}
user=${2:-"user"}
name=${3:-"user-$user"}
if [[ $user == "" ]] ; then
  # echo Info: No user for the next time slot
  name="no-user"
fi

repo=acri-as
tag=${TAG:-"latest"}
cmd="docker-entrypoint.sh"

docker rm -f $name || true

# Start container
echo Info: Start user container: image=$repo:$tag, hostname=$hostname, user=$user, name=$name, date=$(date)

phys_addr=$(/opt/xilinx/xrt/bin/xbutil examine | grep "xilinx_[uv]" | sed -r 's/.*\[([0-9:.]+).*/\1/')

# Clean
#if [[ $name =~ ^user-.*$ ]] ; then
#  # Reset FPGA
#  sudo rmmod xclmgmt || true
#  sudo rmmod xocl || true
#  sudo modprobe xclmgmt
#  sudo modprobe xocl
#  for addr in $(lspci -D -d 10ee: -s .0 | awk '{print $1}') ; do
#    sudo /opt/xilinx/xrt/bin/xbmgmt reset --device $addr --force > /dev/null
#  done
#  for addr in $(lspci -D -d 10ee: -s .1 | awk '{print $1}') ; do
#    sudo /opt/xilinx/xrt/bin/xbutil reset --device $addr --force > /dev/null
#  done
#fi

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

docker run \
  -dit \
  --name "$name" \
  --hostname $hostname \
  --network host \
  --cap-add=SYS_PTRACE \
  --security-opt="seccomp=unconfined" \
  -v /tools:/tools \
  -v /tools2:/tools2 \
  -v /opt/xilinx/platforms:/opt/xilinx/platforms \
  -v $cur/docker-entrypoint.sh:/usr/local/bin/docker-entrypoint.sh \
  -e LOGIN_USER=$user \
  -e LOGIN_USER_UID=1000 \
  -e LOGIN_USER_GID=1000 \
  --device=$xclmgmt \
  --device=$xocl \
  $xvc \
  $devices \
  -v /dev/xfpga:/dev/xfpga \
  --shm-size=2g \
  $repo:$tag \
  > /dev/null

echo Info: Started, date=$(date)

