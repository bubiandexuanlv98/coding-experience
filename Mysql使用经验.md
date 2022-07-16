# Mysql

## 原理

+ 字段类型问题
  1. double和float都会丢失精度，因为这两个类型都是转为二进制存储的，如果原来的十进制数据的**小数部分**不是以5或者0结尾，转为小数会存在精度丢失（不是5或0结尾变成二进制的时候会变成无限循环）。DECIMAL定点数类型时精准的
  2. DECIMAL（M,D）的方式表示高精度小数。其中，M 表示整数部分加小数部分，一共有多少位，M<=65。D 表示小数部分位数，D < M。
  2. TEXT 有一个问题：由于实际存储的长度不确定，MySQL 不允许 TEXT 类型的字段做主键。遇到这种情况，你只能采用 CHAR(M)，或者 VARCHAR(M)。
  2. BigInt(20)是指显示20位，而不是指bigint的类型宽度设为20，bigint的类型宽度是定死的就是占用8个字节存储（其他int都是这样）。但是Char(10)中的10指的是存储宽度的大小（不足补空格），但是VARCHAR(10)中的10指的是最大存储宽度大小（不足不补空格）
  
+ 不要修改主键的值

## 命令
+ 顺序：
  + 书写顺序：
  ```
    select
    from 
    join
    on
    where
    group by
    having
    order by
    limit
  ```
  + 执行顺序：
  ```
    from 
    join 
    on 
    where 
    group by(开始使用select中的别名，后面的语句中都可以使用)
    avg,sum.... 函数
    having 
    select 
    distinct 
    order by
    limit 
  ```
+ 修改数据：
  ```
    UPDATE 表名
    SET 字段名=值
    WHERE 条件
  ```
  + 注意点：不要修改主键的值

+ 查询数据：
  ```
    SELECT *|字段列表
    FROM 数据源
    WHERE 条件
    GROUP BY 字段
    HAVING 条件
    ORDER BY 字段
    LIMIT 偏移量，所需行数
  ```


+ 插入查询结果：
  ```
    INSERT INTO 历史流水表 （日结时间字段，其他字段）
    SELECT 获取当前时间函数，其他字段
    FROM 流水表
  ```
  + 注意点：

+ 条件语句
  + where和having的区别
    1. WHERE 是先筛选后返回结果（是一种约束），而 HAVING 是先返回结果后筛选（是一种事后过滤）。因此where 的效率更高
    2. where 得条件里面不能出现聚合函数，如果要在条件里面用聚合函数（有些资料里面叫分组函数），要在having 里面用。但where里面的子查询是可以用的。
    3. WHERE 在 GROUP BY 之前，所以无法对分组结果进行筛选。
    4. distinct 不要放在where中，因为肯定有更好的写法
  + 条件语句中出现的变量不一定要出现在select里面，这就比较考验选择哪些变量去筛选，最有效且开销最小

+ 派生表
  1. 派生表的别名有时候一定得取，有时候不需要，总的来说当派生表（或者子查询）出现在table_reference 的语句中，比如**from或者join语句中就必须有别名**，如果在select或者where中就不需要，但是建议在select里面起一个别名，方便显示
  2. 外部的别名是可以在派生表内部使用的，但派生表内部的别名无法在外部使用，同时注意派生表内部的别名是可以覆盖外部的别名的，如果他们相同的话。还有就是外部的field名是不会和派生表的field名冲突的。只要派生表内部不要自己冲突一般都没事。

+ 数学函数
  + round(x)
  这是四舍五入的函数，注意如果x<0，五入的值会比x小，eg. -1.5会变成-2
  
+ 聚合函数
  
  ```sql
  1.count() 所有记录数
  2.count(*)所有非null记录数
  3.avg()   某一列平均值
  4.min() 某一列最小值
  5.max() 某一列最大值
  6.sum() 某一列总和
  ```
  
  1. 聚合函数的参数只能是column，这个很重要，不能是一个派生表
  
  


+ 排名
  四大排名函数：row_number、rank、dense_rank、ntile
  
  ```sql
  row_number() over (partition by 分组字段 order by 排序字段)
  ```
  
  <https://leetcode-cn.com/problems/rank-scores/solution/si-da-pai-ming-han-shu-he-guan-jian-zi-b-qvaz/>
  
  1. 区别
     + `row_number()` 很显然，从字面上就可以看出来是每一行都有自己的一个`row_number()`，不管是否出现重复
     + `rank()` 和 `dense_rank()` 这两个都是重复的数字标号一样，但是`rank()`是相同的条数标号一样，但是计数，即假如有一条重复出现n次，再出现下面一条的时候标号就是加n。**`dense_rank()` 是相同的条数标号一样，但是不计数，再出现下面一条就只会增加1**
  
  语法： row_number() over(order by Score partition by Course)
  
  
  
  注意那个partition by是可选的
  
