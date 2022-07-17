# Go 语言环境

1. vscode上编写Go，有三个环境变量必须要设置，GOPATH，GOPROXY，GO111MODULE，第一个变量是你go地址的位置，后面两个是用来下载插件的，不设置下载不了
   后面两个参数值可参考：<https://studygolang.com/articles/28125>
   第一个参数如何设置？这个看起来如果有多个项目岂不是废了？
2. go环境变量的设置，可以使用go env -w 持久化设定，`does not override conflicting OS environment variable`是提醒你查看一下你的bash_profile或者bashrc，里面如果设置了export，会覆盖掉这个持久化设定
3. 如果要下载特定版本的go的依赖包，只能下载带v的版本，如果没有的话需要把依赖包拷到本地，自行找对应的branch的打tag（过程参见：https://blog.csdn.net/weixin_41769812/article/details/108402247），然后在go.mod里面用这个tag下载，如果仍想使用特定包名，可以使用replace把特定包名映射到私有库
4. 如果报404的错误，要么检查是否存在这个tag，以及这个tag是否带v，还有一种情况就是使用-insecure参数下载，如果还出问题
5. vscode里面写的时候，通过别的终端go get来的可能会有问题，要在自带终端里面go get成功，工作区的bug才会消失

# GoLand 编辑器
1. 一个非常有用的破解方法：<https://zhile.io/2020/11/18/jetbrains-eval-reset-da33a93d.html>
2. Gonano 这个插件可以帮忙定义函数注释模板，在tools里面的Gonano settings里面写模板，然后注释的时候按`ctrl+command+/`就可以调出模板了
3. 如果goland崩溃，然后再次打开发现有些文件打不开，或者不显示文件，统一办法：删除根目录下的.idea文件夹，重新生成
4. goland 检查comment，这个设置点右上角那些警示符，随后点右边那三个点，然后"configure inspections"，然后再code style issues 里面把comments相关的都勾选上
   

## Go 的不同之处
1. 数组是值类型，赋值和传参会复制整个数组，而不是指针。因此改变副本的值，不会改变本身的值
2. 数组传参的时候必须要写容量，切片传参可以不写
3. copy函数是有前后顺序的，一定是后者拷贝到前者，拷贝长度**按照两者中较短的len（注意不是cap）来**
4. 为了捕获异常还必须有defer？
5. 方法和普通函数的区别：1.对于普通函数，接收者（注意这里的接受者是指函数的参数，普通函数没有接收者的概念）为值类型时，不能将指针类型的数据直接传递，反之亦然。2.对于方法（如struct的方法），接收者为值类型时，可以直接用指针类型的变量调用方法，反过来同样也可以。
6. go 既不属于面向对象的语言，也不属于面向过程的语言，它虽然有”继承“的机制，也有“多态”机制，但是它的继承机制和多态机制和cpp那种继承和多态不一样。你可以说go的继承不是真正意义上的继承
7. **就继承而言子类虽然可以调用父类的方法，但它的”父类“不能指向”子类“（即无法满足CPP多态的三个必要条件中的一个：父类引用指向子类对象）**，但是存在方法重写（不存在重载，重载是相同函数名且形参不同）。**多态这个操作是靠接口实现的，不能像cpp那样通过继承实现**，接口类型的变量可以指向拥有这个接口的结构体（或者指向拥有这个接口的结构体的**指针**）  注意：在任何一种OOP语言中，父类都不可以调用子类中非重写的方法，因为这个很危险，万一多个子类实现了相同的方法，不知道调用的是哪一个子类的方法。在OOP语言中，父类引用指向子类对象后，是可以调用子类的重写方法的，这是多态性，多态性是OOP语言的特点之一
8. golang暂时没有泛型，c++的泛型事实上就是template
9. 


会不会通道里面的数据没取完通道就关闭了 不会



## Go 初始化
+ 包初始化：<https://yourbasic.org/golang/package-init-function-main-execution-order/>
   1. 包里面的变量的初始化是在这个包被import的时候，从package main开始，深度优先遍历。具体每一个包里面，变量初始化是按声明顺序，如果这个变量依赖别的变量，则先初始化别的变量。
+ init函数：<https://golangbyexample.com/init-function-golang/>
   1. 每个package都可以有一个init函数
   2. 这个主要是为了比如说你一个包级别的全局变量：redis_client，这个变量要初始化不只是实例一个struct就结束了，还要创建网络连接，这一系列的操作就可以放在init函数里面。
   3. init函数是在在每个包初始化变量之后被执行的。


### 使用技巧
#### 减少冗余代码
+ 像struct，slice，map这种组合数据结构，如果这些结构里面还有这些结构，也就是nested composite，使用字面量初始化的时候，只要在最外层指明结构名称，内部不需要在指明名称，比如：
  ```
  var _ = map[LangCategory]map[string]int{
	{true, true}: {
		"Python": 1991,
		"Erlang": 1986,
	},
	{true, false}: {
		"JavaScript": 1995,
	},
  }
  ```

### 内存泄漏
+ slice的内存泄漏
  ```
  var s0 []int
  func g(s1 []int) []int {
    // Assume the length of s1 is much larger than 30.
    s0 = s1[len(s1)-30:]
    return s0
  }
  ```
  退出g以后就发生了内存泄漏，因为s0和s1共享底层数组，g函数结束以后外部可能会有东西继续拿着s0，使得s1的底层数组无法释放
  + 解决方案
    ```
    func g(s1 []int) {
      s0 = make([]int, 30)
      copy(s0, s1[len(s1)-30:])
      // Now, the memory block hosting the elements
      // of s1 can be collected if no other values
      // are referencing the memory block.
    }
    ```
    但要注意的一点是除非s0真的特别大，不然这样的话也很没必要，比如如果那里面是slice里面装的是很复杂的struct，这样的复制很费时。

