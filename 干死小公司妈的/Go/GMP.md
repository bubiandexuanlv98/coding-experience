## GMP模型

1. <https://www.topgoer.com/%E5%B9%B6%E5%8F%91%E7%BC%96%E7%A8%8B/GMP%E5%8E%9F%E7%90%86%E4%B8%8E%E8%B0%83%E5%BA%A6.html>
2. 看起来很牛逼的：<https://www.ardanlabs.com/blog/2018/08/scheduling-in-go-part2.html>这个其实解释异步系统调用的过程

## 协程与线程

<img src="https://www.topgoer.com/static/7.1/gmp/8.jpg"  style="zoom:30%"  />

+ 协程和线程的区别
  1. 创建一个协程一般只需要几KB的内存，创建一个线程需要4MB的内存
  2. 协程是由用户态的协程调度器（go里面的runtime）调度的，线程是由CPU调度的（在linux里面，CPU调度的是一个PCB进程控制块，因为linux认为进程和线程是一样的）

## GM调度器（v1.0及以前）

<img src="https://www.topgoer.com/static/7.1/gmp/10.jpg"  style="zoom:30%"  />

老GM调度器，那个全局的go协程队列是加锁的，每次放回和取出全局队列里面的G都要加锁

- 创建、销毁、调度 G 都需要每个 M 获取锁，这就形成了激烈的锁竞争。
- M 转移新创建的 G’ 时会造成延迟和额外的系统负载，局部性很差。比如M中运行着G，当 G 创建新协程G'的时候，G'会被M交接到别的M‘上运行（M为了继续运行G）但是 G’和 G 是相关的，最好放在 M 上执行，而不是其他 M’，同时这种交接也会有开销。
- 最有意思的一点：首先得理解本地队列的意义，GM模型如果没有本地队列，锁竞争会更激烈，同时可能会有更多的M创建，休眠，销毁的过程，都是很大的开销。但是如果本地队列连在M上，发生系统调用的时候M会被阻塞，这个时候这个本地队列就废了，上面的G都得等到M被重新唤醒以后才能运行了

## GMP 调度器

<img src="https://www.topgoer.com/static/7.1/gmp/12.jpg"  style="zoom:50%"  />

- 全局队列（Global Queue）：存放等待运行的 G。
- P 的本地队列：同全局队列类似，存放的也是等待运行的 G，存的数量有限，不超过 256 个。**新建 G’时，G’优先加入到 P 的本地队列，如果队列满了，则会把本地队列中一半的 G 移动到全局队列。**
- P 列表：所有的 P 都在程序启动时创建，并保存在数组中，最多有 GOMAXPROCS(可配置) 个。
- M：线程想运行任务就得获取 P，从 P 的本地队列获取 G，P 队列为空时，M 也会尝试从全局队列拿一批 G 放到 P 的本地队列，或从其他 P 的本地队列偷一半放到自己 P 的本地队列。M 运行 G，G 执行之后，M 会从 P 获取下一个 G，不断重复下去。

注意：那个的本地队列是P管理的，P的结构体中内容

#### P 和 M数量问题

1. P的数量

   由启动时环境变量 $GOMAXPROCS 或者是由 runtime 的方法 GOMAXPROCS() 决定。**这意味着在程序执行的任意时刻都只有 $GOMAXPROCS 个 goroutine 在同时运行。**

   GOMAXPROCS和线程数的区别：？

2. M的数量

   + go 语言本身的限制：go 程序启动时，会设置 M 的最大数量，默认 10000. 但是内核很难支持这么多的线程数，所以这个限制可以忽略。

   + runtime/debug 中的 SetMaxThreads()，设置 M 的最大数量

   + 一个 M 阻塞了，会创建新的 M。

#### P 和 M 创建时机

1、P 何时创建：GOMAXPROCS设置成n的同时，这n个P就被创建了**。

2、M 何时创建：没有足够的 M 来关联 P 并运行其中的可运行的 G时就会创建M，**注意是P去创建M，P有创建M的能力，且M和P是绑定的**。比如所有的 M 此时都阻塞住了，而 P 中还有很多就绪任务，就会去寻找空闲的 M，而没有空闲的，就会去创建新的 M。

### 调度器策略

1）work stealing 机制

 当本线程无可运行的 G 时，m会尝试从其他线程绑定的 P 偷取一半的G放到自己的p的本地队列里面，而不是销毁线程。

2）hand off 机制

 当本线程因为 G 进行同步系统调用时，线程释放绑定的 P，把 P 转移给其他空闲的线程执行。

3）抢占机制

go里面一个 goroutine 最多占用 CPU 10ms，防止其他 goroutine 被饿死

### 常见调度场景（易错）

注意：系统调用实际上是内核处理，已经不在用户态上面了，所以系统调用的阻塞肯定会阻塞线程（即阻塞M），不可能像channel那样只阻塞G

+ 阻塞系统调用

  <img src="/Users/yixia/Desktop/coding-experience/干死小公司妈的/图片/31.jpeg"  style="zoom:40%"  />

