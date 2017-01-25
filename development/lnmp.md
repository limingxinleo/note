## Linux(CentOS) Nginx Mysql PHP 环境搭建

### 更换Remi仓库
* sudo rpm --import https://rpms.remirepo.net/RPM-GPG-KEY-remi
* sudo rpm -ivh http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
* sudo rpm -ivh https://mirrors.tuna.tsinghua.edu.cn/remi/enterprise/remi-release-7.rpm

> 默认地，REMI是禁用的。要检查REMI是否已经成功安装，使用这个命令。你会看到几个REMI仓库，比如remi、remi-php55和remi-php56。
> yum repolist disabled | grep remi

### 安装
> 如上所述，最好保持禁用REMI仓库，只有在需要的时候再启用。

* yum --enablerepo=remi search <keyword>
* yum --enablerepo=remi install <package-name>