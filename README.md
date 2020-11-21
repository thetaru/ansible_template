# ansible_template
# 進捗
```
・rhel8とwindow server 2019の大まかな基本設定は入る
・各ソフトウェアに関してはノータッチ(これからかな～)
・zabbix agentとかのエージェント系も入れてくれる感じのにしたい j2でipとかホスト名とか引っ張って終わりって感じかｎ
・windows srv 2019は1か所冪等性が保たれてないので改修
・win2019はwindows update問題もある(どのタイミングでupdateするの?ってやつ。専用のplaybook作る?)
・ubuntuとかもやる...?(気が向いたらかな)
・group変数のテンプレ汚いから清書すること
・タグ付けするのわすれてた個々のタスクにタグつけちゃえ
・あと変数名がとてもダサくてヤバイ
・ロールのタスクの順序そろえること。ロールのmain.ymlにタスクが何やってるかコメントで記載すること
--------------------------------------------------------------------------------------------------------------
・冪等性問題めんどいのでなるべく(shell command win_shell win_command以外の)モジュールつかいたいところ
```
# 必要そうな知識
http://tdoc.info/blog/2014/05/30/ansible_target_switching.html
## ■ 外部モジュールのインストール
```
# ansible-galaxy collection install ansible.windows
# pip3 install pywinrm
```
## ■ 事前準備
Linux_Setting.shを使う場合、`SSH_PASS`と`Ansible_PASS`はプロジェクトによって変更すること。
```
### 管理対象サーバ上でSetting.shを実行
### 注) ansible実行ユーザ(Ansible_USER=ansible)を変える場合はansible.cfgのremote_userの値も変更すること
# sh Setting.sh
```
## ■ 実行方法
```
# ansible-playbook main.yml
```
```
BECOME password: <ansible password>
```
## ■ サーバ追加時のヒント
### 1. hostsファイルを編集する
```
# vi inventory/hosts
```
```
+  [GROUP_NAME]
+  HOST_NAME ansible_host=<IP-ADDRESS>

[OS_NAME]
+  HOST_NAME
```
### 2. 新規グループ変数を定義する
テンプレートがある場合は以下のようにやるが、テンプレートがない場合は一から作ること。
```
# cp -p group_vars/_template_<OS_NAME>.yml group_vars/<GROUP_NAME>.yml
```
```
### 必要に応じて変数を変更する
# vi group_vars/<GROUP_NAME>.yml
```
### 3. 新規Playbookを定義する
```
# vi playbooks/<GROUP_NAME>.yml
```
```
---
- hosts: <GROUP_NAME>
  vars_files:
    - ../group_vars/<GROUP_NAME>.yml
  roles:
    - role: <Role_Name>
```
### 4. 作成したPlaybookをインポート
```
### プロジェクト直下のmain.yml
# vi main.yml
```
```
+  - import_playbook: ./playbooks/<GROUP_NAME>.yml
```
### 4. シェルの実行
#### Linuxの場合
```
# sh Linux-Setting.sh
```
#### Windowsの場合
```
> .\Windows-Setting.ps1
```
## ■ パスワード暗号化について
このテンプレートではパスワードの暗号化を施していないので暗号化の方法を以下に記す。
### 事前確認
```
### プロジェクト直下にいることを確認する
# pwd
```
```
/root/project
```
### 事前準備
```
### 復号用のパスワードを記載するファイルを作成
# mkdir group_vars/passwd
# touch group_vars/passwd/.vaultpass
# chmod 600 group_vars/passwd/.vaultpass
```
```
### 復号用のパスワードを記入
# echo "Password" > group_vars/passwd/.vaultpass
```
```
### 暗号化する変数を記載するファイルを作成
### 例としてansible_sudo_passなどを暗号化する
# vi group_vars/passwd/passwd.yml
```
```
+  ansible_sudo_pass: fuga
+  ansible_password: Password0
...
```
### 変数の暗号化
```
### 作成したパスワードをもとに変数を暗号化
# ansible-vault encrypt group_vars/passwd/passwd.yml --vault-password-file=group_vars/passwd/.vaultpass
```
```
Encryption successful
```
### ansible.cfgの編集
```
### 復号用パスワードの場所をansible.cfgに記載
# vi ansible.cfg
```
```
[defaults]
...
+  vault_password_file = ./group_vars/passwd/.vaultpass
```
### 既存設定の変更
```
### playbooks内の各playbookよりpasswd.ymlを変数として読み込む
### 以下を参考にしてください
# vi playbooks/BACKUP_SERVER.yml
```
```yml
---
- hosts: BACKUP_SERVER
  vars_files:
+   - ../group_vars/passwd.yml
    - ../group_vars/BACKUP_SERVER.yml
  roles:
    - role: common_windows_2019
```
```
### 暗号化した変数を使用する
# vi inventory/hosts
```
```
...
# For RHEL8
[RHEL8:vars]
ansible_user=ansible
ansible_sudo_pass="{{ ansible_sudo_pass }}"

# For Windows Server 2019
[WindowsServer2019:vars]
ansible_user=Administrator
ansible_password="{{ ansible_password }}"
ansible_connection=winrm
ansible_port=5986
ansible_winrm_server_cert_validation=ignore

ansible_become=yes
ansible_become_method=runas
ansible_become_user=Administrator
ansible_become_password="{{ ansible_password }}"
...
```
