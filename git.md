### GIT 保存用户名密码到本地
~~~
git config --global credential.helper store
~~~

### GIT 保存姓名和邮箱
~~~
git config --global user.name [username]
git config --global user.email [email]
~~~

### 提交到远程仓库
~~~
git push origin test:master         // 提交本地test分支作为远程的master分支
git push origin test:test           // 提交本地test分支作为远程的test分支
~~~

### github pull request使用方法
* fork 原项目
* 把fork的项目克隆到本地
* 新建分支dev
* 将分支推送到远程dev
* 将本地的master的远程仓库指向 原项目
* 拉取原项目最新的代码到master
* 合并master到dev有冲突处理冲突
* 发起pull request 从dev到原项目
* 一旦对方merge项目
* 更新本地master并推到自己的远程master仓库

### git ssh 
* 设置Git的user name和email
~~~
$ git config --global user.name "limx"
$ git config --global user.email "limx@qq.com"
~~~

* 查看是否已经有了ssh密钥
~~~
cd ~/.ssh
如果没有密钥则不会有此文件夹，有则备份删除 
~~~
* 生存密钥
~~~
ssh-keygen -t rsa -C “limx@qq.com”
~~~
* 添加密钥到ssh
~~~
ssh-add id_rsa
~~~
* 在github上添加ssh密钥，这要添加的是“id_rsa.pub”里面的公钥