+ slice里面是pointers造成的泄漏
  ```
  func h() []*int {
    s := []*int{new(int), new(int), new(int), new(int)}
    // do something with s ...
    return s[:2]
  }
  ```
  这个问题其实就是跟上一个问题是一样的，也可以通过上一问的方法复制一份，就好了，但下面这个解决方案这个给我们提供了一个新思路
  ```  
  func h() []*int {
    s := []*int{new(int), new(int), new(int), new(int)}
    // do something with s ...
    for i := range s[:2] { // 这种方式可以大大提升速度，因为内部调用的是memlcr
      s[i] = nil 
    }
    return s[:2]
  }
  ```
  我们可以通过置空指针的方式大大减小内存，同理如果一个slice里面存的是struct，我们可以通过上面这种方式高效的把后面的struct变成结构体0值，结构体0值占有0字节。有时候我们也需要用这种置空的方式处理[]int，不过这个主要是为了防止暂时性的内存泄漏，比如有多个切片引用着这个切片。

### 类型转化
+ golang 支持普通类型 int, int32, int64, float64, float32, string 的强制类型转换，
+ float转int的时候是截取尾部的
+ golang里面的指针都是带类型的，相互转化需要先用unsafe.Pointer强制转换成无类型的，然后再转化成对应类型。
  

## Go语法

+ interface 
  interface{}是一种类型，而interface不是


+ 首字母大小写问题：无论是方法名、常量、变量名还是结构体的名称，如果首字母大写，则可以被其他的包访问；如果首字母小写，则只能在本包中使用。可以简单的理解成，首字母大写是公有的，首字母小写是私有的。

+ go switch
  1. .(type)关键字
   这个关键字约束特别多，首先**它必须用在switch语句中**，其次**它必须用在interface{}上面**，用于判断interface{}的类型


+ go 流程控制语句语法
  1. if条件判断
   + if的条件是可以这样写的：`if ...; bool表达式`，...的内容可以不是定义变量，比如可以是print语句

+ struct
  1. 当需要表示结构体类型时，应该使用struct{}来标识，比如对于往channel里面传结构体类型的操作，应该使用struct{}来标识。struct{}{}是结构体的值，并且值为空的标识
  2. 结构体属性的大小写是有含义的，除了公有和私有的区别外，类属性如果是小写开头，则其序列化会丢失属性对应的值，同时也无法进行Json解析。
  3. 当自定义一个结构体类型a，a{}就代表一个全是默认值的结构体a
  4. 结构体类型0值是其所有field都不被初始化为对应的0值的东西


+ go 单引号双引号反引号
   单引号 不能用来表示字符串
   双引号 可解析的字符串字面量 (支持转义，但不能用来引用多行，多行必须使用`\n`隔开)；
   反引号 原生的字符串字面量 ，支持多行，不支持转义, 多用于书写多行消息、HTML以及正则表达式。

+ go 字符串拼接
  有三种方式，速度上有差距
  <https://www.cnblogs.com/mambakb/p/10352138.html>

+ go 打印
  1. fmt.Printf()
   这个函数如果你在里面使用`fmt.Printf("%d", t)`，那个特定的%d可以把interface类型转换成想要的类型，这里是整形

+ 类型转换
  1. 强制类型转换：普通类型的转换都一样的，指针的强制类型转换要注意
   <https://studygolang.com/articles/21591?fr=sidebar>
      不同类型之间的变量是不能直接进行算术运算的，
      
  2. **golang之中没有变量之间的隐式类型转换**，但是存在变量与常量之间的隐式类型转换（仅限两种类型兼容比如：123.0可以转换成123，但是123.1不能转换成123）。而且常量之间的运算时也可以隐式转换。
  
  3. 字符串与数字的转换
  
      + 字符串转数字
      
        1. `strconv.Atoi` 字符串转int (注意这个是有两个返回值的) 
           `strconv.Itoa` int转字符串  
           一般业务上不用这两个，直接用`strconv.ParseInt(s string, base int, bitSize int) (i int64, err error)`（字符串转int）
      
        2. ParseInt参数前一个是当前base，**后一个是十进制的宽度，int8，int16还是64！！！（其中0就是int）**，**注意parseInt只能把字符串转换成10进制**，后序再转2进制或者别的进制要用下面那个函数，不过最终得到的是字符串（说明golang没有二进制类型）
      
        3. 负数也可以相互转化，两个方向都可以！！！
      
      + 数字转字符串
      
        1. `strconv.FormatInt(i int64, base int) string`（int转字符串，但注意这里base是指目标字符串的进制数）
           其他类型（float，bool，二进制）的转换见：<https://www.cnblogs.com/f-ck-need-u/p/9863915.html>
        2. 如果是负数，转别的进制的时候不会出现补码，**只是会在前面加个负号**，然后后面的数值就是原数字的绝对值
      
  4. 当把0-9的int转换为byte的时候，**一定要是`byte = byte('0' + int)`**，byte转回去的时候是`int = int(byte - '0')`，如果你不care绝对数值，只care差值，那么你可以`byte(int)`这样转，转完以后的结果是ascii码值为int的byte。类似的`string(int)`表示ascii码值为int的rune
  
  5. string()这种转换方式会把数字转成ASCII码对应的字母，所以数字转字符串的时候，不能用这个
  
  6. 很恶心的一个地方是"00" == string([]byte{'0', '0'})，但是“00” != string([]byte{byte(0), byte(0)})，这个是因为string底层是byte数组，string拆开了也必须和byte的表示方式一样 
  
