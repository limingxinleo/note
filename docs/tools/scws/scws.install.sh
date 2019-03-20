#!/usr/bin/env bash

version='1.2.3'
prefix='/usr/local/scws'

# 下载并解压
wget http://www.xunsearch.com/scws/down/scws-${version}.tar.bz2
tar xvjf scws-${version}.tar.bz2

# 安装Scws
cd scws-${version}
./configure --prefix=${prefix} && \
make && \
make install

# 建立软连接
ln -sf ${prefix}/bin/scws /usr/local/bin/scws

# 检查安装结果
ls -al ${prefix}/lib/libscws.la
scws -h

# PHP扩展安装
# ${prefix}/phpext
# phpize
# ./configure --with-scws=/usr/local/scws
# make