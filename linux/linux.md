### 获取当前文件夹 多少个文件
~~~
ls | wc -w
~~~

### 输出进程个数
~~~
ps -e | grep php-fpm | wc -l
~~~

### 某个端口是否被监听
~~~
lsof -i:8080
~~~

### zsh 安装
* CentOS
~~~
yum install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
~~~

### 查看系统命令的全路径
~~~
which php
~~~

### 硬件信息
~~~
lshw
~~~

### 权限管理
给file文件的[属主|组用户|其他][增加|减少|赋予(去掉其他权限)][读取|写入|执行]权限
~~~
chmod [u|g|o][+|-|=][r|w|x] file
~~~

### 切换用户
~~~
su nginx
~~~
正常情况下切换账号即可，但如果报错 This account is currently not available.则修改下面文件：
~~~
vim /etc/passwd
修改 nginx:x:499:499:Nginx web server:/var/lib/nginx:/sbin/nologin
为 nginx:x:499:499:Nginx web server:/var/lib/nginx:/bin/bash
~~~

### tail命令使用方法演示例子
监视filename文件的尾部内容（默认10行，相当于增加参数 -n 10），刷新显示在屏幕上。退出，按下CTRL+C
~~~
tail -f filename
~~~

显示filename最后20行
~~~
tail -n 20 filename
~~~

显示filename前面20行
~~~
tail -n +20 filename
~~~

逆序显示filename最后10行
~~~
tail -r -n 10 filename
~~~

### 查看进程
查看cpu占用率排序的进程
~~~
ps H -eo user,pid,ppid,tid,time,%cpu,cmd --sort=%cpu
~~~

### tar解压缩命令
~~~
.tar.gz     格式解压为          tar   -zxvf   xx.tar.gz
.tar.bz2    格式解压为          tar   -jxvf   xx.tar.bz2
~~~

### 删除大文件前几行
~~~
sed -i '1,nd' filename
~~~

### 欢迎语
~~~
vim /etc/motd
~~~

### 如何判断自己的操作系统是32位还是64位？

* Windows系统
请按Win+R运行cmd，输入systeminfo后回车，稍等片刻，会出现一些系统信息。在“系统类型”一行中，若显示“x64-based PC”，即为64位系统；若显示“X86-based PC”，则为32位系统。

* Mac
直接使用64位的，因为Go所支持的Mac OS X版本已经不支持纯32位处理器了。

* Linux
用户可通过在Terminal中执行命令arch(即uname -m)来查看系统信息：
64位系统显示:x86_64
32位系统显示:i386

### PATH加载规则
~~~
echo $PATH
可以看到所有的PATH目录，脚本加载顺序便是按照这个顺序，逐个查找，一旦找到，则运行
~~~