#!/usr/bin/env bash
set -e

#echo Info: $(date)

cur=$(dirname $(readlink -f $0))

# Get ID
if [[ $# -lt 2 ]] ; then
  echo Usage: $0 HOSTNAME IP
  exit 1
fi
hostname=$1; shift
ip=$1; shift
name=tool

repo=acri-as-tool
tag=${TAG:-"latest"}
#repo=ubuntu
#tag=18.04
#cmd="/bin/bash"
cmd="docker-entrypoint.sh"

container_exist=0
# Check existing container and stop
for id in $(docker ps -a --filter "name=tool" --format "{{.ID}}") ; do
  tmp=$(docker ps -a --filter "id=$id" --format "{{.Names}}")
  if [[ $tmp == $name ]] ; then
    stat=$(docker inspect --format='{{.State.Status}}' $id)
    if [[ $stat == "running" ]] ; then
      # echo Info: Tool container is already running: id=$id, name=$tmp
      container_exist=1
    else
      echo Info: Remove exited tool container : id=$id, name=$tmp, date=$(date)
      docker rm -f $id > /dev/null
    fi
  fi
done

# No need to start container
if [ $container_exist -eq 1 ] ; then
  exit
fi

# Start container
echo Info: Start tool container: image=$repo:$tag, hostname=$hostname, ip=$ip, name=$name, date=$(date)

# Memory
if [[ $mem == "" ]] ; then
  mem=60
fi

# CPU
if [[ $cpu == "" ]] ; then
  # Default: Available cores / 2
  cpu=$(printf %.3f $(($(fgrep 'processor' /proc/cpuinfo | wc -l)/2)))
fi

docker run \
  -dit \
  --network net \
  --ip $ip \
  --name "$name" \
  --hostname $hostname \
  --cap-add=SYS_PTRACE \
  --security-opt="seccomp=unconfined" \
  -v /scratch:/scratch \
  -v /home:/home:shared \
  -v /tools:/tools \
  -v /opt/xilinx/platforms:/opt/xilinx/platforms \
  -v $cur/docker-entrypoint.sh:/usr/local/bin/docker-entrypoint.sh \
  -v $cur/count-users.sh:/usr/local/bin/count-users.sh \
  --cpus=$cpu \
  --memory ${mem}g \
  --shm-size=2g \
  $repo:$tag \
  > /dev/null

echo Info: Started, date=$(date)
