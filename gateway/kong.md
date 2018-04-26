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