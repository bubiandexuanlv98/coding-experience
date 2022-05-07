## 内存模型

### 定义

Go内存模型指定了一系列条件，在这些条件下，可以保证在一个goroutine中读到其他goroutine中对这个变量所写的值。

### 单线程场景

### 多线程场景（同步条件）

<https://mp.weixin.qq.com/s?__biz=MzUxMDI4MDc1NA==&mid=2247489355&idx=1&sn=8a9511359ee971cb1276fe286b1cc08b&chksm=f9040216ce738b002793ec8233c26b25dbe2dfb5116b7f98cf04630698f7e0d088aea505cfcb&scene=178&cur_album_id=1751854579329056768#rd>

记住一点：channel有buffer，发先于接。channel无buffer，接先于发。
