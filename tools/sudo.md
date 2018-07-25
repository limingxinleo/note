## sudo

### 子账户sudo免密码
~~~
$ chmod u+w /etc/sudoers
$ vim /etc/sudoers
# 增加一行
www	ALL=(ALL) 	NOPASSWD: ALL
$ chmod u-w /etc/sudoers
~~~