+ go string类型
  1. 对于一个string类型，它的索引仍然是string类型。即a是string类型，a[1:4]也是string类型
  2. len()得到的是byte的长度
  3. 遍历字符串的时候用索引的方式取值，取出来的一定是byte。遍历的时候用range那种取出来的值可以是rune也可以是byte
  3. string的比较==

+ go 字符类型
  1. rune类型
  2. byte类型
  
+ go 引用传递和值传递的问题
  很明显，golang中的map和slice是引用传递，像int，float之类的肯定是值传递。

+ go 格式化占位符
  <https://studygolang.com/articles/2644>

+ go 排序
  
  1. 使用sort.Ints..., sort.Sort, sort.Slice, sort.SliceStable 来排序
     这几种排序方式比较：<https://blog.csdn.net/kevin_tech/article/details/104093924>
     注意：默认情况下，这些排序都是正序，如果要逆序，可以使用这种方式：
  
  ```go
   a := []int{5, 3, 4, 7, 8, 9}
   sort.Slice(a, func(i, j int) bool {
      return a[i] > a[j]
   })
  ```
  
  2. sort函数中的less函数，它的意义是：reports whether the element at index `i` should sort before the element at index `j`. **If both `less(i, j)` and `less(j, i)` are false**, then the elements at index `i` and `j` are considered equal。
  
     注意，i，j 没有大小区别，就是任意的两个下标。**而那个equal指的是代码会认为这两个位置上的数值是相等的**（即使本身并不相等）
  
  3. sort.Slice和sort.SliceStable 的区别就是当2中less函数返回是false（即认为两个位置的数值相等的时候）的时候，
  
  ```go
  func Slice(x any, less func(i, j int) bool)
  func SliceStable(x any, less func(i, j int) bool)
  ```
  
  
  
+ go 方法
  
  1. go的方法的接收者为值类型时，可以直接用指针类型的变量调用方法，反过来同样也可以
  
+ go 变量作用域
  go 短变量作用域是花括号内，也就是说在if判断，for循环这些代码块内声明的短变量只作用在这些代码块内

+ go make和new和{}的区别
  <https://www.jianshu.com/p/0c5650eadbcc>

+ go 位运算
  1. ^这个运算符，**单目运算的时候表示取反，双目运算的时候表示异或**

+ go 锁
  1. 对锁的理解很重要，一定要记住锁是用来修饰代码块的！！！！，锁是一个临界区的概念，如果在一个代码块前面mutex.Lock()意思是接下来的代码是临界区，只有在这里获取锁才能进入下面的代码。
  2. 锁下面出现一个变量，并不是说别的地方就访问不了这个变量，别的地方如果不加锁访问（读或者写）就可能会读到脏数据或错误数据（这种脏数据是由于写的协程产生的结果）。这一块可以参见Java中的volatile：<https://blog.csdn.net/u012723673/article/details/80682208>第八点。这一点也是为啥golang中双锁的意义：<https://launchdarkly.com/blog/golang-pearl-thread-safe-writes-and-double-checked-locking-in-go/>
  3. 对同一个共享变量shared_v加的锁一定要是同一把锁，不然锁不住的，A协程写的时候加一把锁a（相当于写的时候获取锁a），B协程写加另一把锁b（获取锁b），B协程修改这个shared_v的时候不需要获得锁a，所以就可能和A协程同时修改共享变量shared_v造成错误
  4. 互斥锁（Mutex）和读写锁（RWMutex）
   + 多读少写的时候要使用读写锁
   + 因为golang里面没有volatile，所以读写锁用的比较多

+ go 循环
  
  + 循环变量capture的问题
    
    无论对于`for key, value := range ...` 循环还是`for i`的循环，那个key/value和i在循环中不会redeclare，他们引用的值会变化（包括channel也是的）。这个时候如果你在循环中起协程，这个协程需要用到循环变量，一定要保证这个循环变量要在进协程之前复制一份
    
    ```go
    // 错误
    for i := 0; i < 5; i++ {
      go func() {
        fmt.Println(i)
      }()
    }
    
    // 错误
    for i := 0; i < 5; i++ {
       go func() {
         ii := i
         fmt.Println(ii)
       }()
     }
    
    // 正确
    for i := 0; i < 5; i++ {
       go func(ii int) {
         fmt.Println(ii)
       }(i)
     }
    
    // 正确
    for i := 0; i < 5; i++ {
      ii := i
       go func() {
         fmt.Println(ii)
       }()
     }
    ```
    
    
    
  + 注意for range循环也是依赖len()的，因此在slice添加元素的时候要注意，要考虑len是否变化了。但是`for i`循环如果你用`len`，实际上在编译期就搞定了，后序迭代并不会依赖它
  
