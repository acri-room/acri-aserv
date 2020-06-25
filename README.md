Setup
=====

```
$ sudo su
# cd /root
# git clone https://github.com/acri-room/acri-aserv.git
# crontab -e
start_container.shに渡す番号を変更すること
```

Maintenance
===========
```
# ./start_container.sh 102 ando maintenance
IP:172.16.6.102でメンテナンス用のコンテナが起動する
このコンテナはcronにより停止されない
作業後に新しいtagでコミットして、start_container.sh内のtagを書き換える
次回以降、コンテナが新しいイメージで起動する
```
