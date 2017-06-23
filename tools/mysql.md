## Mysql

### 安装mysql 如果remi没有mysql源可以使用下列方法
~~~
[centos7]$ yum localinstall  http://dev.mysql.com/get/mysql57-community-release-el7-7.noarch.rpm
[centos7]$ yum install mysql-community-server
[centos7]$ yum install mysql-community-devel
[centos6]$ yum localinstall http://dev.mysql.com/get/mysql57-community-release-el6-8.noarch.rpm
[centos6]$ yum install mysql-community-server
[centos6]$ yum install mysql-community-devel
$ service mysqld start
$ grep 'temporary password' /var/log/mysqld.log

mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY 'LoveYi@521';
mysql> grant all on *.* to limx@'%' identified by 'LoveYi@521'
~~~


### 主从同步
mysql服务器的主从配置，这样可以实现读写分离，也可以在主库挂掉后从备用库中恢复

需要两台机器，安装mysql，两台机器要在相通的局域网内

主机A: 192.168.1.100

从机B:192.168.1.101

可以有多台从机

1、先登录主机 A
~~~
mysql>GRANT REPLICATION SLAVE ON *.* TO ‘backup’@’192.168.1.101‘ IDENTIFIED BY ‘123456’;
赋予从机权限，有多台丛机，就执行多次
~~~

2、 打开主机A的my.cnf，输入
~~~
server-id               = 1                             #主机标示，整数
log_bin                 = /var/log/mysql/mysql-bin.log  #确保此文件可写
read-only               =0                              #主机，读写都可以
binlog-do-db            =test                           #需要备份数据，多个写多行
binlog-ignore-db        =mysql                          #不需要备份的数据库，多个写多行
~~~

3、打开从机B的my.cnf，输入
~~~
server-id               = 2
log_bin                 = /var/log/mysql/mysql-bin.log
master-host             =192.168.1.100
master-user             =backup
master-pass             =123456
master-port             =3306
master-connect-retry    =60                             #如果从服务器发现主服务器断掉，重新连接的时间差(秒)
replicate-do-db         =test                           #只复制某个库
replicate-ignore-db     =mysql                          #不复制某个库
~~~
4、同步数据库

> 不用太费事，只把主从库都启动即可自动同步，如果不嫌麻烦的话可以把主库的内容导出成SQL，然后在从库中运行一遍

5、先重启主机A的mysql，再重启从机B的mysql

6、验证
> 在主机A中

~~~
mysql>show master status\G;
~~~
> 在从机B中

~~~
mysql>show slave status\G;
~~~
> 能看到大致这些内容

~~~
File: mysql-bin.000001
Position: 1374
Binlog_Do_DB: test
Binlog_Ignore_DB: mysql
~~~
> 可以在主机A中，做一些INSERT, UPDATE, DELETE 操作，看看主机B中，是否已经被修改

### 千万级大表增加索引
~~~
create table tmp like paper_author;
ALTER TABLE tmp ADD INDEX ( `PaperID` )
insert into tmp(ooo，...)  select  ooo,... from paper_author
Query OK, 35510600 rows affected (9 min 24.99 sec)
Records: 35510600  Duplicates: 0  Warnings: 0
RENAME TABLE paper_author TO tmp2, tmp to paper_author;
drop table tmp2;
~~~