+ go 数组/切片
  
  1. 初始化问题
   + 如果用var初始化数组/map，有这几种方式：
    ```
    var arr0 [5]int = [5]int{1, 2, 3}
    var arr1 = [5]int{1, 2, 3, 4, 5} // 这个最常用
    var arr2 [2][3]int = [...][3]int{{1, 2, 3}, {7, 8, 9}} // 注意第二个维度不能用...
    var str = [5]string{3: "hello world", 4: "tom"}
    ```
    一个常犯的错误：`var arr0 [5]int{1, 2, 3}`或`var m map[int]int{1: 100, 2: 200}`，**这两种是错误的！！！！**
   + 注意如果使用make去初始化一个切片，必须要给len值，用make初始化map的时候不需要
   + 如果想初始化一个切片（保证每个位置都是可索引的，相当于每个位置上都有初始值），那么可以用这种方式：
   ```
   a := make([]int, 10) 
   或
   a := make([]int, 10, cap)
   注意第二个参数有值才行，如果len=0，cap有值，那么依然不行
   a := make([]int, 0, 10) // 这样不行！！！！！！！！
   a := []int{} // 这样也不行，这样相当于make([]int, 0, 0) ！！！！！！！
   ```
   注意这种初始化相当于已经往数组里面塞了len个元素，每个元素是default value
   + 如果想初始化一个矩阵（保证每个位置都是可索引的，相当于每个位置上有初始值）那么有两种方式，
      一种方式是用一个数组存储，缺点在于这个数组的大小一开始就定死了：
      
      ```
      a := [const][const]int{} // 一定要注意这个const是个常量，不能是变量
      ```
      另一种方式是用切片存储，这里的x是变量，但是这里必须使用如下方式进行初始化
      ```
      a := make([][]int, x1) // 这里的x1x2是变量
      for i := range a { // 注意如果只用一个变量去承接循环量，则这个变量代表的是索引
         a[i] = make([]int, x2)
      }
      ```
       注意二维切片这样是错误的[][]int{}{}，一般[][]int{}或者[][]int{{}}即可
  2. 遍历问题
   ```
   a := make([]int, x1) // 这里的x1x2是变量
   for i := range a { // 注意如果只用一个变量去承接循环量，则这个变量代表的是索引
      ...
   }
   ```
  3. 添加/删除元素
   + append
     + append有一个点一定要注意就是：如果已经`a := make([]int, 10)`了，那么后面再使用append加入元素就是第11个元素了，前面的都是0（default value）
     + 注意append类似于c++里面的emplace_back，而不是push_back，它是地址传递不是值传递，有时候我们需要值传递的时候（比如leetcode上面N皇后），我们就要注意了。 
  4. 切片作为函数参数
   **传切片还是传切片指针？**
      这个问题一定要注意，当你要改变切片的长度，或者地址的时候一定要传指针，因为切片事实上类似于这种结构体：
   ```
   type sliceHeader struct {
    Length        int
    Capacity      int
    ZerothElement *byte
   }
   ```
   确实，当切片做赋值操作的时候是引用传值，相当于只把这三个field赋值给接收者。因此当函数形参是传切片的时候，会复制一份这个结构体用于函数体内部的操作，但是函数外面的这份结构体是不会因函数里面的操作而改变的，这就导致如果函数里面改变了Len或者地址，会导致结构体中的Length和ZeroElement改变，这种改变对外部不可见，造成bug
  5. 切片指针问题
   + 一定要注意，**切片指针不能索引，不能切片，只有切片类型可以**，简而言之，所有针对slice类型的操作都不能用在slice指针上面
   + 切片是可以被new的，new完以后返回的是一个切片指针，但一般不这么用除了在一些恶心的golang库里面，比如heap


+ go 字典map
  1. 初始化问题
   + 给定map的类型，其实就已经相当于setdefault了，即你添加一个key，这个key对应的value就是这个map的value类型0值，例如：对于一个`map[string]int`类型的数组，默认value就是0，即用任何string索引出来的都是0，不管这个string是不是key，它对应的value你打印出来就是0
   **有趣的一件事情是**：初始化map时，你用`a := map[string]int{}`和`a := make(map[string]int)`都可以起到setdefault的效果，即你这样初始化以后，可以直接通过key添加键值对。但是对于slice类型的时候，就不行了
      注意：`a := make(map[string]int, cap)`初始化map时如果用make，第二个参数就是cap，不需要传len这个参数。但不传第二个参数也是可以的，不传默认第二个参数为0
   + 要注意map的0值是nil，map类型的nil，和slice不一样，map为0值的时候如果用`map[...] = ...`赋值的话，会报错，但是slice可以在nil的时候用`append`加入值，这个也可以看出slice 的0值是nil切片
  2. map的key
   所有可比较的类型都可以做map的key，只有三种类型不可以：map，slice和function。注意array是可以的。注意如果是struct，包含前面那三种类型的也不可以。
  3. map的value
  
       + go 中的 map 的 value 本身是不可寻址的，因为 map 的扩容的时候，可能要做 key/val pair迁移。<https://blog.csdn.net/qq_36431213/article/details/82805043>

       + 基于上面这一点，当map的value是结构体类型时，不能通过`map[key].field=...`来赋值，如果想这样赋值的话，那么value应该存储结构体指针类型。因为x=y这种赋值方式，前提是x是可寻址的
  
       + 还有如果存的是结构体类型的话也不能调用它的指针类型的方法。
  
  4. map 的遍历问题
  
     map的遍历一般是用range遍历的，range遍历有很多约束，**不要在遍历的时候对map中除了当前迭代key以外的key进行修改**，但是可以修改当前key。最重要的就是遍历过程中不能边遍历边增加key，不然结果是不可预知的！
  
+ go 寻址与不可寻址

  **golang中不能寻址的可以总结为：不可变的，临时结果和不安全的。只要符合其中任何一个条件，它就是不可以寻址的。**

