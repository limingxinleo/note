## 更新数据的同时获取数据的存储过程
~~~
CREATE PROCEDURE getCardID( IN in_date INT, IN in_type INT)
BEGIN
SET @update_id := 0;
UPDATE cards SET status = 1, cardid = (SELECT @update_id := cardid)
WHERE `date` = in_date AND `type` = in_type AND `status` = 0 ORDER BY sortid LIMIT 1;
SELECT @update_id AS cardid;
END;
~~~

## 重复插入时更新
> 如果您指定了ON DUPLICATE KEY UPDATE，并且插入行后会导致在一个UNIQUE索引或PRIMARY KEY中出现重复值，则执行旧行UPDATE。
> 例如，如果列a被定义为UNIQUE，并且包含值1，则以下两个语句具有相同的效果。
> 如果行作为新记录被插入，则受影响行的值为1；如果原有的记录被更新，则受影响行的值为2。
> 因为插入失败了，所以如果使用这种方法，自增主键会因为这个原因出现断层。

~~~
mysql>INSERT INTO table (a,b,c) VALUES (1,2,3) ON DUPLICATE KEY UPDATE c=c+1;  
mysql>UPDATE table SET c=c+1 WHERE a=1;  
~~~

## INT类型
| 对象 | 区间 | 类型 | 返回 |
| ---------- | ---------- | ---------- | -------- |
| 人 | 0-150 | unsigned tinyint | 0 - 255 |
| 龟 | 数百岁 | unsigned smallint | 0 - 65535 |
| 恐龙化石 | 数千万年 | unsigned int | 0 - 约42.9亿 |
| 太阳 | 50亿年 | unsigned bigint | 0 - 约10^19 |

## mysqldump
~~~
Usage: mysqldump [OPTIONS] database [tables]
OR     mysqldump [OPTIONS] --databases [OPTIONS] DB1 [DB2 DB3...]
OR     mysqldump [OPTIONS] --all-databases [OPTIONS]

mysqldump -h 127.0.0.1 -u root -pxxx --databases db1 >> uat.sql
~~~

## 字符型查询

| 对象  | 类型 | 示例 |
| ---------- | ---------- | -------- |
| shop_no | string  | 0021 |

~~~

SELECT * FROM table WHERE shop_no = '0021'; // 能查到数据
SELECT * FROM table WHERE shop_no = 0021; // 能查到数据
SELECT * FROM table WHERE shop_no = 21; // 能查到数据
SELECT * FROM table WHERE shop_no = '21'; // 不能查到数据

~~~

## 排序
~~~
SELECT * FROM table ORDER BY score DESC;
如果表中score字段的重复率比较高，以上代码应该为一下SQL
SELECT * FROM table ORDER BY score DESC, id DESC;
~~~

