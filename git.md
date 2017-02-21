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