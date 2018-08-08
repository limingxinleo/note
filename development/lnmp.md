## Linux(CentOS) Nginx Mysql PHP 环境搭建

### 安装oh my zsh
~~~
yum install zsh
yum install git
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
~~~

### 安装vim
~~~
yum install vim
~~~

### 修改zsh主题
~~~
vim /root/.zshrc
修改 ZSH_THEME="ys"
~~~

### 更换源Remi仓库
~~~
sudo rpm --import https://rpms.remirepo.net/RPM-GPG-KEY-remi
sudo rpm -ivh http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo rpm -ivh https://mirrors.tuna.tsinghua.edu.cn/remi/enterprise/remi-release-7.rpm
~~~

> 默认地，REMI是禁用的。要检查REMI是否已经成功安装，使用这个命令。你会看到几个REMI仓库，比如remi、remi-php55和remi-php56。

~~~
yum repolist disabled | grep remi
~~~

### 安装
> 如上所述，最好保持禁用REMI仓库，只有在需要的时候再启用。

#### 搜索安装Remi仓库中的包
~~~
yum --enablerepo=remi search <keyword>
yum --enablerepo=remi install <package-name>
~~~

### 安装nginx
* 修改Nginx源
> 替换 “OS” 为 “rhel” 或 “centos”, depending on the distribution used, 
> 替换 “OSRELEASE” 为 “6” 或 “7”, for 6.x or 7.x versions, respectively.

~~~
$ vim /etc/yum.repos.d/nginx.repo
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/OS/OSRELEASE/$basearch/
gpgcheck=0
enabled=1
~~~

* 安装
~~~
yum install nginx
yum install nginx-all-modules
service nginx start
# 开机自启动
systemctl enable nginx.service
~~~

* 访问你的网站就能看到nginx的欢迎页面了。

### 安装mariadb
~~~
yum --enablerepo=remi install mariadb-server
rpm -q mariadb mariadb-server
~~~
### 启动配置mysql
~~~
systemctl start|stop mariadb（service mariadb start|stop）
mysql_secure_installation
~~~

### 安装mysql 如果remi没有mysql源可以使用下列方法
~~~
[centos7]$ yum localinstall  http://dev.mysql.com/get/mysql57-community-release-el7-7.noarch.rpm
[centos7]$ yum install mysql-community-server
[centos7]$ yum install mysql-community-devel
[centos6]$ yum localinstall http://dev.mysql.com/get/mysql57-community-release-el6-8.noarch.rpm
[centos6]$ yum install mysql-community-server
[centos6]$ yum install mysql-community-devel
$ service mysqld start
$ grep 'temporary password' /var/log/mysqld.log

mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY 'LoveYi@521';
mysql> grant all on *.* to limx@'%' identified by 'LoveYi@521';
mysql> FLUSH PRIVILEGES;
~~~


### 安装php72
> 这里只安装一部分常用的扩展，其他扩展可以自行安装

~~~
#7.2
yum --enablerepo=remi install php72 php72-php-devel php72-php-fpm php72-php-gd php72-php-pdo php72-php-mysql php72-php-xml php72-php-mbstring php72-php-phalcon php72-php-zip php72-php-opcache
yum --enablerepo=remi install php72-php-redis php72-php-pecl-swoole4 php72-php-process php72-php-pecl-mongodb

ln -s /usr/bin/php72 /usr/local/bin/php && \
ln -s /opt/remi/php72/root/bin/phpize /usr/local/bin/phpize && \
ln -s /opt/remi/php72/root/bin/php-config /usr/local/bin/php-config && \
ln -s /opt/remi/php72/root/sbin/php-fpm /usr/local/sbin/php-fpm
~~~

### 修改php-fpm组合用户
~~~
vim /etc/opt/remi/php72/php-fpm.d/www.conf
user = nginx
group = nginx
~~~

### 修改php权限
~~~
cd /var/opt/remi/php72/lib/php
# chown -R 用户:组 *
chown -R root:nginx *
~~~

### php-fpm 配置
~~~
vim /etc/opt/remi/php72/php-fpm.conf
daemonize = yes
pid = /var/opt/remi/php72/run/php-fpm/php-fpm.pid
~~~

### 启动php-fpm
~~~
php-fpm
或者
service php-fpm start
或者
service php72-php-fpm start
# 开机自启动
systemctl enable php72-php-fpm.service
~~~

### Reload php-fpm
~~~
kill -USR2 `cat /usr/local/var/run/php-fpm.pid`
kill -USR2 `cat /var/opt/remi/php72/run/php-fpm/php-fpm.pid`
~~~

### 安装composer
~~~
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
php -r "unlink('composer-setup.php');"
~~~

> 以上方式如果下载不下来 可以直接去官网下载composer.phar。

~~~
mv composer.phar /usr/local/bin/composer
~~~
### 修改composer国内镜像
~~~
composer config -g repo.packagist composer https://packagist.laravel-china.org
~~~
### 使用composer安装一个小项目
* 新建项目
~~~
cd /
mkdir www
cd www
composer create-project limingxinleo/phalcon-project demo --prefer-dist
~~~
* 配置nginx

> 把[demo.conf](http://7xrqhy.com1.z0.glb.clouddn.com/phalcon.conf)复制到conf.d中并修改文件

~~~
server_name  demo.cn;
root   /www/demo/public;

location / {
    if (!-e $request_filename) {
        rewrite "^/(.*)$" /index.php?_url=/$1 last;
        #rewrite "^/(.*)$" /index.php/$1 last;
    }
}
~~~
* 访问你的域名 demo.cn

> 当看到以下信息时，就代表可以正常使用了，因为此项目默认注入db服务，所以会显示下列错误！

~~~
SQLSTATE[HY000] [1049] Unknown database 'phalcon'
~~~

### 安装Redis
~~~
yum --enablerepo=remi install redis

vim /etc/redis.conf
requirepass yourpassword

service redis start
~~~
