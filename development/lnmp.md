## Linux(CentOS) Nginx Mysql PHP 环境搭建

### 安装oh my zsh
~~~
yum install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
~~~

### 安装vim
~~~
yum install vim
~~~

### 修改zsh主题
~~~
vim /root/.zshrc
修改 ZSH_THEME="bira"
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
~~~
yum --enablerepo=remi install nginx
service nginx start
~~~
* 访问你的网站就能看到nginx的欢迎页面了。

### 安装mysql
~~~
yum --enablerepo=remi install mariadb-server
rpm -q mariadb mariadb-server
~~~
### 启动配置mysql
~~~
systemctl start|stop mariadb（service mariadb start|stop）
mysql_secure_installation
~~~
### 安装php70
> 这里只安装一部分常用的扩展，其他扩展可以自行安装
~~~
yum --enablerepo=remi install php70 php70-php-gd php70-php-pdo php70-php-mysql php70-php-xml php70-php-mbstring
cp /usr/bin/php70 /usr/bin/php
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
composer config -g repo.packagist composer https://packagist.phpcomposer.com
~~~
