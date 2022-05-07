### 数据结构

+ 切片slice

  1. 切片实际上是一个结构体

   ```
   type slice struct {
    array unsafe.Pointer  // Data section
    len   int          // length
    cap   int             // capacity
  }
   ```

  1. nil切片（或叫nil）：切片0值可以认为是nil切片(即slice{nil})，这个是专门定义出来的类型0值，你可以认为是定义出来一个专门的slice类型的nil([]T(nil))，事实上所有0值是nil的类型都可以看做定义了一个本类型的nil作为0值（这只是为了类型安全，虽然nil本身其实是untyped的）。slice类型0值和单纯地结构体类型0值不一样，结构体0值也没专门定义出来一个结构体类型的nil
  2. 切片0值的长度是0，容量是0，可以for range迭代它
  3. 空切片：`a := []T{}`这个是一个空切片，它的指针指向的是一个空数组，也就是说它的指针不是nil，它的长度是0，容量是0，看以下代码：

   ```
  var a []int
  fmt.Print(a == nil) // true
  for ... := range a // 这种写法正确，可以迭代一个空指针
   ```

  4. 使用for index,value := range(slice)得到的value是值拷贝，你修改value是改不了slice里面的
  5. 切片扩容

    + 如果切片的容量小于 1024 个元素，于是扩容的时候就翻倍增加容量。一旦元素个数超过 1024 个元素，那么增长因子就变成 1.25 ，即每次增加原来容量的四分之一。
    + 有一个非常关键的点一定要注意，**就是切片扩容的时候可能不产生新数组！！！！！**这两种情况一定要区分
      + 如果slice指向的数组，数组长度大于len，这个时候加入
        问题：如果slice是结构体那为什么slice的可以有0值，专门定义了slice类型的nil值？比较的时候发生转换？对！我的直觉是对的，可以看下面对nil的解释

  6. 切片clone效率

    ```
    sClone := make([]T, len(s))
    copy(sClone, s)
  
    sClone := append(s[:0:0], s...)
    ```

    上面这两种方法，第一种在s是一个纯切片的时候效率更高，第二种在s不是纯切片或者第一种的make有大于两个参数的时候更快，即下面几种情况

    ```
    // 情况二：
    var s = make([]byte, 10000)
    y = make([]T, len(s), len(s)) // not work
    copy(y, s)
  
    // 情况三：
    var a = [1][]byte{s}
    y = make([]T, len(a[0])) // not work
    copy(y, a[0])
  
    // 情况四：
    type T struct {x []byte}
    var t = T{x: s}
    y = make([]T, len(t.x)) // not work
    copy(y, t.x)
    ```

  7. append加入元素

    + append可以直接对nil切片操作，这样的操作是允许的：`append([]T(nil), T)`
    + append不一定会重新分配内存，如果加入一个或几个元素以后，**切片长度没有超过底层数组长度（cap），就不会重新分配内存**，而且如果原来底层数组那些位置是有值的，append进去的元素会**覆盖**原来底层数组的那些位置的数字。

  8. reslice

    + 切片再切片的时候时间复杂度为O(1)，因为底层数组没有变化。也没有出现数据迁移

  9. 两个切片不可以比较，因为切片是不可比较类型，但是两个string经过切片以后是可以比较的

+ string 类型

  ```
  type _string struct {
    elements *byte // underlying bytes
    len      int   // number of bytes
  }
  ```

  1. string类型时可比较的，所有比较符号都适用，elements指向底层byte数组，当比较的时候，会把底层的bytes数组一个一个的比较，两个切片不可比较，但是两个string经过切片以后是可以比较的



## new 和 make 的区别

1. new和make都分配内存空间，make只能用于分配slice，map和channel的，new可以针对所有类型
2. new返回的是分配的内存空间的地址，这个**内存空间里面存放的是这个类型的0值**，make返回的是这个类型的初始化后的值，即返回的是一个有初始值的一定记住不是0值

