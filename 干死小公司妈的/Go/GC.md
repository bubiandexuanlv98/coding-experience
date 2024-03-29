# GC

<https://blog.csdn.net/xiaodaoge_it/article/details/121890145>

## 触发条件

1. 堆内存的分配达到控制器计算的触发堆大小；这里计算的是内存分配里面的bitmap
2. 如果一定时间内没有触发，就会触发，默认为 2 分钟；
3. 如果当前没有开启垃圾收集，则触发新的循环；（没看懂）

## 三色扫描

- 强三色不变性 — 黑色对象不会指向白色对象，只会指向灰色对象或者黑色对象；
- 弱三色不变性 — 黑色对象指向的白色对象必须包含一条从灰色对象经由多个白色对象的可达路径

三色扫描里面，灰色是待扫描，黑色是已扫描，白色是要回收的。什么狗屁强弱三色不变，就是一个原则，**黑色不能单一指向白的**，因为黑色不会再被扫描了，所以黑单一指向白会导致白一直是白的，最后白的被回收，黑指向发生空悬挂！！

## GC过程

### 第一阶段：gc开始，std(stop the world)

初始所有内存都是白色的，进入标记队列就是灰色

1. stop the world
2. **每个processor启动一个mark worker goroutine用于标记（第二步）**
3. 启动gc write barrier，启动用户程序协助（Mutator Assists，如果有的话，这个是如果发现清理速度不够就有）
4. 将根对象加入标记队列（work.markrootJobs，这个时候还没开始标记），所谓根对象包括所有 **Goroutine 的指针（注意不是goroutine上的变量）**、全局变量以及不在堆中的运行时数据结构（最后一个不太理解，到时候就是“等”）
5. start the world，进入第二阶段

#### 注意：

1. 这一步是不和用户程序并行的
2. 第2步里面，虽然每一个processor都分配了一个Mark worker，但是在实际标记当中，同时进行标记工作的不能超过CPU使用率的25%

### 第二阶段：marking，start the world

1. 启动程序，执行markroot（这个一次gc只执行一次），从标记队列取出根对象扫描，当扫描到某一个goroutine的指针（栈对象）期间会暂停当前处理器，**然后把这个栈对象上的所有变量一把全部扫掉，而且是一次性扫黑（从v1.8以后）**，注意接下来并不会把栈上的对象放到扫描队列里面（因为已经都是黑色的了）

   *注意：栈上的对象扫黑了说明与栈上对象关联的堆上的对象都扫成灰色的了*

2. 取出扫描队列中的对象（这些都是堆上或者是全局变量了），将他们标记成黑色，并将它们指向的对象标记成灰色；

3. 在扫描过程中，对于所有非栈对象，如果用户代码删除对象，那么会触发写屏障，将删除的对象标记为灰色（对应Yuasa 删除写屏障），如果是修改，则要看当前栈是否已经被修改（修改后栈是灰的）如果修改过，就把修改的目的地址标灰，没修改过，就不用变灰

4. 如果过程中新建对象则直接被标记成黑色

#### 注意：

1. 这个阶段是和用户的程序并发一起运行的

2. 所有进入队列中的对象逻辑上就认为是灰色的

3. 为什么上面3中，如果是修改，如果没扫描过，则当前节点肯定是白的（这个逻辑比较复杂），新指向的有可能没有  。那么应该把，扫描过说明当前对象肯定也会变灰，后面的不用提前考虑，但是如果没扫描过，则有可能会出现断开的情况。

   

### 第三阶段：标记终止，stop the world

1. **暂停程序**、将状态切换至 `_GCmarktermination` 并关闭辅助标记的用户程序；
2. 清理处理器上的线程缓存；
3. 将状态切换至 `_GCoff` 开始清理阶段，初始化清理状态并关闭写屏障；

### 第四阶段：sweep，start the world

1. 恢复用户程序，所有新创建的对象会标记成白色；
2. 后台并发清理所有的内存管理单元，当 Goroutine 申请新的内存管理单元时就会触发清理；



### 写屏障

写屏障技术实际上是在转成编译码的时候体现出来的，代码里面并没有，代码中会设置一个开关开启

补充：内存屏障技术是一种屏障指令，它可以让 CPU 或者编译器在执行内存相关操作时遵循特定的约束，目前多数的现代处理器都会乱序执行指令以最大化性能，但是该技术能够保证内存操作的顺序性，在内存屏障前执行的操作一定会先于内存屏障后执行的操作。

#### 版本迭代

