# UNMP

## 安装php
~~~
sudo add-apt-repository ppa:ondrej/php

sudo apt-get update

sudo apt-get install php7.0 php7.0-cgi php7.0-cli php7.0-common php7.0-curl php7.0-dev \
php7.0-gd php7.0-json php7.0-ldap php7.0-mysql php7.0-odbc php7.0-opcache \
php7.0-xml php7.0-fpm php7.0-mbstring php7.0-mcrypt php7.0-zip php7.0-phalcon

sudo apt-get install composer

composer config -g repo.packagist composer https://packagist.phpcomposer.com
~~~

## 安装Nginx
~~~
sudo apt-get install nginx

#修改nginx用户组
user = xxx;
~~~

## PHP-FPM
~~~
# 修改php-fpm 用户组
user = xxx;
group = xxx;
~~~

## 安装Redis
~~~
sudo apt-get install redis-server
redis-server &
~~~

## 安装Mysql
~~~
sudo apt-get install mysql-server
sudo service mysql start

# 刷新权限
FLUSH PRIVILEGES;

# 外网访问
vim /etc/mysql/mysql.conf.d/mysqld.cnf
# bind-address            = 127.0.0.1
~~~
