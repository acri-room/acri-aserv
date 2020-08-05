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
crontabファイルを参照
```

ユーザーを指定して手動で起動する方法
===============
```
# ./start_container.sh as001 172.16.6.1 ando
他のユーザーのコンテナが起動していたら落としてしまうので注意！
```

メンテナス方法
===============
+ Dockerfileを編集する
+ acri-as:testでDockerイメージをビルドする
+ acri-as:testでDockerを起動し（今のところ手動で）動作を確認する
+ 問題なければacri-as:latestでビルドする（次回以降の起動時に新しいイメージが使われる）

テスト
======
```
# ./start_container.sh as102 172.16.6.102 ando test
4つ目の引数にコンテナの名前を指定する。
IP:172.16.6.102でメンテナンス用のコンテナが起動する
このスクリプト実行でユーザーコンテナの停止、スクラッチ領域の掃除、FPGAリセットは行われない（ユーザーが利用中でも影響しない）
このコンテナはcronにより停止されない
```
