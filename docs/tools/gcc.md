# gcc

## 升级gcc版本

~~~bash
#!/bin/bash
# 在非root账户下，使用sudo命令
# 安装解压缩工具
yum install lbzip2 unzip flex

# 获取源码
cd ~
wget https://github.com/gcc-mirror/gcc/archive/gcc-8_2_0-release.zip
 
# 解压
unzip gcc-gcc-8_2_0-release.zip
 
cd gcc-gcc-8_2_0-release
./contrib/download_prerequisites
cd ..
 
# 建立编译输出目录
mkdir gcc-build-8.2.0
 
# 进入下面目录，执行命令，生成Makefile文件
cd gcc-build-8.2.0
../gcc-gcc-8_2_0-release/configure --enable-checking=release --enable-languages=c,c++ --disable-multilib

# 编译
make -j4
 
# 安装
make install
~~~