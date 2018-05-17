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