+ go range 遍历

  因为这个实在


+ go 运算符
  1. Golang的自增自减只能当做一个独立语言使用时，**不能这样**使用 `b := a++ 或者 b := a--`，同时自增自减运算符只能出现在右边，不能出现在左边，即只能`a++`不能`++a`
  2. 自增操作只能单独写一行
  3. 运算符优先级问题：
   + golang的索引运算符[]优先级最高，高于取地址*运算符

+ go 随机数
  rand.Intn(n)是从[0, n)随机选取一个数字

+ go nil空指针
  1. go的nil空指针不能赋给一个无类型的变量，即不能`a := nil`，如果一定要用nil指针初始化，就应该是`var a 类型 = nil`
  2. nil是interfaces, functions, pointers, maps, slices 和 channels的类型零值，也就是说这些类型如果要用nil初始化，直接`var a 类型`即可
  
+ Runtime
  
  + runtime.Gosched()
  
    这个函数是用于让出CPU时间片。这就像跑接力赛，A跑了一会碰到代码runtime.Gosched()就把接力棒交给B了，A歇着了，B继续跑。注意：这个函数并不是说将当前线程挂起了！而是让出CPU给下一个g，后面还会再运行这个g的


+ go 函数
  1. 可变参数
      形如func(word ...string)这样的形参的就是可变参数，如果是一个数组，比如说是words = []string，就使用func(words...)解开数组传进去。 
  2. 不能把函数参数当成**命名返回值（named returned）**用，因为命名返回值相当于是已经声明的一个变量，如果函数参数当成命名返回值，**那么一个函数中就会出现两个相同名字的变量**，这个是巨大的错误
  
+ go 闭包
  闭包就是在一个函数里面实现（定义）一个函数，这个函数就叫做闭包。闭包的含义就是一个函数可以读取另一个函数的资源，比如
  
  ```go
  func Fib() func() int {
  	a, b := 0, 1
  	return func() int { // 这个匿名函数也叫闭包
  		return a+b
  	}
  }
  f := Fib() // f也叫闭包
  ```
  
  
  
  1. golang里面闭包有一个特别常用的用法，就是用于延迟调用。场景：当在A函数里面定义了一个B函数以后，这个新定义的B函数可以使用A函数的实参和其中的变量，非常方便，然后再把B函数作为引用返回出去，外面用一个变量接收，然后想调用的时候再调用
  
+ go 组合与继承
  1. go的继承是通过组合实现的，组合就是一个结构体镶嵌到另一个结构体里面。继承一般是通过把一个匿名结构体镶嵌到另一个结构体里面，这里一定要注意**如果不是匿名镶嵌，它就仅是组合**，你是无法通过子类对象去访问父类方法的。
  看一个有趣的现象：
  ```
  type Context interface {
    Deadline() (deadline time.Time, ok bool)
    Done() <-chan struct{}
    Err() error
    Value(key interface{}) interface{}
   }
  
  type valueCtx struct {
    Context
    key, val interface{}
   }
   // valueCtx 没有实现一个Context方法
  ```
  + 注意var a Context = valueCtx{}是没问题的，因为注意！！！！！valueCtx组合了一个匿名的Context类型结构体，**所以valueCtx即使什么方法都没有实现，但是它依然算是实现了Context的方法**。这个例子并没有说明父类引用可以子类对象！！！！
  + 还有一个注意的点，那个context是一个接口，但是写在valueCtx里面是作为一个Context类型的成员，这个地方只有一个Context类型的变量可以填进去。

+ go type 关键字
  可以给某个类型用type起多个名字


+ go 常量
  go的常量是用const修饰的，程序运行期间都不会被改变，声明方式就是: `const a int = 3.14` 注意**定义的时候必须同时赋值，可以没有类型**，也可以有。

+ go break
  break 有一个很有意思的地方，就是它会像c一样有带标签的break，比如：



## Go并发
+ 协程
  1. 协程调用的返回值会被抛弃，如果想把协程的返回值捕获到，必须使用`sync.errgroup`
  
+ defer延迟调用
  1. defer的函数一般在返回值前按先入先出的方式执行，和协程调用一样返回值会被抛弃
  1. defer函数在所在的函数返回、函数结束**或者对应的goroutine发生panic的时候**defer就会执行，这就解释了为啥lock以后要立马defer unlock，这是因为防止中间发生panic，这个锁放不开造成死锁
  
+ panic和recover
  1. panic的恢复一般是使用defer函数完成，在defer的函数里面调用recover()捕获**恐慌的内容**
  
  1. 不管有没有出现panic，不管这个panic是在运行函数里面，还是在defer栈的函数里面，defer栈里的函数都会被正常的执行完
  
  2. 如果在运行函数中一个panic后面还有一个panic，那么第二个panic是unreachable的（因为正常函数运行到panic就结束了，但是defer栈里的函数是不会因为任何一个panic而中断的）
  
  3. 注意如果前面好几个panic最后有一个recover，整个函数不会panic（说明最后这个recover捕获了所有panic），且**打印出来的错误是最后一个panic**，但是注意**并不是后面的panic覆盖了前面的panic，而因为后面的panic包裹了前面的panic**。但是如果在一个panic后面没有recover，则肯定会崩溃
  
     <https://stackoverflow.com/questions/41139447/is-it-okay-to-panic-inside-defer-function-especially-when-its-already-panickin>
  
  2. 注意如果一个程序里面有一个goroutinue发生错误panic了，然后这个panic没有在这个goroutine里被recover，整个程序就崩溃了。**但是！！！如果一个函数panic了，这个函数内部并没有捕获是可以的，这个函数的调用方甚至是调用调用方都可以捕获。只要他们在同一个goroutine内！！！**
  
