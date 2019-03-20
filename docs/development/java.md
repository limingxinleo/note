# JAVA环境 Linux

## jdk jre jvm的区别
~~~
JDK（Java Development Kit）是针对Java开发员的产品，是整个Java的核心，包括了Java运行环境JRE、Java工具和Java基础类库。
Java Runtime Environment（JRE）是运行JAVA程序所必须的环境的集合，包含JVM标准实现及Java核心类库。
JVM是Java Virtual Machine（Java虚拟机）的缩写，是整个java实现跨平台的最核心的部分，能够运行以Java语言写作的软件程序。
~~~

## 安装JRE

1. (https://www.java.com/zh_CN/)[https://www.java.com/zh_CN/] 下载安装包
2. 解压缩
3. 移动所有文件到/opt/java/1.8.0中。
4. 建立软连接
~~~
ln -s /opt/java/1.8.0 /opt/java/home
~~~
5. 加入/opt/java/bin 到环境变量
~~~
vim /etc/profile
JAVA_HOME=/opt/java/home
JAVA_BIN=/opt/java/home/bin
export JAVA_HOME JAVA_BIN

export CLASSPATH=.:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar:$CLASSPATH

PATH=$JAVA_BIN:$PATH
export PATH
~~~

* 注意
~~~
a. 你要将 /usr/share/jdk1.6.0_14改为你的jdk安装目录 
b. linux下用冒号“:”来分隔路径 
c. $PATH / $CLASSPATH / $JAVA_HOME 是用来引用原来的环境变量的值。在设置环境变量时特别要注意不能把原来的值给覆盖掉了，这是一种 
常见的错误。 
d. CLASSPATH中当前目录“.”不能丢,把当前目录丢掉也是常见的错误。 
e. export是把这三个变量导出为全局变量。 
f. 大小写必须严格区分。
~~~

## 安装openjdk
~~~
yum --enablerepo=remi install java-1.8.0-openjdk
~~~


# JAVA MAC
~~~
查询java

brew cask search java
查看版本信息

brew cask info java
从官网下载并安装 JDK 8

brew cask install java
需要安装 JDK 7 或者 JDK 6，可以使用homebrew-cask-versions：

brew tap caskroom/versions
brew cask install java6
检查

java -version
~~~


  
