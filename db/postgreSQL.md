## PostgreSQL

### 使用
~~~
# 显示所有数据库
\l


~~~

### MAC安装
~~~
# 安装
brew install postgresql
# 初始化
initdb /usr/local/var/postgres -E utf8
# 启动
pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start
# 关闭
pg_ctl -D /usr/local/var/postgres stop -s -m fast
# 创建用户
createuser username -P
# 创建数据库
createdb dbname -O username -E UTF8 -e
# 链接数据库
psql -U username -d dbname -h 127.0.0.1
~~~