+ channel
  1. 这篇文章挺牛逼：<https://juejin.cn/post/6844904016254599176>
  2. 使用channel有一种情况要注意：
  ```
   for {
      i, ok := <-ch1 // 通道关闭后再取值ok=false
      if !ok {
            break
      }
   }
  ```
  + 注意如果那个位置不加那个ok，**即使通道关闭了，那个位置也不会死锁，而是会一直读出0值**，（但往一个关闭的通道里面发送值是会panic的）
  + 关闭channel的几种最佳方式：
    1. 发送协程主动关闭通道，接收协程不关闭通道。技巧：把接收方的通道入参声明为只读(`<-chan`)，**如果接收协程关闭只读协程，编译时就会报错。**
    2. 协程处理1个通道，并且是读时，协程优先使用`for-range`，因为`range`可以关闭通道的关闭自动退出协程。
    3. `,ok`可以处理多个读通道关闭，需要关闭当前使用`for-select`的协程。
    4. 显式关闭通道`stopCh`可以处理主动通知协程退出的场景。
  + 去读取ch1中的内容时，如果还没读完通道就关闭了，这种情况是可以的，这个代码会把剩下的内容全部读完再退出。
  + `var a chan int`只是声明了一个nil通道，没有分配空间，你往一个nil里面写值读值都是死锁的（往close里面写值才是panic）
  
+ context
  这篇文章说的最好最全面：<https://juejin.cn/post/6844904070667321357>
  context 对比 channel在并发操作中的优势：在并发程序中，由于超时、取消操作或者一些异常情况，往往需要进行抢占操作或者中断后续操作。熟悉channel的朋友应该都见过使用done channel来处理此类问题。
  但是done channel存在一个问题：假如有个主协程起了多个子协程A，B，C...，每个子协程又起了多个子子协程a,b,c,d....会有个问题就是子子协程需要监听两个done channel或者在子协程中done channel的处理中加入给子协程done channel发送信号的代码，总之channel会变的越来越多而且逻辑也会越复杂。context的引入可以使当主协程发出终端操作，会一把把子协程，子子协程，子子子协程全部中断掉，无需增加done channel的个数
  
+ select
  1. select在for循环内
   + 如果select
  
+ Timer和Ticker
  
  timer的reset的问题：<https://tonybai.com/2016/12/21/how-to-use-timer-reset-in-golang-correctly/>

+ 广播场景
有时候我们需要让当前协程**一次性**通知多个协程，能够实现这一点的有两种方法：
1. 关闭channel实现广播（缺点：一次性）
2. 使用sync包里面的sync.Cond，条件变量Conditions
3. 让当前协程往通道里面写多个值 / 使用多个通道 / 让一个通知一个串起来：这都比较怪异


## Go 编程trick
+ 指向slice的指针，指向map的指针
+ 循环中r := r

## Go 文件操作
<https://www.devdungeon.com/content/working-files-go>

## Go标准库
### container类
+ heap
  堆的建立比较恶心，需要自己实现以下接口，下面是一般实现方式，以小根堆为例：
  ```
  // An IntHeap is a min-heap of ints.
   type IntHeap []int
  
   func (h IntHeap) Len() int           { return len(h) }
   func (h IntHeap) Less(i, j int) bool { return h[i] < h[j] } // 小于号是小根堆，大于号是大根堆
   func (h IntHeap) Swap(i, j int)      { h[i], h[j] = h[j], h[i] }
  
   func (h *IntHeap) Push(x interface{}) { // 这个也是一个很脑残的东西，只是为了实现”add x as element“，以满足标准库的变态要求。
      // Push and Pop use pointer receivers because they modify the slice's length,
      // not just its contents.
      *h = append(*h, x.(int))
   }
  
   func (h *IntHeap) Pop() interface{} { // 这个函数实现就是一个很脑残的东西，只是为了实现“remove and return element Len() - 1.”，以满足标准库的变态要求。
      old := *h
      n := len(old)
      x := old[n-1]
      *h = old[0 : n-1]
      return x
   }
  ```
  使用的时候是这样的：
  ```
  	h := &IntHeap{100,16,4,8,70,2,36,22,5,12}
  
	fmt.Println("\nHeap:")
	heap.Init(h) // 这一行可有可无
  
	fmt.Printf("最小值: %d\n", (*h)[0])
  
	// for(Pop)依次输出最小值,则相当于执行了HeapSort
	fmt.Println("\nHeap sort:")
	for h.Len() > 0 {
		fmt.Printf("%d ", heap.Pop(h).(int))
	}
  
	// 增加一个新值,然后输出看看
	fmt.Println("\nPush(h, 3),然后输出堆看看:")
	heap.Push(h, 3)
	for h.Len() > 0 {
		fmt.Printf("%d ", heap.Pop(h)) // 注意这里可以加.(int)也可以不加，因为%d会默认转化
	}
  
	fmt.Println("\n使用sort.Sort排序:")
  h2 := IntHeap{100,16,4,8,70,2,36,22,5,12}
  sort.Sort(h2)
  for _,v := range h2 {
    fmt.Printf("%d ",v)
	}
  ```
  三点要注意，
  1. 一个是`heap.Pop(h Interface) interface{}`这个方法和上面那个`func (h *IntHeap) Pop() interface{}`屁联系都没有，这个是heap的内部库的一个方法。
  2. 注意注意注意！！！！那个**h一定要是一个地址类型**，即必须要有取地址，或是`&`或是`new()`
  3. 第二个是如果你要返回最小，你可以使用`heap.Pop`的方式，或者使用`(*h)[0]`的方式，两者区别不言而喻，一个就是单纯的索引，另一个会改变数组本身。但要注意不能通过`(*h)[1]`去寻找第二小的元素！！！！，因为不知道是左右哪一个，只有pop完了0位置的再索引或者再pop才是第二小的元素
  4. 注意那个自己实现的Pop和Push，那个接收者是一个指针类型，为啥呢，是因为切片你可以理解为是一个结构体，结构体里面有三个东西 1.指向一个数组的指针 2.长度 3.容量 当你Push一个数字进去的时候，如果使用的是值类型的接收者，会先把这个结构体复制一份a，然后添加的时候**会改变a中的长度但是不会改变源结构体中的长度**，这就导致再去调用Len()函数时返回的不是添加后的长度。
  5. 第四点中讲了为啥那个接收者是指针，那为啥Swap()不需要指针接收者，因为即使发生复制，指针所指向的数组地址并没有变化，因此不需要传指针接收者

