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

### Tunnel

> ```
> SSH的的Port Forward，中文可以称为端口转发，是SSH的一项非常重要的功能。它可以建立一条安全的SSH通道，并把任意的TCP连接放到这条通道中。下面仔细就仔细讨论SSH的这种非常有用的功能。SSH Tunnel有三种，分别是本地Local（ssh -NfL），远程Remote（ssh -NfR），动态Dynamic（ssh -NfD）。（含义参考man ssh）说明：在我们举例说...
> ```

SSH Tunnel有三种，分别是本地Local（ssh -NfL），远程Remote（ssh -NfR），动态Dynamic（ssh -NfD）。

说明：在我们举例说明用法之前，先假设你有一台SSH机器，它的IP是a.b.c.d。

- 本地 Local 模式

  ```bash
  # ssh -NfL <local host>:<local port>:<remote host>:<remote port> <SSH hostname>
  ssh -NfL 127.0.0.1:1234:www.google.com:80 root@a.b.c.d
  ```

  这样当你本地访问  127.0.0.1:1234 时，就会自动转发到 www.google.com:80

  ***比如说你在本地访问不了某个网络服务（如www.google.com），而有一台机器（如：a.b.c.d）可以，那么你就可以通过这台机器来访问。***

- 远程Remote

  ```bash
  # ssh -R <local port>:<remote host>:<remote port> <SSH hostname>
  #在需要被访问的内网机器上运行： 
  ssh -NfR 1234:localhost:22 root@a.b.c.d
  
  #登录到a.b.c.d机器，使用如下命令连接内网机器：
  ssh -p 1234 localhost
  ```

  > 需要注意的是上下两个命令里的localhost不是同一台。这时你会发现自己已经连上最开始命令里的localhost机器了，也就是执行“ssh -NfR”的那台机器。

  ***比如当你下班回家后就访问不了公司内网的机器了，遇到这种情况可以事先在公司内网的机器上执行远程Tunnel，连上一台公司外网的机器，等你下班回家后 就可以通过公司外网的机器去访问公司内网的机器了。***