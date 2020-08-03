Setup
=====

```
$ sudo su
# cd /root
# git clone https://github.com/acri-room/acri-aserv.git
# cd acri-aserv/docker

U50搭載サーバー
# docker build -t acri-as:latest -f Dockerfile.u50 .

U280-ES1搭載サーバー
# docker build -t acri-as:latest -f Dockerfile.u280-es1 .

U200/U250搭載サーバー
# docker build -t acri-as:latest -f Dockerfile .

# crontab -e
start_container.shに渡す番号を変更すること
```

ユーザーを指定して手動で起動する方法
===============
```
# ./start_container.sh as001 172.16.6.1 ando
他のユーザーのコンテナが起動していたら停止する
```

Maintenance
===========
```
# ./start_container.sh as102 172.16.6.102 ando maintenance
IP:172.16.6.102でメンテナンス用のコンテナが起動する
このスクリプト実行でユーザーコンテナの停止、スクラッチ領域の掃除、FPGAリセットは行われない（ユーザーが利用中でも影響しない）
このコンテナはcronにより停止されない
作業後に新しいtagでコミットして、start_container.sh内のtagを書き換える
次回以降、コンテナが新しいイメージで起動する
```
