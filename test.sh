#!/usr/bin/env bash
set -ex

pushd docker
docker build -t acri-as:latest -f Dockerfile.vck5000 .
popd

#echo Info: $(date)

cur=$(dirname $(readlink -f $0))

# Get ID
if [[ $# -lt 2 ]] ; then
  echo Usage: $0 HOSTNAME IP [USER [NAME]]
  exit 1
fi
hostname=$1; shift

# Get user
user=$1
name=${2:-"user-$user"}
if [[ $user == "" ]] ; then
  # echo Info: No user for the next time slot
  name="no-user"
fi

repo=acri-as
tag=${TAG:-"latest"}
cmd="docker-entrypoint.sh"

# Start container
echo Info: Start user container: image=$repo:$tag, hostname=$hostname, ip=$ip, user=$user, name=$name, date=$(date)

phys_addr=$(/opt/xilinx/xrt/bin/xbutil examine | grep "xilinx_[uv]" | sed -r 's/.*\[([0-9:.]+).*/\1/')

# Clean
if [[ $name =~ ^user-.*$ ]] ; then
  # Clean
  rm -f /tmp/*.sshd_config
  rm -f /tmp/*.xrdp.ini

  # Reset FPGA
  #/usr/sbin/rmmod xclmgmt || true
  #/usr/sbin/rmmod xocl || true
  #/usr/sbin/modprobe xclmgmt
  #/usr/sbin/modprobe xocl
  #rmmod xclmgmt || true
  #rmmod xocl || true
  #modprobe xclmgmt
  #modprobe xocl
  #yes | /opt/xilinx/xrt/bin/xbutil reset --device $phys_addr > /dev/null
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
xocl=$(basename $(ls -d /sys/bus/pci/devices/$phys_addr/drm/renderD*))
xocl="/dev/dri/$xocl"
if [[ ! -e $xocl ]] ; then
  echo "Error: can't find xocl"
  exit 1
fi

xclmgmt=$(ls -1 /dev/xclmgmt* | head -n 1)
if [[ ! -e $xclmgmt ]] ; then
  echo "Error: can't find xclmgmt"
  exit 1
fi

#xvc=$(ls -1 /dev/xvc_* | head -n 1)
#if [[ ! -e $xclmgmt ]] ; then
#  echo "Error: can't find xvc"
#  exit 1
#fi

devices=""
for f in /dev/xfpga/* ; do
  devices="$devices --device=$f"
done

# Memory
if [[ $mem == "" ]] ; then
  mem=16
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
  $devices \
  -v /dev/xfpga:/dev/xfpga \
  --cpus=$cpu \
  --memory ${mem}g \
  --shm-size=2g \
  $repo:$tag \
  > /dev/null

echo Info: Started, date=$(date)