1. G8 进行了阻塞的系统调用，M2 和 P2 立即解绑，P2 会执行以下判断：如果 P2 本地队列有 G、全局队列有 G 或有空闲的 M，P2 都会立马唤醒 1 个 M 和它绑定**（注意，以上三种情况都会绑定M）**否则 P2 则会加入到空闲 P 列表，等待 M 来获取可用的 p。

2. 注意上面那个“否则”，简直他妈的至关重要！！！！这就意味着P也有空闲列表。即如果不满足上述三个条件，即假如在上图中P2的本地队列是空的，休眠线程队列也是空的，全局队列也是空的，**这个时候就不会有新的M被创建**，这个P2也会被加入空闲P列表

3. 因为有了2，所以系统调用结束以后的操作就很显然了，如果G8-M2的系统调用结束了，G8并不会直接被放入全局，这个时候分两种情况：

   + 如果有空闲的P，则M2获取一个P，继续执行G8（在非阻塞调用的时候有区别）。

   + 如果没有空闲的P，则将G8放入全局队列，等待被其他的P调度。然后M2将进入缓存池睡眠。

+ 非阻塞系统调用

  <img src="/Users/yixia/Desktop/coding-experience/干死小公司妈的/图片/32.jpeg"  style="zoom:40%"  />

  G8进行非阻塞调用，M2 和 P2 会解绑，**但 M2 会记住 P2**，然后 G8 和 M2 进入系统调用状态。**注意这里的异步调用不包括后面将讨论的网络IO和部分文件IO**，当 G8 和 M2 退出系统调用时，有三种情况：

  1. **会尝试获取 P2**
  2. 如果无法获取P2，则获取空闲的 P
  3. 如果没有P2也没有空闲P，G8 会被记为可运行状态，并加入到全局队列，M2 因为没有 P 的绑定而变成休眠状态 (长时间休眠等待 GC 回收销毁)。

+ 阻塞

  这里阻塞找不到具体的调度图，是因为不同的阻塞可能调度的方式不一样，但总体来说可以用下面两图表示（这是channel的情况）

  下图是阻塞的开始：

  <img src="/Users/yixia/Desktop/coding-experience/干死小公司妈的/图片/channel_block.png"  style="zoom:20%"  />

  1. 这里G1执行了一个阻塞的操作，图中是往一个满了的channel里面发送数据，这个时候会挂起，注意这里使用的是gopark，但实际上当等待一个悲观锁的时候（普遍情况，不讨论golang里面互斥锁的两种模式）**也会挂起**，但可能用的不是gopark
  2. **注意这里G1阻塞以后直接就被移除M了，这才叫挂起，和同步系统调用不同**，在channel的例子里面g中的m直接就置为nil了

  下面是阻塞的结束：

  <img src="/Users/yixia/Desktop/coding-experience/干死小公司妈的/图片/channel_unblock.png"  style="zoom:20%"  />

  

  

  这里G2做了一个操作，实际上是解除了G1的阻塞，注意！！！，G1看没看到！！被立马加入到解除它的G所在的P中去了！！，这个非常关键，这个也就告诉我们了那个被因为阻塞而被解除了M的G1并不是孤魂野鬼的协程，它会被唤醒的时候也是有地方去的


## IO操作

### 网络IO

不同的操作系统也都实现了自己的 I/O 多路复用函数（最原始的是select），golang针对不同操作系统的这些复用函数各开发了一套网络轮询器。你可以说golang的网络轮询器封装了底层操作系统的网络轮询器

1. 当某一个Goroutine在进行网络IO操作时，如果网络IO未就绪，就将其该Goroutine封装一下，放入epoll的等待队列中，当前G挂起，**与其关联的M可以继续运行其他G(说明是非阻塞的)**。

   <img src="/Users/yixia/Desktop/coding-experience/干死小公司妈的/图片/94_figure4.png"  style="zoom:30%"  />

2. 当相应的网络IO就绪后，Go运行时系统会将等待网络IO就绪的G从epoll就绪队列中取出（主要在两个地方从epoll中获取已网络IO就绪的G列表，一是sysmon监控线程中，二是自旋的M中），再由调度器将它们像普通的G一样分配给各个M去执行。

   ```go
   func sysmon() {
   	...
   	for {
   		...
   		lastpoll := int64(atomic.Load64(&sched.lastpoll))
   		if netpollinited() && lastpoll != 0 && lastpoll+10*1000*1000 < now {
   			atomic.Cas64(&sched.lastpoll, uint64(lastpoll), uint64(now))
   			list := netpoll(0)
   			if !list.empty() {
   				incidlelocked(-1)
   				injectglist(&list)
   				incidlelocked(1)
   			}
   		}
   		...
   	}
   }
   ```

   这段代码就是sysmon从epoll里面找就绪的goroutine的地方，那个list就是已经网络IO就绪的goroutine，那个injectlist函数就是把这些就绪的goroutine**放到全局队列中**（我目前能看懂的是放到全局中了）

   

   ***网络IO操作这样处理有一个好处就是：netpoller那个线程已经有了，网络io阻塞不需要创建新的线程。同时假如空闲线程很多，这种方案也节省了M切换带来的开销***

   











