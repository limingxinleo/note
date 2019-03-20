## SSH 
### 免密码登录
1.首先生成id_rsa 和 id_rsa.pub
~~~
ssh-keygen -t rsa -C "limx@qq.com"
~~~

2.上传id_rsa.pub到服务器

3.将公钥加入到.ssh/authorized_keys
~~~
cd ~
cat id_rsa.pub >> .ssh/authorized_keys
chmod 600 .ssh/authorized_keys
~~~

### ssh 携带其他公钥登录
~~~bash
ssh -i /var/jenkins_home/.ssh/id_rsa root@192.168.0.1
~~~

### StrictHostKeyChecking

当我们用ssh连接到其他linux平台时，会遇到以下提示：

The authenticity of host ‘git.sws.com (10.42.1.88)’ can’t be established. 
ECDSA key fingerprint is 53:b9:f9:30:67:ec:34:88:e8:bc:2a:a4:6f:3e:97:95. 
Are you sure you want to continue connecting (yes/no)? yes 
而此时必须输入yes，连接才能建立。

但其实我们可以在ssh_config配置文件中配置此项，
~~~
打开/etc/ssh/ssh_config文件
将 StrictHostKeyChecking ask 修改为 StrictHostKeyChecking no 并删除前面的注释符
这个选项会自动的把 想要登录的机器的SSH pub key 添加到 /root/.ssh/know_hosts 中。
~~~

### 非root账号登录
~~~
su - www
ssh-keygen
# 将Jenkins的key添加到这里
vim echo yourpubkey ~/.ssh/authorized_keys
# 调整权限，否则免登会失效
chmod g-w ~/.ssh/authorized_keys
~~~