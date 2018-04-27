## Kong Gateway

[官网](https://getkong.org)

### 新建PostgreSQL 用户
~~~
postgres=# CREATE USER kong;　　//默认具有LOGIN属性
~~~

### 新建数据库
~~~
$ createdb kong -O kong -E UTF8 -e
~~~

### MAC使用
当默认安装了nginx时，会出现使用冲突。只要自用nginx与openresty用的nginx在端口上没有冲突，就可以按照下面方法来做
~~~
# 启动我们自己的nginx
sudo nginx
# 去掉nginx的软连接
brew unlink nginx
# 建立openresty的软连接
brew link openresty
# 启动kong
kong start
~~~