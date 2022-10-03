Setup
=====

```
# git clone https://github.com/acri-room/acri-aserv.git
# cd acri-aserv
# ./build.sh

# crontab -e
crontabファイルを参照
```

Enable hardware profiling
=========================

```
# cp 12-xocl-docker.rules /etc/udev/rules.d/12-xocl-docker.rules
# udevadm control --reload-rules && udevadm trigger
```
