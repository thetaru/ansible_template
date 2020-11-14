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
# 外部モジュールのインストール
```
# ansible-galaxy collection install ansible.windows
```
# 事前準備
Setting.shの`SSH_PASS`と`Ansible_PASS`はプロジェクトによって変更すること。
```
### 管理対象サーバ上でSetting.shを実行
### 注) ansible実行ユーザ:ansibleを変える場合はansible.cfgのremote_userの値も変更すること
# sh Setting.sh
```
# 実行方法
```
# ansible-playbook main.yml
```
```
BECOME password: <ansible password>
```
# 更新時のヒント
```
1. inventory/hostsを編集する
2. 追加したグループ名と同名のグループ変数ファイルをgroup_vars下に作成する
3. 追加したグループ名と同名のplaybookファイルをplaybooks下に作成する
```
