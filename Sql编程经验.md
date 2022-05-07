# Hive
Hive sql 执行顺序
<https://zhuanlan.zhihu.com/p/51032131>
Hive sql 书写顺序
<https://zhuanlan.zhihu.com/p/77847158>
## Group By
+ 这个函数很多时候是用来去重的，**要注意select里面出现的字段，一定要在group by里面出现。除了select里面聚合性的字段**，比如select里面用min，max，sum等聚合性函数包裹的变量


## NVL()和 COALESCE() 函数
+ presto 里面没有nvl函数，所以必须用coalesce函数代替。同时nvl函数只能两个表达式，coalesce函数可以有多个

## select
### 注意事项
如果有一个字段的名字在所有临时表里面只有唯一的一个，在select里面可以直接用这个字段的名字

## 代码注意事项
+ where，group by后面不能跟别名


# presto
空值和NULL值不一样，看一下coalesce到底是针对空值还是null值
int和bigint不一样
双引号和单引号不一样，presto里面全用单引号
