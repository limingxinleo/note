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

### Centos安装
~~~
yum install https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7-x86_64/pgdg-centos10-10-2.noarch.rpm
yum install postgresql10-server
# 启动PostgreSQL
/usr/pgsql-10/bin/postgresql-10-setup initdb
systemctl enable postgresql-10
systemctl start postgresql-10
# 登录数据库 PostgreSQL不允许使用root登录，故需要自己创建用于登录的账号
$ sudo -u postgres /usr/pgsql-10/bin/psql
CREATE USER kong; CREATE DATABASE kong OWNER kong;
$ vim /var/lib/pgsql/10/data/pg_hba.conf
local   all             all                                     trust
host    all             all             127.0.0.1/32            trust
host    all             all             ::1/128                 trust

~~~