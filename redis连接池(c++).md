# xRedisClient类
## 构造函数
+ 置空mRedisPool，这个用来申请资源创建RedisPool（RedisPool只有一个）


## xRedisClient::Init(uint32_t maxtype)
+ 初始化mRedisPool
先申请资源创建RedisPool，再执行RedisPool的Init(uint32_t typesize)函数，将maxtype传进去



## xRedisClient::ConnectRedisCache(const RedisNode *redisnodelist, uint32_t nodecount, uint32_t hashbase, uint32_t cachetype)
调用传参：xRedis.ConnectRedisCache(RedisList1, sizeof(RedisList1) / sizeof(RedisNode), 3, CACHE_TYPE_1);
+ 用mRedisPool初始化RedisCache
  mRedisPool->setHashBase(cachetype, hashbase)
  
+ mRedisPool->ConnectRedisDB(cachetype, pNode->dbindex, pNode->host, pNode->port, pNode->passwd, pNode->poolsize, pNode->timeout, pNode->role);

# RedisPool类
## 构造函数
+ 初始化mTypeSize（不能超过MAX_REDIS_DB_HASHBASE），这是用来标识一共有多少个RedisCache的，有多少集群就有多少RedisCache
+ 置空mRedisCacheList，这个用来申请资源创建RedisCache集群（有几个Redis集群就有几个RedisCache）

## RedisPool::Init(uint32_t typesize)
真正的初始化
+ 用类私有指针mRedisCacheList构造一组RedisCache，个数由类变量mTypeSize决定。根据一共有多少个Redis集群数量来构造多少个RedisCache（没有执行RedisCache的Init函数，所以并未真正初始化），也就是说多个Redis集群，只有一个xRedisClient，一个xRedisClient只有一个RedisPool


## RedisPool::setHashBase(uint32_t cachetype, uint32_t hashbase)
根据cachetype指示初始化第几个RedisCache，进去以后实际调用的是RedisCache类的InitDB()


## 析构函数


# RedisCache类

## 构造函数
+ mDBlist置空，这是用来申请资源初始化RedisDBSlice集群(一个Redis集群有几个机器就有几个RedisDBSlice)
  
## InitDB()
初始化mDBList
