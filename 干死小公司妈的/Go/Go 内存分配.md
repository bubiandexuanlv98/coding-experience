# Go内存分配

注意这里讲的都是堆上的内存分配，内存分配器是针对堆的

1. 这个用来看spans, bitmap, arena 干啥的：<https://zhuanlan.zhihu.com/p/59125443>
2. 大对象分配和gc：<https://luna.xin/a/16>
3. 小微对象和分块的内存：https://zhuanlan.zhihu.com/p/59125443



mspan: 链表中每个Span根据Class的级别会存储不同数量的Page页，也就是说一个span

分配流程：

- 32KB 的对象，直接从mheap上分配；
- <=16B 的对象使用mcache的tiny分配器分配；
- (16B,32KB] 的对象，首先计算对象的规格大小，然后使用mcache中相应规格大小的mspan分配；
- 如果mcache没有相应规格大小的mspan，则向mcentral申请
- 如果mcentral没有相应规格大小的mspan，则向mheap申请
- 如果mheap中也没有合适大小的mspan，则向操作系统申请