+ 连接
  
  1. 注意所有的join，连接的结果一定是左右两个表所有字段都在上面，包括重复的字段，哪张表在前面取决于`A join B`前面那个A是在前面的
  2. 无论什么连接，如果一张表中的一条对应另一张表中的多条（n条），那么连接后就会有n行
  
  + 内连接（join & inner join）
    1. 内连接join和where的区别
        + 从语法上讲，下面这两种代码的执行结果是一样的
        ```
        SELECT a.ID, b.Name, b.Date FROM Customers a, Sales b WHERE a.ID = b.ID;
        SELECT a.ID, b.Name, b.Date FROM Customers a Join Sales b on a.ID = b.ID;
        ```
        但是很多时候，数据库不会做优化，mysql会先把from后面的两张表生成一个笛卡尔积，就是加入a和b各有1000条，笛卡尔积之后就变成了1000000条，浪费资源。但是如果使用inner join这个命令，和on配对使用可以避免笛卡尔积产生
    
  + 自然连接(natural join)
    
  + 这个连接会交给数据库自己根据相同的**字段（field）**连接，不会产生笛卡尔积，没有查询价值
    
    
  
+ group by
  
  注意：group by 一定要和聚合函数一块使用！！！，虽然不一块不会报错，然而group by一组无论有没有聚合都是只会有一条数据。但是聚合函数不一定非要group by，因为你可以把整张表看成一个group
  
  + group by
    
    1. **group by 的结果一定是一组对应一条**，使用group by 要考虑两个问题，这两个问题是连续的，即分组+统计，**不要妄想用group by展示分组结果**
    2. group_concat一般是需要group by的（不用就成了concat），结果虽然只有一行，但是group_concat对应的那个字段应该是多个
    
    
  
+ order by
  
  1. order by有一个奇用就是分组展示结果，这个解决了group by 里面的问题
  
  2. order by这个东西很神奇，**它后面可以加聚合函数**（而且可以select里面不出现这个聚合函数），**而且它后面出现的字段可以不出现在select里面**（但如果select里面有distinct，order by里面的字段就必须出现在select里面）
  
  3. order by 后面加聚合函数必须要用 group by ，不然mysql会只返回第一行内容（没有经过聚合的第一行），甚至会报错，
  
     
  
+ limit
  limit要注意，后面可以加offset，也可以不加
  不加：limit 偏移量，所需行数
  加了：limit 所需行数 offset 偏移量
  
+ distinct
  
  1. distinct 不是聚合函数
  2. **select中出现distinct就只能输出distinct的内容了**，因为distinct必须放在第一位，而如果distinct 后面出现多列，那么distinct输出的是多字段唯一值。
  2. 针对2，**如果有需求需要单字段唯一的同时出现多个字段，就必须使用group by代替**
  
  
  
  + delete
  
    delete的一般用法
  
    `DELETE FROM 表名称 WHERE 列名称 = 值`
  
    delete的牛逼用法：
  
    `DELETE t1 FROM t1 LEFT JOIN t2 ON t1.id=t2.id WHERE t2.id IS NULL;`
  
    1. 也就是说delete可以先将两张表合并，然后再删除一张表上面的内容
  
+ 不等于
  
  不等于尽量使用：`<>`，而不是使用`!=`
  
+ 引号
  
  mysql中，单引号双引号没有区别


+ sql六种通用查询策略：

  <https://leetcode-cn.com/problems/nth-highest-salary/solution/mysql-zi-ding-yi-bian-liang-by-luanz/>
  
+ count

  count(1)，count(*)，count(列名)的区别
  
  <https://blog.csdn.net/wx1528159409/article/details/95643499>
  
+ null

  1. **是否为`null `的判断只能用`is`**，不能用`=`或者`<>`
  
+ 字符串拼接的方式

  concat(string1, string2, string3...)
  
  concat_ws(separator, string1, string2,...)
  
  group_concat( [distinct] 要连接的字段 [order by asc/desc 排序字段] [separator '分隔符']) 
  
  concat, concat_ws，group_concat : <https://wenku.baidu.com/view/30a978646aeae009581b6bd97f1922791688be98.html>
  
  concat 和 concat_ws : https://blog.csdn.net/szw906689771/article/details/123652828
  
  1. 上面几种方法都是指在查询结果中拼接字符串
  2. group_concat可以不用group by，直接group_concat是对整张表，整张表group_concat一般都是把一列所有数据放到一起
  3. 似乎concat和concat_ws只能拼接列与列的字段，列内字段的拼接要用group_concat

## 技巧

+ `where 1=1` 这句废话广泛用于代码中拼接sql语句中，因为这样可以统一增加条件的语句，即在for循环里面每一个循环都加上“and ...”
+ 不能在where里面用rank，只能把rank写在派生表中，用from读取，然后再用where对这个派生表中的rank做判断
+ 聚合函数不光可以针对已有的列进行计算，还可以针对在select中新生成的列进行计算