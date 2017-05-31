### 获取当前文件夹 多少个文件
~~~
ls | wc -w
~~~

### 输出进程个数
~~~
ps -e | grep php-fpm | wc -l
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