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

### git stash
~~~
git stash: 备份当前的工作区的内容，从最近的一次提交中读取相关内容，让工作区保证和上次提交的内容一致。同时，将当前的工作区内容保存到Git栈中。
git stash pop: 从Git栈中读取最近一次保存的内容，恢复工作区的相关内容。由于可能存在多个Stash的内容，所以用栈来管理，pop会从最近的一个stash中读取内容并恢复。
git stash list: 显示Git栈内的所有备份，可以利用这个列表来决定从那个地方恢复。
git stash clear: 清空Git栈。此时使用gitg等图形化工具会发现，原来stash的哪些节点都消失了。
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
* 生成密钥
~~~
ssh-keygen -t rsa -C “limx@qq.com”
~~~
* 添加密钥到ssh
~~~
ssh-add id_rsa
~~~
* 在github上添加ssh密钥，这要添加的是“id_rsa.pub”里面的公钥

### 新建仓库
* 在github或者git.oschina.net创建仓库
* 在本地新疆项目例如
~~~
composer create limingxinleo/phalcon-project　demo --prefer-dist
~~~
* 进入项目
~~~
cd demo
~~~
* 初始化仓库
~~~
git init
~~~
* 修改远程仓库
~~~
git remote add origin git@your.git.repo
~~~
* 暂存新代码
~~~
git add *
~~~
* 提交到本地
~~~
git commit -a -m "* INIT"
~~~
* 从远程拉取代码
~~~
git pull origin master
~~~
* 有冲突的话处理冲突
~~~
git add 冲突的文件
~~~
* 提交
~~~
git commit
~~~
* 提交到远程
~~~
git push --set-upstream origin master
~~~

### depth
拉取最新一次commit提交
~~~
git clone --depth=1 https://github.com/limingxinleo/simple-subcontrollers.phalcon.git
~~~
拉取所有历史
~~~
git fetch --unshallow
~~~