```
a := make([]int) 这个不允许，只有切片是要求用make的时候必须传2个参数及以上的
a := make([]int, 0) 这个实际上是一个空切片，不是切片类型0值，即它的element指针并不是nil，也就是说这个时候a实际上是指向一个底层数组的，这个底层数组也被分配了，只不过底层数组长度为0，而且这个底层数组其实是先被分配的
```

make这个操作的原因本质还是因为数据结构在被引用之前要先被初始化，也就是说得先有

3. 注意make channel后返回的是一个指向channel（在堆上）的指针

## 类型系统

#### 引用类型与值类型

值类型：基本数据类型int, float,bool, string以及数组和struct

```
值类型：变量直接存储值，内容通常在栈中分配
 var i = 5       i -----> 5
```

引用类型：指针，slice，map，chan等都是引用类型

```go
引用类型：变量存储的是一个地址，这个地址存储最终的值
ref r ------> 内存地址 -----> 值
```

+ struct

  1. struct是non-nil的，也就是说：default value of a struct will contain the default value for all its fields. struct的类型0值是一个struct里面的field都是0值。
  2. 结构体0值，占用的字节数是0

+ nil

  1. nil很有意思的一点是它是一个untyped(golang中有很多untyped，比如所有字面量都是untyped)，但是它是唯一一个没有default type（比如3.4的default type是float）
  2. nil因为是untyped，所以golang里面的类型转化会把它转成需要的类型，所以下面几个都是正确的

   ```
  var _ = (int)(nil) == nil
  var _ = ([]int)(nil) == nil
   ```

  3. nil分为bare nil和类型nil，编译器必须知道一个nil的类型，可以认为nil是跟着类型走的，不同类型的nil不不一样，同一种类型的nil可以相互比较，但是如果这种类型本身是incomparable的（比如slice类型），那么这种类型的nil是不可比较的

   ```
  var _ = (int)(nil) == (int)(nil) // true
  var _ = ([]int)(nil) == ([]int)(nil) // 报错
  var a []int 
  a == []int(nil) 报错
   ```


## defer

1. go允许多值返回，返回的时候会先把返回值压栈，然后执行defer函数，所以如果defer函数中有修改返回值的内容，就会把返回值修改了
2. defer函数在所在的函数返回、函数结束**或者对应的goroutine发生panic的时候**defer就会执行，这就解释了为啥lock以后要立马defer unlock，这是因为防止中间发生panic，这个锁放不开造成死锁


## 类型宽度

1. int，uint在32位机里面是4 bytes，64位机里面是8 bytes，
2. byte是uint8类型的别名，rune是一个int32类型的别名
3. uint8最大是255，int8最大是127，最小是-128
4. uint类型在进行+, -, *, and <<这些运算的时候，是把计算结果对2^n取模的，n是uint类型对应的bit宽度，比如uint32中n是32。但是要注意下面这个是错误的：

```
var num uint32 = 1 << 35
```

因为你这个实际上是在赋值，1<<35是一个常量，并不是，其中<<并不是在针对uint类型进行计算

5. int类型在计算的时候发生溢出是可以正常计算的，但你会发现最终结果还是原类型，这就会让一部分数据丢失

## context 原理

1. <https://juejin.cn/post/6844904070667321357>
   里面很有意思的一段是下面这段代码：

