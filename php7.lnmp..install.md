## 阿里云Centos php7 Lnmp环境搭建
#### 更新系统软件
~~~
$ yum update
~~~
#### 安装nginx
~~~
[centos7]$ yum localinstall http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
[centos6]$ yum localinstall http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm
$ yum install nginx
$ service nginx start
~~~
#### 如果安装错了源
~~~
$ yum remove nginx //删除软件
//$ yum clean all // 清除缓存
$ rpm -qa | grep nginx // rpm -qa | grep 包名 查询安装的rpm包
$ rpm -e nginx-release-centos // rpm -e 文件名 这个命令就是你想卸载的软件，后面是包名称，最后的版本号是不用打的
~~~
#### 安装mysql
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
mysql> grant all on *.* to limx@'%' identified by 'LoveYi@521'
~~~
#### 编译安装php7.0
~~~
$ wget -O php7.tar.gz http://cn2.php.net/get/php-7.0.14.tar.gz/from/this/mirror
$ tar -xvf php7.tar.gz
cd php-7.0.14
$ yum install libxml2 libxml2-devel openssl openssl-devel bzip2 bzip2-devel libcurl libcurl-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel gmp gmp-devel libmcrypt libmcrypt-devel readline readline-devel libxslt libxslt-devel
$ ./configure \
--prefix=/usr/local/php \
--with-config-file-path=/etc \
--enable-fpm \
--with-fpm-user=nginx  \
--with-fpm-group=nginx \
--enable-inline-optimization \
--disable-debug \
--disable-rpath \
--enable-shared  \
--enable-soap \
--with-libxml-dir \
--with-xmlrpc \
--with-openssl \
--with-mcrypt \
--with-mhash \
--with-pcre-regex \
--with-sqlite3 \
--with-zlib \
--enable-bcmath \
--with-iconv \
--with-bz2 \
--enable-calendar \
--with-curl \
--with-cdb \
--enable-dom \
--enable-exif \
--enable-fileinfo \
--enable-filter \
--with-pcre-dir \
--enable-ftp \
--with-gd \
--with-openssl-dir \
--with-jpeg-dir \
--with-png-dir \
--with-zlib-dir  \
--with-freetype-dir \
--enable-gd-native-ttf \
--enable-gd-jis-conv \
--with-gettext \
--with-gmp \
--with-mhash \
--enable-json \
--enable-mbstring \
--enable-mbregex \
--enable-mbregex-backtrack \
--with-libmbfl \
--with-onig \
--enable-pdo \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--with-zlib-dir \
--with-pdo-sqlite \
--with-readline \
--enable-session \
--enable-shmop \
--enable-simplexml \
--enable-sockets  \
--enable-sysvmsg \
--enable-sysvsem \
--enable-sysvshm \
--enable-wddx \
--with-libxml-dir \
--with-xsl \
--enable-zip \
--enable-mysqlnd-compression-support \
--with-pear \
--enable-opcache

$ make && make install
vim /etc/profile
*****************************
在profile文件最下面加入
PATH=$PATH:/usr/local/php/bin
export PATH
******************************
$ source /etc/profile
~~~
#### 配置php-fpm
~~~
$ cp php.ini-production /etc/php.ini
$ cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
$ cp /usr/local/php/etc/php-fpm.d/www.conf.default/usr/local/php/etc/php-fpm.d/www.conf
$ cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
$ chmod +x /etc/init.d/php-fpm
$ /etc/init.d/php-fpm start
~~~

