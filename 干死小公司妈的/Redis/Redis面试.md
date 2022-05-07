1. 为什么redis那么快

   <https://m.php.cn/redis/424900.html>

+ 纯内存操作，避免大量访问数据库，减少直接读取磁盘数据，redis将数据储存在内存里面，读写数据的时候都不会受到硬盘 I/O 速度的限制，所以速度快；

+ 单线程操作，避免了不必要的上下文切换和竞争条件，也不存在多进程或者多线程导致的切换而消耗CPU，不用去考虑各种锁的问题，不存在加锁释放锁操作，没有因为可能出现死锁而导致的性能消耗；

+ 采用了非阻塞I/O多路复用机制

2. redis常用数据结构

   键的类型只能是string

   值的类型有：字符串(String)、哈希(Map)、 列表(list)、集合(sets) 和 有序集合(sorted sets)。集合是不包含重复的，列表是包含重复的

3. redis做排行榜

   + 多字段排序：<https://blog.csdn.net/willingtolove/article/details/113753797>

     其实就是把多个字段放到一个十进制数或者二进制数里面做分数，时间戳直接存太大了，可以用一个大数减一下
   
4. redis的key

5. redis的遍历

   <https://zhuanlan.zhihu.com/p/46353221>

   + 不能用keys，少量的时候可以用keys。因为keys 会阻塞线程，且keys 没有类似limit的参数
   + 只能用scan，**但是scan如果正好碰上redis的缩容会重复，所以使用的时候要去重**（扩容的时候不会，因为做了特殊处理，见链接）**这也是scan会被面试的地方**
   + scans用的时候要注意，默认count是10，但实际上这个count只是一个大致的约束，每次返回的个数是不定的，不管你指不指定count：<https://redis.io/commands/scan/>（搜The COUNT option）

​	代码中如何使用Scan：<https://blog.csdn.net/Eric_Alive/article/details/123131367>

6. redis的大/多key处理方案

   + 拆分方案

     https://cloud.tencent.com/developer/article/1454332

     这里面注意一下，这里面包括两个相反的过程，一个是大key拆分，另一个是多key合并。对于value之间没有什么相关性（大key拆分），或者key之间没有相关性（多key合并）的情况可以用hash分桶解决。如果value或者key之间有相关性，可以根据相关性拆分或合并（比如一条视频的信息包括tag，标题，作者，创建时间，曝光情况。或者说多路召回）

     https://www.csdn.net/tags/Mtjacg1sMTQ0MzQtYmxvZwO0O0OO0O0O.html（主要讲怎么分桶的）

   + 大key的找出和删除

     https://www.modb.pro/db/103715

     检测的方法主要有三种：--bigkeys，rdb-tools，memory usage这种，--bigkeys不精确，rdb-tools不够实时，memory usage必须指定key，而且也是阻塞的

     删除大key的方法主要就是两个：就是4.0以后可以用unlink可以非阻塞的删除大key，还有就是定期删除一些失效的内容，比如zset里面时间做分数的话实际上要定时删掉一些过期的内容
   
7. redis热点key的解决方案

   监控和解决方案：<https://blog.csdn.net/weixin_39628105/article/details/110987939>

8. redis集群

   Redis Cluster集群中的从节点，官方默认设置的是不分担读请求的、只作备份和故障转用。但是从节点是有读权限的

   <https://blog.csdn.net/yabingshi_tech/article/details/115573330>

9. redis的普通主从，哨兵模式

   <https://www.cnblogs.com/HDMaxfun/p/15711892.html> 这里面关于redis cluster集群的一致性hash是错误的，但是其它都比较简洁明了，适合面试

   <https://time.geekbang.org/column/article/274483> 极客时间，比较标准

   