#!/usr/bin/env bash

chown -hR $LOGIN_USER_UID:$LOGIN_USER_GID /opt/vitis_ai/workspace

/etc/init.d/rpcbind start
ypbind -broadcast

/etc/init.d/dbus start
/etc/init.d/xrdp start

/etc/init.d/ssh start
#/usr/sbin/sshd -D

/etc/init.d/xbutler start
