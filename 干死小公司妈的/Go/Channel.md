# Channel

1. https://draveness.me/golang/docs/part3-runtime/ch06-concurrency/golang-channel/
2. https://blog.csdn.net/u010853261/article/details/85887948 goready和gopark函数

## 数据结构

### hchan

这是channel的主体结构

```go
type hchan struct {
	qcount   uint           // 当前队列中剩余元素个数
	dataqsiz uint           // 环形队列长度，即可以存放的元素个数
	buf      unsafe.Pointer // 环形队列指针
	closed   uint32	        // 标识关闭状态
	sendx    uint           // 队列下标，指示元素写入时存放到队列中的位置
	recvx    uint           // 队列下标，指示元素从队列的该位置读出
	recvq    waitq          // 等待读消息的goroutine队列，双向链表
	sendq    waitq          // 等待写消息的goroutine队列，双向链表
	lock mutex              // 互斥锁，chan不允许并发读写
  ...
}
```

sudog结构，这个很重要，是recvq和sendq挂着的双向链表的节点

```go
type sudog struct {
	g *g // 指向一个goroutine的指针
	next *sudog
	prev *sudog
	elem unsafe.Pointer // 指向发送方的数据，或者是接收方的地址 (may point to stack)
  ...
}
```



## 操作

### 创建

创建channel的时候使用make语句

```
ch := make(chan Task, 3)
```

这个channel语句是存储在堆上面的，ch是一个指向堆的指针。这就是为什么我们不需要在函数传参的时候传递指向ch的指针来节省空间的原因，因为人家本来就是指针。

### 发送

编译器会把 <- 这个发送符号转化为runtime.chansend1，发送过程有三种情况

