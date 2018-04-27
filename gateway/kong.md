## Kong Gateway

[官网](https://getkong.org)

### 新建PostgreSQL 用户
~~~
postgres=# CREATE USER kong;　　//默认具有LOGIN属性
~~~

### 新建数据库
~~~
$ createdb kong -O kong -E UTF8 -e
~~~

### GUI
[konga](https://github.com/pantsel/konga)
~~~
git clone https://github.com/pantsel/konga.git
cd konga
npm install
npm start (npm run production)
~~~

### Centos 安装
~~~
wget https://bintray.com/kong/kong-community-edition-rpm/rpm -O bintray-kong-kong-community-edition-rpm.repo
# 修改baseurl为 baseurl=https://kong.bintray.com/kong-community-edition-rpm/centos/7
mv bintray-kong-kong-community-edition-rpm.repo /etc/yum.repos.d/
yum install epel-release
yum install kong-community-edition
cp /etc/kong/kong.conf.defaul /etc/kong/kong.conf

# 安装PostgreSQL
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

# 启动Kong
kong migrations up -c /etc/kong/kong.conf
kong start -c /etc/kong/kong.conf
~~~

### MAC使用
当默认安装了nginx时，会出现使用冲突。只要自用nginx与openresty用的nginx在端口上没有冲突，就可以按照下面方法来做
~~~
# 启动我们自己的nginx
sudo nginx
# 去掉nginx的软连接
brew unlink nginx
# 建立openresty的软连接
brew link openresty
# 启动kong
kong start
~~~