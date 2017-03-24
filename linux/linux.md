### 获取当前文件夹 多少个文件
~~~
ls | wc -w
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