+ 1.7以前

  在 Go 语言 v1.7 版本之前，运行时会使用 Dijkstra 插入写屏障保证强三色不变性，但是运行时并没有针对栈上的根对象开启插入写屏障。这是因为可能程序包含成百上千个goroutine，每个goroutine都有自己的栈，如果在每个栈上都开启写屏障，这个开销不可接受。因此Go 团队在实现上选择了在标记阶段**如果这个栈上的对象发生改变，则把这个栈标灰，标记完成后对所有标灰的栈全部重新扫描。栈对象标记为灰色并重新扫描**，在活跃 Goroutine 非常多的程序中，重新扫描的过程需要占用 10 ~ 100ms 的时间。

+ 1.8以后

  Go 语言在 v1.8 组合 Dijkstra 插入写屏障和 Yuasa 删除写屏障构成了如下所示的**混合写屏障**，该写屏障会**将依据删除写屏障，把被覆盖的对象标记成灰色，然后判断如果当前栈已经被扫描，则将新对象也标记成灰色**，那个if语句不看就相当于是把两个写屏障完全融合了

  栈上所有元素一开始就标黑+混合写屏障+新申请的全部标黑（有人说只是栈上新申请的全部标灰）+栈上发生变化就把栈标灰（这点没啥太大用只是提升一下效率），保证了即使栈上不开写屏障，也不用最后重新扫栈

  ```go
  writePointer(slot, ptr):
      shade(*slot) // 这个shade是标灰的意思
      if current stack 被标灰: // 栈被标灰和元素被标灰是两个概念
          shade(ptr)
      *slot = ptr
  ```

#### 混合写屏障

1. 这里主要讲一下为什么上面那三个机制能产生那样神奇的效果

+ C，A，B三个是堆上对象（这里主要讲他们之前发生转换的时候发生的变化，如果他们当中有新生成的，直接标黑就行了）

  1. C->A，A->B，B是白的，C是黑的，A是灰的，C（通过A->B）指向B同时C->A断掉（C不能同时指向A和B），然后A->B断掉（A->B不断无所谓，因为即使A已经不可达了但A仍然是灰的，C可以变灰），这个时候C->B是一条单一的黑->白。为了防止这个，混合写屏障`shade(*slot)`会在A->B断掉的时候把B从白的变成灰的（C->A断掉的时候A也会因为`shade(*slot)`变灰，不过A已经是灰的了）
  2. C->A，C-B，B是白的，C是黑的，A是黑的，A（通过C->B）指向B，这个时候A->B是一条单一的黑->白。为了防止这个，混合写屏障`shade(*slot)`会在A->B的时候把A从黑的变成白的
2. C，D在同一个栈上，A，B是堆上，C->A->B，D，此时CD都是黑的，A是灰的，B是白的，这时D->B的联系，由于D是栈上，栈被修改了，因此栈变灰了，那个if语句起效果了，就把B标灰了（其实后序如果AB断开，还会有删除写屏障保护着，但这不没效率了嘛）

那个if语句实际上保证了，如果当前栈已经被修改过，那么此时就把这个当前栈上引出去的堆元素的操作目标地址标灰，因为这个目标地址很有可能在前面被栈上已经扫描过（黑色的的栈元素）引用了，但引用的时候没开写屏障

2. 为什么只有插入写屏障+栈上不开写屏障必须要在最后STW

   C->A，A->B，C在栈上，C黑，A灰，B白，C换指向了B，因为栈上没开写屏障，B没有标灰，如果把A-B断开，那C就直接指向B，一个黑色直接单一指向白色，出错，因此需要最后扫栈

3. 为了把stw去掉，v1.8以后使用了：
   + GC刚开始的时候，会将栈上的可达对象全部标记为黑色。
   + GC期间，任何在栈上新创建的对象，均为黑色。（有人说堆上也是，不过这点存疑）
   + 混合写屏障（堆上被删除的对象标记为灰色 + 堆上新指向的对象标记为灰色）
3. 其实删除写屏障+上面那一大堆+栈上不开写屏障已经避免了最后重新扫栈，为啥还要用一个插入写屏障

​	因为删除写屏障会带来一定冗余标记，两者结合可以减少一部分冗余的扫描和标记操作。

#### 插入写屏障与删除写屏障

直接看这个<https://draveness.me/golang/docs/part3-runtime/ch07-memory/golang-garbage-collector/#%E6%B7%B7%E5%90%88%E5%86%99%E5%B1%8F%E9%9A%9C>，其他的都不对。这个不对：<https://github.com/golang-design/under-the-hood/issues/20>