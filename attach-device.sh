#/usr/bin/env bash

if [ $# -ne 2 ] ; then
  exit
fi

major=$1
minor=$2

for d in /sys/fs/cgroup/devices/docker/*/devices.allow ; do
  echo "c $major:$minor rwm" > $d
done