```
func main() {
    var n, m int
    fmt.Scan(&n)
    fmt.Scan(&m)
    graph := make([][]byte, n)
    visited := make([][]bool, n)
    startX, startY := -1, -1
    scanner := bufio.NewScanner(os.Stdin)
    for i := 0; i < n; i++ {
        scanner.Scan()
        temp := scanner.Text()
        graph[i] = make([]byte, m)
        visited[i] = make([]bool, m)
        for j := 0; j < m; j++ {
            graph[i][j] = temp[j]
            if temp[j] == 'S' {
                startX = i
                startY = j
            }
        }
    }
    ans := math.MaxInt32
    var helper func(int, int, int, int) 
    helper = func(i, j, jcount, res int) {
        if visited[i][j] {
            return 
        }
        if graph[i][j] == '#' {
            return 
        }
        if graph[i][j] == 'E' {
            ans = min(jcount, ans)
            return 
        }
        visited[i][j] = true
        if i > 1 {
            helper(i-1, j, jcount+1, res)
        }
        if i < len(graph)-1 {
            helper(i+1, j, jcount+1, res)
        }
        if j > 1 {
            helper(i, j-1, jcount+1, res)
        }
        if j < len(graph[i])-1 {
            helper(i, j+1, jcount+1, res)
        }
        if res > 0 {
            helper(n-1-i, m-1-j, jcount+1, res-1)
        }
        visited[i][j] = false
    }
    helper(startX, startY, 0, 5)
    if ans == math.MaxInt32 {
        fmt.Println(-1)
    }
    fmt.Println(ans)
}

func min(a, b int) int {
    if a < b { return a }
    return b
}

type Point struct {
    X int
    Y int
    Res int
}
```







### math 库

这个库刷leetcode的时候常用，一定要记住其中一部分。它恶心在几乎所有的函数参数和返回值的类型都是float64
+ math.Pow(a, b float64) float64 一定要注意都是float64类型
+ math.Abs(x float64) float64
+ 最大的float64数(32位同理)，math.MaxFloat64， **注意没有float64 负数最小值，你可以用float64(math.MinInt32)**
+ 最小的float64**正数**：math.SmallestNonzeroFloat64
+ math.Ceil(x float64) float64：注意这个ceil是向上取整，但是ceil(9.0) = 9

### strings 库
+ 字母转大写：strings.ToTitle(s string) string
+ 字母转小写：strings.ToLower(s string) string 
+ 判断是否包含：strings.Contains(s, substr string) bool
+ 把s左边的cut字符删除（右边也有一个）：strings.TrimLeft(s string, cut string) string 
+ 字符串分割：strings.Split(s string, sep string) []string
+ 替换选中的字符：strings.Replace(s, old, new string, n int) string，n表示“前几个”，n为-1的时候是全部替换
+ join方法：strings.Join(elems []string, sep string) string

### fmt 库

+ Scan, Scanf 都是以空字符为截止的，包括空格和换行。Scanln是只以换行为截止的

+ `fmt.Scanf("1:%s 2:%d 3:%t", &name, &age, &married)`,这种意思是你在输入的时候必须输入1:，2:这种

+ fmt 有一个可以把10进制转换成别的进制的trick，就是使用占位符：

  ```go
  %b	base 2
  %d	base 10
  %o	base 8
  %O	base 8 with 0o prefix
  %x	base 16, with lower-case letters for a-f
  %X	base 16, with upper-case letters for A-F
  %U	Unicode format: U+1234; same as "U+%04X"
  %q	a single-quoted character literal safely escaped with Go syntax.
  %c	the character represented by the corresponding Unicode code point
  ```

  


### Go template
命令：<https://www.cnblogs.com/f-ck-need-u/p/10035768.html>
语法：<https://www.cnblogs.com/f-ck-need-u/p/10053124.html>
国外：<https://learn.hashicorp.com/tutorials/nomad/go-template-syntax>
  -会一直删到上一个或者下一个不为空的数值， end是在最后的
  if, {{range}}本身不占空格，但range那一行结尾会有个\n，range中，迭代到下一个元素时，之前会再加一个range（占一行，即最后的换行符还在，前面的-不管用了，前面空字符（包括\n）只看end的位置，后面的空字符（包括\nbb）是看后面的-的），但第一行不受end影响。一定注意只有第二轮以后且只有前面受到end影响
  不过原来如果range前面有空格的话，这里会被去掉，一直去到与end对齐，如果end前面有-，那这里的range也会去掉上一行，所以这个，但是range后面的空格不会被去，可以加一个fuck看看，但end不会这样。end有对齐的作用，
