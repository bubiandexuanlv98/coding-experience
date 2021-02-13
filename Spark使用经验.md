# 基于PySpark

### RDD 的概念
<https://www.cnblogs.com/qingyunzong/p/8899715.html>

### Spark处理RDD，分区数，executor，task，stage，job的关系
分区数，executor，task关系<https://www.pianshen.com/article/59541140058/>
一个带有shuffle操作的transformation算子（这样的算子使得父子两个RDD形成宽依赖，其他算子都是窄依赖）划分两个stage，一个action算子形成一个job，job串行执行，一个stage里面有多少task取决于RDD有多少分区，executor的数量往往是人为指定的，一个executor中有多少core一般就能并行执行多少个task，所以设置executor-core往往也就是在设置一个executor中有多少task。
如果遇到以下情况：
我有201个executor，每个executor中有两个core，我某次操作A的RDD是20个分区，那么运行的时候，一般是从201个executor中挑选10个executor来执行操作A
### spark 宽依赖窄依赖算子概念，和分类
<https://blog.csdn.net/qq_19446965/article/details/110412564>
<https://blog.csdn.net/u014028317/article/details/102889277>
宽依赖窄依赖另一种分类：
<https://untitled-life.github.io/blog/2018/12/27/wide-vs-narrow-dependencies/>
distinct大部分时候是宽依赖

### spark action 和 transformation算子
<https://blog.csdn.net/helloxiaozhe/article/details/78481784>

### 通过parallelize方法创建RDD
<https://www.jianshu.com/p/c688b8856dd8>
### 通过textFile方法创建RDD
<https://blog.csdn.net/legotime/article/details/51871724>
注意：这种方法有一个问题，就是读取的路径可以是空的，但不能是不存在的，如果是空的，仍然能读取只不过是空的罢了
### 通过saveAsTextFile方法保存RDD
一定要注意Spark对text的处理一定是一行一行的处理，一行为一个元素，保存的时候也是一样，比如以`saveAsTextFile`保存一个list，那么list中的每一个元素都将作为一行存储进HDFS中

### RDD的两个算子及其区别（Transformation和Action）
<https://www.cnblogs.com/qingyunzong/p/8899715.html>
妈的一定要注意，必须要有action算子才能执行整个代码

### reduceByKey
reduceByKey的**作用对象是(key, value)形式的RDD**，而reduce有减少、压缩之意，reduceByKey的作用就是对相同key的数据进行处理，最终每个key只保留一条记录。一定要注意reduceByKey**不能处理dict！，不能处理dict！**

### Broadcast
<https://www.cnblogs.com/yy3b2007com/p/10613035.html>
具体原理：<https://www.cnblogs.com/yy3b2007com/p/11439966.html>
### Cache

### Cache 和 Broadcast的区别
broadcast 一般是把driver当中定义的变量，比如我在我的main函数里面定义了一个字典，分发到各个executor中存储
但是cache一般是，把每个executor中某一个RDD给持久化了，就是认为 broadcast是针对自定义变量的，然后cache和persist是针对RDD的


## 注意事项
1. 当stage的description中出现`runJob at PythonRDD.scala:498`时，代表出现了把executor的结果提取到driver中的操作，比如`rdd.take`，但他妈的`rdd.collect`其实也调用了`runJob`这个函数，但是他在description中就是collect
2. 当stage的description中出现`coalesce at NativeMethodAccessorImpl.java:0`时，代表出现了repartition的操作（即`coalesce + shuffle=true`），注意单纯的`coalesce`是一个窄依赖，属于多个父分区对应一个子分区


spark编程技巧：
1. 如果需要提取整个表中的数据做dict，要么先map再reduce，要么拉到driver中做整体处理
2. pyspark