1. 当存在等待的接收者时，通过 [`runtime.send`](https://draveness.me/golang/tree/runtime.send) 直接将数据发送给阻塞的接收者；（直接发送）

2. 当缓冲区存在空余空间时，将发送的数据写入 Channel 的缓冲区；（缓冲区发送）

3. 当不存在缓冲区或者缓冲区已满时，等待其他 Goroutine 从 Channel 接收数据；（阻塞发送）

```go
func chansend(c *hchan, ep unsafe.Pointer, block bool, callerpc uintptr) bool {
	lock(&c.lock)

	if c.closed != 0 {
		unlock(&c.lock)
		panic(plainError("send on closed channel"))
	}
  ...
```

发送的一些统一处理：

1. 上来就获取锁，channel也是一把大锁锁住的！不允许并发读写
2. 判断这个channel是否已经关闭了

#### 直接发送

如果目标 Channel 没有被关闭并且已经recvq中有东西（有读等待的goroutine，注意channel可能有缓冲区可能没有），那么 [`runtime.chansend`](https://draveness.me/golang/tree/runtime.chansend) 会从接收队列 `recvq` 中取出最先陷入等待的 Goroutine （就是sudolog结构里面的g）并直接向它发送数据：

```go
if sg := c.recvq.dequeue(); sg != nil {
  send(c, sg, ep, func() { unlock(&c.lock) }, 3)
  return true
}
```

<img src="/Users/yixia/Desktop/coding-experience/图片/2020-01-29-15802354027250-channel-direct-send.png"  style="zoom:50%"  />

```go
func send(c *hchan, sg *sudog, ep unsafe.Pointer, unlockf func(), skip int) {
	if sg.elem != nil {
		sendDirect(c.elemtype, sg, ep)
		sg.elem = nil
	}
	gp := sg.g
	unlockf()
	gp.param = unsafe.Pointer(sg)
	goready(gp, skip+1)
}
```

直接发送的时候有两点要注意：那个sendDirect是把ep里面的（就是发送方的发送的数据）**拷贝**到接收者（就是那个sg）的地址里面的，注意是拷贝

1. goready注意一下，这个函数后面会讲，这里它是把接收的那个goroutine，就是sg里面那个g，放到了当前goroutine的process的本地队列里面了，但此时并没有执行（唤醒），只是“ready”。
2. 注意这里那个g并不一定是当前process的本地队列里面的，因为后面会讲到，那个g是接收方阻塞的g。当一个g阻塞的时候（休眠的时候），它与它自己原来属于的那个machine 和 process剥离了

#### 缓冲区发送

如果创建的 Channel 包含缓冲区并且 Channel 中的数据没有装满（c.qcount < c.dataqsiz），那这个**待发送的数据会被拷贝到缓冲区**。会执行下面这段代码：

````go
func chansend(c *hchan, ep unsafe.Pointer, block bool, callerpc uintptr) bool {
	...
	if c.qcount < c.dataqsiz {
		qp := chanbuf(c, c.sendx) // 找到缓冲区里面下一个可以放置的地址
		typedmemmove(c.elemtype, qp, ep)
		c.sendx++
		if c.sendx == c.dataqsiz {
			c.sendx = 0
		}
		c.qcount++
		unlock(&c.lock)
		return true
	}
	...
}
````

chanbuf会计算出下一个可以放置的位置的地址，然后typedmemmove会把待发送的值（ep那个地址里面存的）从发送者的地址中（ep）拷贝过去。

注意sendx是循环的，当它到达dataqsiz的时候会重新回到0，**因为buf是一个循环缓冲区**

#### 阻塞发送

这个是指发送的时候没有缓冲区空位，或者没有缓冲区且没有接收者时的阻塞发送

```go
func chansend(c *hchan, ep unsafe.Pointer, block bool, callerpc uintptr) bool {
	...
	gp := getg()
	mysg := acquireSudog()
	mysg.elem = ep
	mysg.g = gp
	c.sendq.enqueue(mysg)
	goparkunlock(&c.lock, waitReasonChanSend, traceEvGoBlockSend, 3) // 这里进入睡眠
	// 之后的代码必须在这个goroutine被唤醒以后才能继续往下运行
	...
	releaseSudog(mysg) 
	return true
}
```

1. 执行 [`runtime.acquireSudog`](https://draveness.me/golang/tree/runtime.acquireSudog) 获取 [`runtime.sudog`](https://draveness.me/golang/tree/runtime.sudog) 结构并设置这一次阻塞发送的相关信息，例如发送的 Channel、是否在 select 中和待发送数据的内存地址等；
2. 将刚刚创建并初始化的mysg**加入发送等待队列**，并设置到当前 Goroutine 的 `waiting` 上，表示 Goroutine 正在等待该 `sudog` 准备就绪；

### 接收

接收 <-，会被编译转换为 [`runtime.chanrecv1`](https://draveness.me/golang/tree/runtime.chanrecv1) 和 [`runtime.chanrecv2`](https://draveness.me/golang/tree/runtime.chanrecv2) 两种不同函数的调用，但是这两个函数最终还是会调用 [`runtime.chanrecv`](https://draveness.me/golang/tree/runtime.chanrecv)

接收和发送一样，有三种情况

#### 直接接收

直接接收就是指在sendq上面有待发送的sudog的时候发送

```go
if sg := c.sendq.dequeue(); sg != nil {
  recv(c, sg, ep, func() { unlock(&c.lock) }, 3)
  return true, true
}
```

上面这一段是直接接收的代码。这个recv函数见：<https://draveness.me/golang/docs/part3-runtime/ch06-concurrency/golang-channel/>

recv中根据缓冲区的有无可以分为两种情况：

- 不存在缓冲区

  将sendq上面的队列头（就是上面那段代码的sg）存储的 `elem` **数据拷贝到**接收者的目标内存地址中；这个和直接发送那个是相似的（注意elem是在sg里面的）

- 存在缓冲区，且缓冲区满了，sendq上面还有等待发送的sudog

  1. 将队列中的数据拷贝到接收方的内存地址；（注意不是像上面那种情况一样接收sg存储的elem）
  2. 将发送队列头的数据拷贝到缓冲区中，释放一个阻塞的发送方，注意这个时候；

这两种情况结束以后在recv中都需要对sg执行goready，把sg放到当前处理器的runnext，调度器下一次调度时将这个sg唤醒。

#### 缓冲区接收

这个很简单了，和上面一样，chanbuf找到缓冲区中下一个可以接收的elem的地址，然后用typedmemmove把那个elem从缓冲区拷贝到接收者的目标地址中

#### 阻塞接收

这个和上面也一样，当这个channel没有缓冲区且没有sendq，或者有缓冲区但缓冲区中是空的，这两种情况，接收方会阻塞，然后接收方goroutine会自己生成sudog，挂到recvq上面，然后剥离M，进入休眠

### 关闭

关闭管道的close关键字会被编译器转换成 [`runtime.closechan`](https://draveness.me/golang/tree/runtime.closechan) 函数：

```go
// 当 Channel 是一个空指针或者已经被关闭时，Go 语言运行时都会直接崩溃并抛出异常：
func closechan(c *hchan) {
	if c == nil {
		panic(plainError("close of nil channel"))
	}

	lock(&c.lock)
	if c.closed != 0 {
		unlock(&c.lock)
		panic(plainError("close of closed channel"))
	}
```

处理完了这些异常的情况之后就可以开始执行关闭 Channel 的逻辑了，主要工作就是将 `recvq` 和 `sendq` 两个队列中的sudog的goroutine加入 `gList`列表中，与此同时该函数会清除所有 [`runtime.sudog`](https://draveness.me/golang/tree/runtime.sudog) 上未被处理的元素。最后对gList里面的每一个goroutine执行goready。

### 关于阻塞与唤醒

这里的阻塞也适用于阻塞接收。阻塞的时候要注意，被阻塞的goroutine要剥离它运行的那个machine和它原来所在的那个process，这个操作是gopark实现的

#### gopark

#### goready 

goready并不是唤醒，唤醒就要运行了，goready只是让当前goroutine在之后的调度中被唤醒

goready源码中有一个getg()，这个函数很有意思，它实际上获取的是当前g的结构体。比如协程a调用goready解除某一个协程b的阻塞的，比如a从一个满channel里面读取一个数字，那么这个协程调用getg获取的就是这个a协程的g，后面会把b放到a协程所在的local p中