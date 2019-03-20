## 安装
~~~
wget http://www.xunsearch.com/download/xunsearch-full-latest.tar.bz2
tar -xjf xunsearch-full-latest.tar.bz2

cd xunsearch-full-1.3.0/
sh setup.sh

安装目录为/opt/xunsearch
安装完毕后建立软连接
ln -s /opt/xunsearch/bin/xs-ctl.sh /usr/local/bin/xs-ctl

# 开启
xs-ctl -b inet start
# 关闭
xs-ctl -b inet stop
~~~

## 问题
1. bzip2: Cannot exec: No such file or directory
~~~
yum install bzip2
~~~

2. You need a working C++ compiler to compile Xapian, but configure failed to find one
~~~
yum install -y gcc gcc-c++
~~~

## 依赖库
~~~
yum -y install bzip2 gcc gcc-c++ wget automake autoconf libtool make zlib-devel
~~~
