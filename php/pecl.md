## PECL

### PECL常用命令

~~~bash
# 显示所有注册进来的扩展【注册进来的扩展，并不代表现在的php已经具备其能力，还是需要看是否加载进来】
$ pecl list

# 只注册扩展，不编译、安装扩展
$ pecl install -B mongodb

# 编译、安装扩展
$ pecl install mongodb

# 强制替换当前扩展
$ pecl install -f mongodb

# 查看扩展的安装位置
$ pecl list mongodb | grep src

~~~