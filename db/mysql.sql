# 索引

## 增加普通索引
ALTER TABLE `table` ADD KEY `idx_created_at`(`created_at`) USING BTREE;

## 主键索引
ALTER TABLE `table` DROP PRIMARY KEY;
ALTER TABLE `table` ADD PRIMARY KEY (`id`,`no`);

## 修改字段
ALTER TABLE `table` MODIFY COLUMN `shop_id` bigint(20) unsigned
NOT NULL DEFAULT '0' COMMENT '门店ID';

## 增加字段
ALTER TABLE `table` ADD COLUMN `status` smallint(2) DEFAULT '1' COMMENT '状态';