```
type CancelFunc func()

func WithCancel(parent Context) (ctx Context, cancel CancelFunc) {
    c := newCancelCtx(parent)
    propagateCancel(parent, &c)
    return &c, func() { c.cancel(true, Canceled) }
}

// newCancelCtx returns an initialized cancelCtx.
func newCancelCtx(parent Context) cancelCtx {
    // 将parent作为父节点context生成一个新的子节点
    return cancelCtx{Context: parent}
}

func propagateCancel(parent Context, child canceler) {
    if parent.Done() == nil {
        // parent.Done()返回nil表明父节点以上的路径上没有可取消的context
        return // parent is never canceled
    }
    // 获取最近的类型为cancelCtx的祖先节点
    if p, ok := parentCancelCtx(parent); ok {
        p.mu.Lock()
        if p.err != nil {
            // parent has already been canceled
            child.cancel(false, p.err)
        } else {
            if p.children == nil {
                p.children = make(map[canceler]struct{})
            }
            // 将当前子节点加入最近cancelCtx祖先节点的children中
            p.children[child] = struct{}{}
        }
        p.mu.Unlock()
    } else {
        go func() {
            select {
            case <-parent.Done():
                child.cancel(false, parent.Err())
            case <-child.Done():
            }
        }()
    }
}

func parentCancelCtx(parent Context) (*cancelCtx, bool) {
    for {
        switch c := parent.(type) {
        case *cancelCtx:
            return c, true
        case *timerCtx:
            return &c.cancelCtx, true
        case *valueCtx:
            parent = c.Context
        default:
            return nil, false
        }
    }
}
```

这段代码里面那个propagateCancel是最有意思的，它的点在于，实际上子CancelCtx是被挂到祖先CancelCtx的children里面，然后方便进行后序删除的。

## channel 原理

1. channel 发送和接收过程：<https://speakerdeck.com/kavya719/understanding-channels>
2. 辅助理解：chanrecv和chansend：<https://draveness.me/golang/docs/part3-runtime/ch06-concurrency/golang-channel/>。goready和gopark：<https://blog.csdn.net/u010853261/article/details/85887948>

## GMP模型

1. <https://www.topgoer.com/%E5%B9%B6%E5%8F%91%E7%BC%96%E7%A8%8B/GMP%E5%8E%9F%E7%90%86%E4%B8%8E%E8%B0%83%E5%BA%A6.html>
2. 看起来很牛逼的：<https://www.ardanlabs.com/blog/2018/08/scheduling-in-go-part2.html>这个其实解释异步系统调用的过程

## GC 机制

1. gc都是针对堆上的内存进行回收的
2. go 的gc机制三色标记法： <https://studygolang.com/articles/18850?fr=sidebar>
3. sweep，mark，stw发生时机问题：<https://agrim123.github.io/posts/go-garbage-collector.html>
4. ![lov] (./图片/GC时间线与STW" )
5. 
6. 深入理解gc：<https://programming.vip/docs/deep-understanding-of-go-garbage-recycling-mechanism.html>

## 一些比较经典的问题

<https://www.kancloud.cn/fruitbag/stack_of_gofuny/667895>

## 内存模型

### 定义

Go内存模型指定了一系列条件，在这些条件下，可以保证在一个goroutine中读到其他goroutine中对这个变量所写的值。

### 单线程场景

### 多线程场景（同步条件）

<https://mp.weixin.qq.com/s?__biz=MzUxMDI4MDc1NA==&mid=2247489355&idx=1&sn=8a9511359ee971cb1276fe286b1cc08b&chksm=f9040216ce738b002793ec8233c26b25dbe2dfb5116b7f98cf04630698f7e0d088aea505cfcb&scene=178&cur_album_id=1751854579329056768#rd>

记住一点：channel有buffer，发先于接。channel无buffer，接先于发。

1. 为什么GMP需要P

我觉得直接看GM的缺点在哪比较直观：

GM有几个缺点：

- 创建、销毁、调度 G 都需要每个 M 获取锁，这就形成了激烈的锁竞争。
- M 转移新创建的 G’ 时会造成延迟和额外的系统负载，局部性很差。比如M中运行着G，当 G 创建新协程G'的时候，G'会被M交接到别的M‘上运行（M为了继续运行G）但是 G’和 G 是相关的，最好放在 M 上执行，而不是其他 M’，同时这种交接也会有开销。
- 最有意思的一点：首先得理解本地队列的意义，GM模型如果没有本地队列，锁竞争会更激烈，同时可能会有更多的M创建，休眠，销毁的过程，都是很大的开销。但是如果本地队列连在M上，发生系统调用的时候M会被阻塞，这个时候这个本地队列就废了，上面的G都得等到M被重新唤醒以后才能运行了