+ 内置function
  <https://pkg.go.dev/text/template#hdr-Functions>
  1. 一定要注意and, or都是function，要放在最前面的，而且他们不会短路，所有跟在他们后面的表达式都会被evaluated的，如果想短路，参见：<https://stackoverflow.com/questions/44582435/how-to-have-short-circuit-with-and-or-in-text-template>

### go 序列化
+ yaml/json
  一定注意当调用json/yaml的Unmarshal的时候，结构体的field必须是exported的，千万不能是首字母小写的！！！！，不然啥也读不出来，还他妈逼不报错

## gorm框架
gorm专门用来读取关系型数据库
+ gorm.find(interface{})
  这个其实很牛逼，可以认为它可以用来读取多条数据然后写到一个结构里面，这个interface{}支持结构体和结构体切片，有意思的是如果你只需要数据库里面部分列的数据，只要你传进去的那个单个结构体的field名和gormt工具生成的表结构体的field一致，就可以准确把对应field对应的column的数据读入到对应field里面。且不需要在sql语句里面指定只读哪几个column

## go mapstructure包
1. 
    <https://pkg.go.dev/github.com/mitchellh/mapstructure#Decoder.Decode>
    用于将一个struct转化成一个map[string]interface{}{}，或者相反。其实这个包可以任意转换两种go类型，但是常用的就是这个转换。

## go 命令行交互
cobra和promptui一般用的比较多：<https://www.youtube.com/watch?v=so3VZwdWcBg>

## tabby框架
为啥要有一个service层
rpc_controller里面为啥是http的调用方式
这是用反射的方式实例化controller吗，如果是的话，在哪反射的
中间件加载哪些东西，所有的长链接是不是都放在统一加载的中间件里面，每个服务都自己定义一些中间件


Error都报警
WithContext.Infof这个函数中的key是客户端统一传过来的？
层与层之间写接口的好处是啥？

启动脚本里面是不是要明确写出conf的名字


有几个问题:一个是闭包的问题
另一个是函数签名的问题

## Gin 框架
1. c.Next() c.Abort() c.Set() c.Get() 这几个常用在中间件中，各自作用：<https://blog.csdn.net/qq_37767455/article/details/104712028>
   注意：c.Abort()这个函数使用了以后本函数的内容仍然会正常走完，包括如果在本函数中调用了别的函数，也会走完。一般用在中间件中，用于阻止下一个ginserver.HandlerFunc

2. 报这种错误很有可能是在解析请求参数时（类似于ShouldBindJson那种）出错，有可能是结构体的tag出错
   ```
    2021/06/28 15:37:55 http: panic serving [::1]:54136: interface conversion: string is not error: missing method Error
    goroutine 76 [running]:
    net/http.(*conn).serve.func1(0xc0000b20a0)
          /usr/local/go/src/net/http/server.go:1824 +0x153
    panic(0x4bd0be0, 0xc0000c0c60)
          /usr/local/go/src/runtime/panic.go:971 +0x499
    git.bbobo.com/framework/tabby/pkg/core/server/ginserver.recoverMiddleware.func1.1(0xc00057f750, 0xc02e7cf4e90c7be0, 0xdd8a7669, 0x55738e0, 0x1f4, 0xc00057f73e, 0xc0000e80f0)
          /Users/yixia/Desktop/framework/tabby/pkg/core/server/ginserver/middleware.go:60 +0x230
    panic(0x4b68e80, 0xc0000b6d30)
   ```
3. 请求包结构体定义的tag一定要注意，要和请求参数的参数名保持一致，很多导致结果为0或出错的bug都是来源于这里
4. gin在解析请求body的时候用的tag是binding，这个tag里面可以加入对这个字段的长度的限制。可以减少一步参数校验

```
    // 这个就是错误的
    var helper func(int,int)(int)
    memo := make([][]int, n+1)
    for i := 0; i <= n; i++ {
        memo[i] = make([]int, m+1)
        for j := 0; j <= m; j++ {
            memo[i][j] = -1
        }
    }
    helper = func(num, depth int) int {
		    if num == 0 {
            return 1
        }
        if depth == 0 {
            return 0
        }

        if memo[num][depth] != -1 {
            return memo[num][depth]
        }
        ans := 0
        for i := 1; i <= num; i++ {
            left := helper(i-1, depth-1) % (1e9+7)
            right := helper(num-i, depth-1) % (1e9+7)
            ans += (left * right) % (1e9+7)
        }
        // fmt.Printf("num:%v, depth:%v, ans:%v\n",num,depth,ans)
        memo[num][depth] = ans
        return ans
    }
    fmt.Println(helper(n, m))
    
    
        dp := make([][]int, n+1)
    for i := 0; i <= n; i++ {
        dp[i] = make([]int, m+1)
    }
    for j := 0; j <= m; j++ {
        dp[0][j] = 1
    }
    for i := 1; i <= n; i++ {
        for j := 1; j <= m; j++ {
            for k := 1; k <= i; k++ {
                dp[i][j] = (dp[i][j] + dp[k-1][j-1] * dp[i-k][j-1] % (1e9+7)) % (1e9+7);
            }
        }
    }
    fmt.Println(dp[n][m])
```



