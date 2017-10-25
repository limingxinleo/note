### 更新数据的同时获取数据的存储过程
~~~
CREATE PROCEDURE getCardID( IN in_date INT, IN in_type INT)
BEGIN
SET @update_id := 0;
UPDATE cards SET status = 1, cardid = (SELECT @update_id := cardid)
WHERE `date` = in_date AND `type` = in_type AND `status` = 0 ORDER BY sortid LIMIT 1;
SELECT @update_id AS cardid;
END;
~~~

### 重复插入时更新
> 如果您指定了ON DUPLICATE KEY UPDATE，并且插入行后会导致在一个UNIQUE索引或PRIMARY KEY中出现重复值，则执行旧行UPDATE。
> 例如，如果列a被定义为UNIQUE，并且包含值1，则以下两个语句具有相同的效果。
> 如果行作为新记录被插入，则受影响行的值为1；如果原有的记录被更新，则受影响行的值为2。
> 因为插入失败了，所以如果使用这种方法，自增主键会因为这个原因出现断层。

~~~
mysql>INSERT INTO table (a,b,c) VALUES (1,2,3) ON DUPLICATE KEY UPDATE c=c+1;  
mysql>UPDATE table SET c=c+1 WHERE a=1;  
~~~

### INT类型
| 对象 | 区间 | 类型 | 返回 |
| ---------- | ---------- | ---------- | -------- |
| 人 | 0-150 | unsigned tinyint | 0 - 255 |
| 龟 | 数百岁 | unsigned smallint | 0 - 65535 |
| 恐龙化石 | 数千万年 | unsigned int | 0 - 约42.9亿 |
| 太阳 | 50亿年 | unsigned bigint | 0 - 约10^19 |

### mysqldump
~~~
Usage: mysqldump [OPTIONS] database [tables]
OR     mysqldump [OPTIONS] --databases [OPTIONS] DB1 [DB2 DB3...]
OR     mysqldump [OPTIONS] --all-databases [OPTIONS]

mysqldump -h 127.0.0.1 -u root -pxxx --databases db1 >> uat.sql
~~~

### 字符型查询

| 对象  | 类型 | 示例 |
| ---------- | ---------- | -------- |
| shop_no | string  | 0021 |

~~~

SELECT * FROM table WHERE shop_no = '0021'; // 能查到数据
SELECT * FROM table WHERE shop_no = 0021; // 能查到数据
SELECT * FROM table WHERE shop_no = 21; // 能查到数据
SELECT * FROM table WHERE shop_no = '21'; // 不能查到数据

~~~



