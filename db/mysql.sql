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
ALTER TABLE `table` ADD COLUMN `status` smallint(2) unsigned NOT NULL DEFAULT '1' COMMENT '状态';
ALTER TABLE `table` ADD COLUMN `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '备注' AFTER `mobile`,
ADD COLUMN `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '反馈类型' after `remark`;

## 插入失败则更新
## 这种方式更新，会使自增主键出现间隔
INSERT INTO `user` (username,role_id) VALUES ('limx2',1) ON DUPLICATE KEY UPDATE role_id=role_id+1;

