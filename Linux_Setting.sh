#!/bin/bash
####################################################################################################
#
# VARIABLE
#
####################################################################################################

### 対象サーバのホスト名またはIPアドレス
read -p "対象サーバの名前解決のできるホスト名またはIPアドレスを入力してください: " SSH_HOST

####################################################################################################
#
# CONST
#
####################################################################################################

### ログインユーザ
SSH_USER=root

### ログインパスワード
SSH_PASS=hoge

### Ansibleユーザ
Ansible_USER=ansible

### Ansibleパスワード
Ansible_PASS=fuga

####################################################################################################
#
# MAIN
#
####################################################################################################

### 疎通失敗
ping ${SSH_HOST} -w 2 -c 1 &> /dev/null
if [[ $? -ne 0 ]]; then
  echo "対象サーバ(${SSH_HOST})と疎通ができませんでした。"
  exit
fi

### 鍵作成
if [[ ! -e /root/.ssh/id_rsa || ! -e /root/.ssh/id_rsa.pub ]]; then
  ssh-keygen -q -t rsa -b 2048 -N "" -f /root/.ssh/id_rsa
  chmod 600 /root/.ssh/id_rsa
fi

### Ansible用ユーザの作成
sshpass -p "${SSH_PASS}" ssh -o StrictHostKeyChecking=no ${SSH_USER}@${SSH_HOST} "id ${Ansible_USER} &> /dev/null"
if [[ $? -eq 0 ]]; then
  sshpass -p "${SSH_PASS}" ssh -o StrictHostKeyChecking=no ${SSH_USER}@${SSH_HOST} "usermod -aG wheel ${Ansible_USER} && echo ${Ansible_PASS} | passwd --stdin ${Ansible_USER}"
else
  sshpass -p "${SSH_PASS}" ssh -o StrictHostKeyChecking=no ${SSH_USER}@${SSH_HOST} "useradd -G wheel ${Ansible_USER} && echo ${Ansible_PASS} | passwd --stdin ${Ansible_USER}"
fi

### 公開鍵配布
echo "公開鍵を配布中..."
sshpass -p "${Ansible_PASS}" ssh-copy-id -f -o StrictHostKeyChecking=no -i /root/.ssh/id_rsa.pub ${Ansible_USER}@${SSH_HOST} 1> /dev/null
if [[ $? -eq 0 ]]; then
  echo "公開鍵の配布に成功しました"
else
  echo "公開鍵の配布に失敗しました"
  exit
fi

### known_hostsから対象サーバを削除
sed -i "/^${SSH_HOST}/d" /root/.ssh/known_hosts
