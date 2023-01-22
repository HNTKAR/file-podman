# はじめに
環境は以下の状態を想定する
|名称|値|
|:-:|:-:|
|ポッド名|file|
|コンテナ名|samba|
|イメージ名:バージョン|samba:1.0|
|sambaの設定ファイル|Config/smb.conf|
|sambaで共有したいフォルダ|/home/podman/file|

samba-serverの実行に必要な権限は下記の通りである。

- CAP_DAC_OVERRIDE
- CAP_NET_BIND_SERVICE
- CAP_SETGID
- CAP_SETUID

# 実行スクリプト

## samba

```bash
cd file_podman

# ボリュームの作成
sudo podman volume create file_samba_conf
sudo podman volume create file_samba_log

# イメージのビルド
sudo podman build --build-arg CONFIG_FILE=Config/smb.conf --tag samba:1.0 --file samba/Dockerfile .

# ポッドの作成
sudo podman pod create --publish 138:138/udp --publish 139:139/tcp --publish 445:445/tcp --name file

# コンテナの実行
sudo podman run --detach --replace --mount type=bind,source=/home/podman/file,destination=/data --mount type=volume,source=file_samba_conf,destination=/var/lib/samba/private --mount type=volume,source=file_samba_log,destination=/var/log/samba --pod file --name samba samba:1.0
```

## nginx
```bash
cd file_podman

# ボリュームの作成
sudo podman volume create file_samba_conf
sudo podman volume create file_samba_log

# イメージのビルド
podman build --build-arg CONFIG_FILE=Config/nextcloud.conf --build-arg NEXTCLOUD_DATA=Config/latest.tar.bz2 --tag nginx:1.0 --file nginx/Dockerfile .

# ポッドの作成
podman pod create --replace --publish 1180:80/tcp --publish 11443:443/tcp --name file

# コンテナの実行
podman run --detach --replace --mount type=volume,source=certbot_dir,destination=/etc/ssl --mount type=bind,source=/home/podman/file,destination=/data --pod file --name nginx nginx:1.0
```
# 自動起動の設定
```
sudo podman generate systemd -f -n --new --restart-policy=always file >tmp.service
cat tmp.service | \
xargs -I {} sudo cp {} -frp /etc/systemd/system/
sed -e "s/.*\///g" tmp.service | \
grep pod | \
xargs -n 1 sudo systemctl --now enable
```

# 自動起動解除
```
sed -e "s/.*\///g" tmp.service | \
grep pod | \
xargs -n 1 sudo systemctl --now disable
```