## 分区
[原博客地址](https://blog.csdn.net/yongchao940/article/details/55266603)

查看Mysql是否支持分区
~~~
show plugins;
# 看到以下信息partition为ACTIVE时，表示支持分区
# partition | ACTIVE | STORAGE ENGINE | NULL | GPL
~~~

1. range分区
按照RANGE分区的表是通过如下一种方式进行分区的，每个分区包含那些分区表达式的值位于一个给定的连续区间内的行
~~~
//创建range分区表  
CREATE TABLE IF NOT EXISTS `user` (
	`id` int(11) NOT NULL AUTO_INCREMENT COMMENT '用户ID',
	`name` varchar(50) NOT NULL DEFAULT '' COMMENT '名称',
	`sex` int(1) NOT NULL DEFAULT '0' COMMENT '0为男，1为女',
	PRIMARY KEY (`id`)
) ENGINE = InnoDB CHARSET = utf8 AUTO_INCREMENT = 1
PARTITION BY RANGE (id) (
	PARTITION p0 VALUES LESS THAN (3),
	PARTITION p1 VALUES LESS THAN (6),
	PARTITION p2 VALUES LESS THAN (9),
	PARTITION p3 VALUES LESS THAN (12),
	PARTITION p4 VALUES LESS THAN MAXVALUE
);
  
//插入一些数据  
INSERT INTO `test`.`user` (`name`, `sex`)
VALUES ('tank', '0'),('zhang', 1),('ying', 1),
    ('张', 1),('映', 0),('test1', 1),('tank2', 1),
    ('tank1', 1),('test2', 1),('test3', 1),('test4', 1),
    ('test5', 1),('tank3', 1),('tank4', 1),('tank5', 1),
    ('tank6', 1),('tank7', 1),('tank8', 1),('tank9', 1),
	('tank10', 1),('tank11', 1),('tank12', 1),('tank13', 1),
	('tank21', 1),('tank42', 1);
  
//到存放数据库表文件的地方看一下，my.cnf里面有配置，datadir后面就是  
[root@BlackGhost test]# ls |grep user |xargs du -sh  
4.0K    user#P#p0.MYD  
4.0K    user#P#p0.MYI  
4.0K    user#P#p1.MYD  
4.0K    user#P#p1.MYI  
4.0K    user#P#p2.MYD  
4.0K    user#P#p2.MYI  
4.0K    user#P#p3.MYD  
4.0K    user#P#p3.MYI  
4.0K    user#P#p4.MYD  
4.0K    user#P#p4.MYI  
12K    user.frm  
4.0K    user.par  
  
//取出数据  
mysql> select count(id) as count from user;  
+-------+  
| count |  
+-------+  
|    25 |  
+-------+  
1 row in set (0.00 sec)  
  
//删除第四个分区  
mysql> alter table user drop partition p4;  
Query OK, 0 rows affected (0.11 sec)  
Records: 0  Duplicates: 0  Warnings: 0  
  
/**存放在分区里面的数据丢失了，第四个分区里面有14条数据，剩下的3个分区 
只有11条数据，但是统计出来的文件大小都是4.0K，从这儿我们可以看出分区的 
最小区块是4K 
*/  
mysql> select count(id) as count from user;  
+-------+  
| count |  
+-------+  
|    11 |  
+-------+  
1 row in set (0.00 sec) 
  
/*可以对现有表进行分区,并且会按規则自动的将表中的数据分配相应的分区 
中，这样就比较好了，可以省去很多事情，看下面的操作*/  
ALTER TABLE `user` PARTITION BY RANGE(id)  
(PARTITION p1 VALUES less than (1),  
 PARTITION p2 VALUES less than (5),  
 PARTITION p3 VALUES less than (10),  
 PARTITION p0 VALUES less than MAXVALUE);
~~~

2. List分区
~~~
//这种方式失败 存在主键，但不在LIST中
CREATE TABLE IF NOT EXISTS `list_part` (
	`id` int(11) NOT NULL AUTO_INCREMENT COMMENT '用户ID',
	`province_id` int(2) NOT NULL DEFAULT 0 COMMENT '省',
	`name` varchar(50) NOT NULL DEFAULT '' COMMENT '名称',
	`sex` int(1) NOT NULL DEFAULT '0' COMMENT '0为男，1为女',
	PRIMARY KEY (`id`)
) ENGINE = INNODB CHARSET = utf8 AUTO_INCREMENT = 1
PARTITION BY LIST (province_id) (
	PARTITION p0 VALUES IN (1, 2, 3, 4, 5, 6, 7, 8), 
	PARTITION p1 VALUES IN (9, 10, 11, 12, 16, 21), 
	PARTITION p2 VALUES IN (13, 14, 15, 19), 
	PARTITION p3 VALUES IN (17, 18, 20, 22, 23, 24)
);

//这种方式成功 不存在主键
CREATE TABLE IF NOT EXISTS `list_part` (
	`id` int(11) NOT NULL COMMENT '用户ID',
	`province_id` int(2) NOT NULL DEFAULT 0 COMMENT '省',
	`name` varchar(50) NOT NULL DEFAULT '' COMMENT '名称',
	`sex` int(1) NOT NULL DEFAULT '0' COMMENT '0为男，1为女'
) ENGINE = INNODB CHARSET = utf8
PARTITION BY LIST (province_id) (
	PARTITION p0 VALUES IN (1, 2, 3, 4, 5, 6, 7, 8), 
	PARTITION p1 VALUES IN (9, 10, 11, 12, 16, 21), 
	PARTITION p2 VALUES IN (13, 14, 15, 19), 
	PARTITION p3 VALUES IN (17, 18, 20, 22, 23, 24)
); 
~~~

3. HASH分区
~~~
CREATE TABLE IF NOT EXISTS `hash_part` (
	`id` int(11) NOT NULL AUTO_INCREMENT COMMENT '评论ID',
	`comment` varchar(1000) NOT NULL DEFAULT '' COMMENT '评论',
	`ip` varchar(25) NOT NULL DEFAULT '' COMMENT '来源IP',
	PRIMARY KEY (`id`)
) ENGINE = INNODB CHARSET = utf8 AUTO_INCREMENT = 1
PARTITION BY HASH (id) PARTITIONS 3;
~~~

4. KEY分区
~~~
CREATE TABLE IF NOT EXISTS `key_part` (
	`news_id` int(11) NOT NULL COMMENT '新闻ID',
	`content` varchar(1000) NOT NULL DEFAULT '' COMMENT '新闻内容',
	`u_id` varchar(25) NOT NULL DEFAULT '' COMMENT '来源IP',
	`create_time` DATE NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '时间'
) ENGINE = INNODB CHARSET = utf8
PARTITION BY LINEAR HASH (YEAR(create_time)) PARTITIONS 3;
~~~

## 时间函数
~~~
NOW() # 返回当前时间 2018-07-13 11:39:54
UNIX_TIMESTAMP("2018-07-13 11:39:54") # 1531453194
FROM_UNIXTIME(1531453194) # 2018-07-13 11:39:54
~~~

## 安装mysql 如果remi没有mysql源可以使用下列方法
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


## 主从同步
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

## 千万级大表增加索引
~~~
create table tmp like paper_author;
ALTER TABLE tmp ADD INDEX ( `PaperID` )
insert into tmp(ooo，...)  select  ooo,... from paper_author
Query OK, 35510600 rows affected (9 min 24.99 sec)
Records: 35510600  Duplicates: 0  Warnings: 0
RENAME TABLE paper_author TO tmp2, tmp to paper_author;
drop table tmp2;
~~~





