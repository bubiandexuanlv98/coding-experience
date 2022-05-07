

1. 数据库三大范式
   
   + 数据表中的每一列(字段)，必须是不可拆分的最小单元，也就是确保每一列的原子性，而不是集合。这一范式也保证每张表都是二维的
     + 反例（user_id）（出生日期）（出生地点）其中地点是[中国，安徽，合肥]，这也是为什么MySQL里面没有集合类型
   + 满足1NF的基础上，要求：表中的所有列（属性），都必需依赖于主键，而不能有任何一列（属性）与主键没有关系。
     + 反例：（user_id主键）（出生日期）（出生地点）（今天天气）
   + 满足2NF的基础上，任何非主属性不依赖于其它非主属性（在2NF基础上消除传递依赖）
     + 反例：（order_id主键）（买家id）（买家性别）（买家年龄）后面三个属性应该放在另一张表上面
   
2. 数据库五大约束

   + 主键约束

     这个属性每一个值是唯一的且非空

   + 唯一约束

     这个属性每一个值是唯一的但可以空

   + 检查约束

     对这个属性的范围和格式的控制

   + 默认约束

     该属性的默认值

   + 外界约束

     两表间的约束

3. 索引模型的区别

   + 二叉树与B树区别（见索引）
   + B树，B+树区别（见索引）
   + 哈希表，B树区别
     1. Hash 索引进行等值查询更快（一般情况下），但是却无法进行范围查询；
     2. Hash 索引不支持使用索引进行排序
     3. Hash 索引虽然在等值查询上较快，但是不稳定，性能不可预测，当某个键值存在大量重复的时候，发生 Hash 碰撞，此时效率可能极差；而 **B+ 树的查询效率比较稳定**，对于所有的查询都是从根结点到叶子结点，且**树的高度较低**。
     4. Hash 索引不支持模糊查询以及多列索引的最左前缀匹配，原理也是因为 Hash 函数的不可预测
     5. Hash 索引任何时候都避免不了回表查询数据，而 B+ 树在符合某些条件（聚簇索引，覆盖索引等）的时候可以只通过索引完成查询；

4. DB的索引，什么数据结构可以代替B+树？ **跳表**

4. 为什么需要自增主键做索引

   1. 有一个自增主键，这样保证每次插入都是递增插入，都不涉及到挪动其他记录，也不会触发叶子节点的分裂。
   2. 自增主键有时候比别的属性做主键，占用空间少
   
6. Drop/Delete/Truncate的区别

   1. delete一行一行删，有回滚，有触发，记录日志，靠日志可恢复
   2. truncate 直接把表中的数据删掉，没有回滚，不可恢复，但是表结构保存，索引什么都在
   3. drop直接把表删掉，表结构都没了
   
7. or 不能走索引，因此要替换成in

8. 工作建表内容：

   ```sql
   DROP TABLE IF EXISTS `censor_text_sample_roster`;
   CREATE TABLE `censor_text_sample_roster` (
       `roster_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '名单id',
       `company_id` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT '公司id',
       `name` varchar(64) NOT NULL DEFAULT '' COMMENT '名单名称',
       `description` varchar(255) NOT NULL DEFAULT '' COMMENT '名单描述',
       `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '应用状态 1-正常 2-删除 3-停用',
       `match_type` tinyint(4) NOT NULL DEFAULT '1' COMMENT '匹配方式 1-原文匹配 2-语义匹配',
       `admin_id` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT '管理员id',
       `admin_name` varchar(64) NOT NULL DEFAULT '' COMMENT '管理员名字',
       `create_time` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
       `update_time` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT '修改时间',
   PRIMARY KEY (`roster_id`) USING BTREE,
   KEY `idx_company_id` (`company_id`) USING BTREE,
   KEY `idx_admin_id` (`admin_id`) USING BTREE,
   KEY `idx_create_time` (`create_time`) USING BTREE
   ) ENGINE=InnoDB AUTO_INCREMENT=261408517632557057 DEFAULT CHARSET=utf8mb4 COMMENT='审核文本名单表';
   
   DROP TABLE IF EXISTS `censor_text_sample`;
   CREATE TABLE `censor_text_sample` (
       `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'id',
       `roster_id` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT '名单id',
       `word` varchar(64) NOT NULL DEFAULT '' COMMENT 'word 词',
       `risk_type` int(11) NOT NULL DEFAULT '0' COMMENT '风险类型，对应违禁类型',
       `status` tinyint(4) NOT NULL DEFAULT '1' COMMENT '应用状态 1-正常 2-删除 3-停用 4-过期',
       `source` tinyint(4) NOT NULL DEFAULT '1' COMMENT '来源 1内部舆情 2WXB 3GA 4GD 5WH 6ZF 7其他',
       `suggestion` tinyint(4) NOT NULL DEFAULT '1' COMMENT '处置建议 1-通过 2-审核 3-拒绝',
       `tags` varchar(255) NOT NULL DEFAULT '' COMMENT '标签',
       `reason` varchar(255) NOT NULL DEFAULT '' COMMENT '原因',
       `hit_type` tinyint(4) NOT NULL DEFAULT '1' COMMENT '命中类型 1-包含 2-完全相等',
       `is_forever` tinyint(4) NOT NULL DEFAULT '1' COMMENT '1-永久有效 2-有效期',
       `valid_start_time` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT '生效开始时间',
       `valid_end_time` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT '生效结束时间',
       `admin_id` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT '管理员id',
       `admin_name` varchar(64) NOT NULL DEFAULT '' COMMENT '管理员名字',
       `create_time` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT '创建时间',
       `update_time` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT '修改时间',
       PRIMARY KEY (`id`) USING BTREE,
       UNIQUE KEY `idx_word_roster_id` (`word`,`roster_id`) USING BTREE,
       KEY `idx_admin_id` (`admin_id`) USING BTREE,
       KEY `idx_create_time` (`create_time`) USING BTREE
       ) ENGINE=InnoDB AUTO_INCREMENT=261444505826230273 DEFAULT CHARSET=utf8mb4 COMMENT='审核文本样本库';
   ```

9. mysql 实战面试题：https://www.nowcoder.com/discuss/922991?type=2&channel=-1&source_id=discuss_terminal_discuss_jinghua_nctrack

10. 数据库优化方案 与 分库分表的做法与意义

    https://mp.weixin.qq.com/s?__biz=MzIwODI1OTk1Nw==&mid=2650322981&idx=1&sn=644537003c300db69934aa7acee80c8c&chksm=8f09c63fb87e4f29b5bebeca1c03e102898fcbd663b6f189a78dba8cec646f875cc01832a221&token=1553501157&lang=zh_CN#rd
