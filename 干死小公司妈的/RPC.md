# RPC 通信

## 目的

解决跨机器，跨语言的请求痛点。

## 概念

### RPC通信过程

<img src="/Users/yixia/Desktop/coding-experience/干死小公司妈的/图片/RPC_model.png"  style="zoom:40%"  />

RPC框架核心就是三层：编解码层，协议层和网络通信层

<img src="/Users/yixia/Desktop/coding-experience/干死小公司妈的/图片/RPC_struct.png"  style="zoom:40%"  />

上图是一个RPC通信的过程描述，注意上面那两个框属于用户测，下面两个框属于RPC框架侧。

### RPC模型组件

1. IDL：定义了跨语言的数据交换格式
2. GenCode：把框架的内容封装成静态库，连接用户侧和RPC框架测
3. 编解码层：解决了跨语言的数据交换格式的问题
4. 协议层：见下面Thrift的协议层







## Thrift 

### 框架设计

这里面框架设计就是Thrift的分层设计，补充两个跟网络博客上不太一样的内容：一个是Transport 层，一个是Protocol 层。Thrift的Protocol指的是上面那个Encoder，Transport指的是上面那个Protocol+Transfer

+ Transport 层

  其实apache thrift是有实现自己的协议的，Transport并不完全是TCP协议，他是封装了一个自己的协议头THeader的，但是有意思的就在于这个它自己实现的协议是放在Transport中的，并没有放在Protocol中，thrift里面的Protocol层指的是编解码的协议。

  1. 为什么需要这样一个协议？
  
     + 看那个protocol id，我们要统一一个编解码的格式。RPC既然靠IDL约束数据传输内容，那么必须要做到编解码方式要事先约定好
  
     + 看那个Length，记不记得我们讲的TCP黏包的问题
  
     + 看那个Sequence Number，这个能做到多路复用，一个TCP连接只有一个seq number，它实际上只能
  
     + 其余信息作用均见下图
  
  
  
  <img src="/Users/yixia/Desktop/coding-experience/干死小公司妈的/图片/THeader.png"  style="zoom:40%"  />

+ TProtocol 层

  1. TProtocol层在thrift中是编解码层，**编解码层要解决的一个很重要的问题是如何进行跨语言的数据交换**。这里必须定义一个新的跨语言的数据交换编码，因为：

     + 不能用语言自带的数据编码方式，因为不知道Python序列化一个类和Java序列化一个类编码不一定一致

     + 不能用json（参见json的弊端），其他的人类阅读语言有着类似的问题

  2. Thrift里面的BinaryProtocol用的是TLV编码，Compact用的是类似varint的编码。Grpc用的编码就是Varint编码，Varint编码冗余度小一点，尤其对那种数据比较小的field

  下面是TLV编码的方式：

  <img src="/Users/yixia/Desktop/coding-experience/干死小公司妈的/图片/thrift_tlv.png"  style="zoom:30%"  />

  

小知识：http协议是靠特殊结束符来标记每个协议单元的结束的（协议一般指协议头），THeader这种就是属于变长协议（自定义协议）。http也是靠那种方式解决黏包问题的。

### RPC 框架设计需要考虑的问题

1. 稳定性（见工程：健壮的网络服务）

   框架内部实现的时候通过注册中间件实现，采用Option模式设计，`WithTimeout(...)`这种

2. 易用性

   合理的默认参数，丰富的文档，自动生成静态库的工具

3. 扩展性

   <img src="/Users/yixia/Desktop/coding-experience/干死小公司妈的/图片/rpc_extension.png"  style="zoom:30%"  />

   RPC框架要对上面这些内容的变化开放，上面这些层由下到上和协议栈的层级是一样的。

4. 观测性（见工程：健壮的网络服务）

   除了工程里面说的，还有要内置观测性服务，能提供一个web页面去观测这个服务里面的Option，中间件，协程数等等

5. 高性能（见工程：健壮的网络服务）

   除了工程里面说的，还要去考虑不同场景下的服务性能（这个面试的时候不要答，答不好）



## 字节RPC

字节RPC是一个类Thrift的RPC，并不是基于Thrift开发的

#### 字节自研网络库

go自带网络库net有两个问题：

1. 一个连接一个goroutine，会出现goroutine暴涨问题
2. 无法感知失效连接（这个在连接池中，尤其是长连接的连接池中会很影响效率）
3. 其余见：<http://www.uml.org.cn/zjjs/202110201.asp>

字节自研网络库的优势：

1. goroutine池

2. 感知连接状态

3. 减少GC

4. 减少拷贝

   注意：后面两个是靠LinkBuffer实现读写并行无锁（读在队头读，写在队尾写）。它提供了一个零拷贝接口。上层无需调用`Read()`拷贝（拷贝操作还是为了让上层读，和IO写不冲突，实现读写不冲突）。同时这个由网络库管理的Buffer是一个相当于内存池，能减少GC。这个链表还能高效的扩缩容

   

字节go网络库其他优势：<http://www.uml.org.cn/zjjs/202110201.asp>
