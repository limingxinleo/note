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

~~~
mysql>INSERT INTO table (a,b,c) VALUES (1,2,3) ON DUPLICATE KEY UPDATE c=c+1;  
mysql>UPDATE table SET c=c+1 WHERE a=1;  
~~~
