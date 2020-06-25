#!/usr/bin/env bash

if [[ $LOGIN_USER != "" ]] ; then
  chown -hR $(id -u $LOGIN_USER):$(id -g $LOGIN_USER) /opt/vitis_ai/workspace
fi

/etc/init.d/rpcbind start
ypbind -broadcast

/etc/init.d/dbus start
/etc/init.d/xrdp start

/etc/init.d/ssh start
#/usr/sbin/sshd -D

/etc/init.d/xbutler start
