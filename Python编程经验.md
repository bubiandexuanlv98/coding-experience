# Python 语法及第三方库奇技淫巧
## 代码编辑
+ jupyter notebook
  1. jupyter（**还有命令行也是**）里面如果你把builtin的name，不小心赋值了，后面你再使用这个name，就没有内置的效果了：<https://stackoverflow.com/questions/31087111/typeerror-list-object-is-not-callable-in-python>，解决方案：执行`del name`，比如你错误赋值了`list`，可以执行一下`del list`
## Python 库安装
+ pip install 参数：<https://blog.csdn.net/tsq292978891/article/details/111460944?utm_medium=distribute.pc_aggpage_search_result.none-task-blog-2~aggregatepage~first_rank_ecpm_v1~rank_v31_ecpm-1-111460944-null-null.pc_agg_new_rank&utm_term=install+pip+%E7%9A%84%E5%8F%82%E6%95%B0&spm=1000.2123.3001.4430> 
## Python 语法本身
协程  mongopipliner里面读  没意义
to_thread 怎么保证他能在适当的时候切换呢？

### 多进程
<https://www.cnblogs.com/kaituorensheng/p/4445418.html>
Queue的使用：<https://www.jb51.net/article/170581.htm>

### 自带类型
+ None 
  这个到底是不是有类型的。如果一个本来是dict类型，没有赋值，是空值，但他不是None，但可以当None使用？  
+ `str`类：  
  1. `str.split()`  
   这个函数一定要注意，在默认情况下（不传入任何参数），它检测到任何空格（空格，双空格，换行，制表）都会split，而且会自动将“空”的分裂元素扔掉。而如果你在split函数参数中传入`' '`那么对于`str.split()`对于双空格会剩余一个“空”不会去掉。同理对于双换行（传入`'\n'`），双制表（传入`'\t'`）也是一样
  2. str类对其一些类型的判断：  
   <https://www.programiz.com/python-programming/methods/string/isalpha> 字母，数字等都可以判断
+ `set`类
  1. 注意set不能对对象进行去重，因为当你向set里面添加对象的时候，他一定是不同的元素，因为你加的是对象名，而对象名是地址
### 自带模块和函数
+ `open`方法 
  1. 所有open返回的句柄都可以直接迭代取内容（注意这里迭代的是行），不需要一定read或者readline，以二进制形式打开的也是如此  
  2. readline,readlines的比较  
   <https://blog.csdn.net/chengxuyuanyonghu/article/details/45022309>
  3. write,writelines的比较
   其实就是write只能写字符串，writelines可以写字符串列表
   <https://www.cnblogs.com/rychh/articles/9839757.html>
   注意这两种方法都不能换行，如果要换行一定要手动加上一个`\n`，另外还要注意这两种方法在写入内容的时候不会立刻把数据写入磁盘，而是会先存在缓存中，文件close的时候才会写到文件中。因此如果需要立马写入，要加上`文件句柄.flush()`

+ python正则表达式  
  使用`re.sub`或者`pattern.sub`时有一个东西查不到：`\g<1>`。这个是指在pattern字符串中的匹配到的第一组中的字符
+ `eval()`函数  
  这个函数很鸡贼，他只不过是把括号内的字符串变成python语言罢了，看似无比傻逼的操作。但是它却在读取文本后对文本内容类型的判断有不可替代的作用，除此之外还能把读进来的str转换成list，从而可以很方面的构造字典
+ `sys.exit()`和`os.exit()`  
  这两个的区别可以见<https://blog.csdn.net/jingbaomm/article/details/83716504>  
  `sys.exit()`的用法见<https://www.cnblogs.com/weiman3389/p/6047062.html>  
+ `sys.stdout.write()`和`print()`和`sys.stdout.flush()`的区别于联系
  <https://blog.csdn.net/Just_youHG/article/details/102591313>  
+ `sys.stdout`和`sys.stderr`区别（这个不准确）  
  <https://blog.csdn.net/c_phoenix/article/details/52858151>


+ `re`模块  
  re.search, re.match和re.findall有很大区别，re.findall返回的是一个数组，匹配结果直接呈现在数组里，但是前两个必须要用`.group(num=0)`去获得具体的字符串，注意如果分组了（eg.()...()...()）那么`.group(1)`,`.group(2)`,`.group(3)`才有意义，否则使用`.group()`就行（这里默认传入`num=0`），因为`.group()`返回的是整个字符串。`.groups()`返回的就是`(.group(1),.group(2),.group(3))`(没有`.group(num=0)`，因为`.group(num=0)`是整个匹配到的整个字符串)

  + 注意事项：
  这个模块的正则取自于Perl正则，但是和Perl正则又不是完全一样，所以要对着语法看。要记住除了basic正则，其他所有正则都赋予了非字母数字字符特殊的含义（除了'_'），因此需要匹配特殊字符时，都要在前面加上转义字符'\'，虽然有时候可能会有漏网之鱼：比如'<>'在python正则里面没啥特殊含义。

+ 函数参数中`*args`和`**kargs`：
  <https://zhidao.baidu.com/question/367559039025445444.html>
  只要参数前面加星号，则代表这个位置上可以接受任意多参数
  1. 任意数量位置参数（*args）**不能**放在普通参数的前面。
  2. 任意数量位置参数（*args）**可以**放在默认值参数的前面。
  3. 任意数量的关键字参数（\**kwargs）**不能**放在普通参数的前面
  4. 任意数量的关键字参数（\**kwargs）**不能**放在默认值参数的前面
  5. Optional啥意思

+ `glob`模块  
  `glob.glob(pathname, recursive)`这个其实只要注意一个问题就是如何列举本文件夹下所有文件（包括子文件夹，孙子文件夹，曾孙子文件夹...的文件）,  
  eg.
  ```   
  glob.glob(**/*.txt, recursive=True)
  ```
  这个模块pathname这个参数的写法，其实和shell脚本中对path的写法是一样的，可以参考shell里面怎么用（尤其是）。其实glob中的匹配和shell里面一样，只不过shell里面（绝大多数shell）在使用`**/*`的时候默认了`recursive=True`  

+ 交并补集  
  list之间只能用`+`运算符，其他`|`,`-`,`&`都不行，set可以。dict.keys可以`+`,`|`,`-`,`&`，但dict.values都不行，`{**dict1,**dict2}`如果dict2和dict1有相同的key，后者会覆盖前者。  

+ 注意，python有个很恶心的地方，就是0 or None 返回的是None，但是1 or None返回的就是1了

### 循环
+ 永远不要在for循环迭代一个列表的时候，更改这个列表
<https://stackoverflow.com/questions/6260089/strange-result-when-removing-item-from-a-list-while-iterating-over-it>

### python并发
+ multiprocessing模块 多进程
  + process开的总数和: <https://stackoverflow.com/questions/20039659/python-multiprocessings-pool-process-limit>。区分IO密集型和cpu密集型
  + Process类
    1. Process 的启动涉及到一个很重要的知识点：当前系统是通过spawn还是fork来启动子进程的，即当执行`process.start()`时，底层调用的是fork还是spawn
      spawn和fork的区别：<http://www.bnikolic.co.uk/blog/python/parallelism/2019/11/13/python-forkserver-preload.html>
                       <https://stackoverflow.com/questions/64095876/multiprocessing-fork-vs-spawn>
      python里面一般fork是在linux系统上，spawn是在macos和windows：<https://docs.python.org/3/library/multiprocessing.html#contexts-and-start-methods>
    2. 对于spawn，如果你的同步结构（Queue, Event，Lock）等没有作为参数传到执行函数里面，而是在全局，那么spawn每启一个进程就会复制一个这样的同步结构（即各自都保留一份，不共享），这样一定会死锁。**但是fork这样操作就没关系（应该没问题）**
  + Pool类
    <https://pythonspeed.com/articles/python-multiprocessing/> 有空看看
    1. 这个特别麻烦，尤其涉及到共享锁的时候: <https://stackoverflow.com/questions/25557686/python-sharing-a-lock-between-processes> 看评论，总体意思是pool在做apply之类的操作时是先启的进程再pass变量
    2. 无论底层是fork还是spawn，**Pool要注意的是他并不是由当前进程创建的子进程**，所以当前进程里面的Queue，Event这种同步结构等都是**无法被共享的**（别的结构就更别想了，别的本来就不是process-safe的），**传进去也不行**这个在fork和spawn下都一样（fork里面共享的是有父子关系的两个进程的内存空间）。但是不行的原因不一样，**spawn在全局时不行是因为会把共享结构都复制一遍，传进去不行是因为不是父子进程不能共享同步结构。fork两个不行都是因为不是父子进程（fork全局行不行有待商榷）。**
    3. 当底层是fork的时候，Pool不能pickle到当前函数里面的结构（比如闭包），但是Process可以。对于全局结构，Process和Pool都可以pickle到（pickle和能共享是两码事，见2）。当底层是spawn的时候，无论是fork还是spawn都不能pickle到
    4. Pool初始化的时候可以传入`processes`参数，这个参数可以限定最大的并行数，对于`pool.apply_async()`如果加入的函数超过了最大并行数，后面启动的时候是会排队的。
    5. 无论是spawn还是fork，process还是pool，多进程想怎么读就怎么读。（但是对于Pool而言，要能pickle到）
    <https://stackoverflow.com/questions/25557686/python-sharing-a-lock-between-processes> 上面绝大部分都是出自dano的回答
    **所以综上：fork和spawn在用Pool的时候都要用`Manager()`来共享同步结构（其他结构则更是这样了）。对于底层用fork的系统而言，（pool和process）不论传参还是全局，都相当于共享。但是spawn只有传参相当于共享，全局就是复制，且函数的local命名空间不复制，因为它不全局（注意相当于共享不代表能共享）。Process启动的是子进程，Pool不存在父子进程关系。同步结构不能在非父子进程中共享**
  + Manager类
    1. manager的作用是新启一个进程，把要共享的结构放进去，然后别的进程通过IPC的方法去和它管理的结构通信。
    2. 对于绝大部分python的类型，他们是一定程度上线程安全的，但都不是**进程安全的**，因此如果要多进程对他们进行读写是要用manager管理的

+ asyncio模块 多协程
  大致详解：<https://bbc.github.io/cloudfit-public-docs/asyncio/asyncio-part-1.html>
  + 同步原语
    + condition和semaphore的区别：<https://stackoverflow.com/questions/3513045/conditional-variable-vs-semaphore>
    + event 和 condition 的区别：<https://stackoverflow.com/questions/7424590/threading-condition-vs-threading-event> 反正都不准


+ python列表生成式  
  注意：如果想在列表生成式中使用`if else`语句，那么就必须把`if else`语句放在`for`循环前面。  

+ zip打包和zip解包：  
  <https://www.runoob.com/python/python-func-zip.html>  
  注意：*运算符在python中的含义可能是对tuple的解引用，但`zip(*a)`是一种语法，即把原来打包的`[(),(),(),....]`形式转换为`[(),()]` 

+ `__repr__`和`__str__`
  两者区别：<https://blog.csdn.net/nanhuaibeian/article/details/86694581>
  repr面向开发者（也面向用户），str面向用户，但其实对于编程而言并没有什么卵用，因为都要用print，使用print就是面向用户

+ `argparse`包
  这个包就是用来在程序里面编写一个用户友好的接口，它里面提供方法来解析命令行参数，以及负责提供参数help和参数报错

+ `json`包
  json.load是从文件中加载，json.loads是从字符串中加载。


+ python 引入路径的问题   
  1. python 有个问题很恶心，就是他的“搜索路径”和“可见的文件”是两个不同的概念。
    我们把执行python命令时所在的路径称为A，把执行的python件所在的路径称为B。
    python 的搜索路径包含了B（注意：不是执行python命令时所在的文件夹），这就带来一个问题：它无法导入执行A中的模块，必须要使用`sys.path.append()`加入A路径才行。但是A中的文件时对所执行的python文件可见的，这样的话所执行的python文件是可以用文件名打开A中的文件，而不需要加上A的路径前缀  
  2. 很多时候在一个Python package内部直接运行一个文件会报错，这个错误是`Attempted relative import in non-package`，原因可以查看下面这个博客
    <https://blog.csdn.net/qiusuoxiaozi/article/details/79061885>

+ 排序问题
  1. sorted结束以后并不会对原有数据结构改变，若想改变原有结构要加一个赋值操作
  2. list.sort()以后会对原有数据结构改变

+ 字符串格式化输出
  1. f字符串，f字符串实际上是format的简写版
  ```
  num = 1
  f"clips num is {tt = }" # 打印结果：clips num is tt=1
  f"clips num is {tt}" # 打印结果：clips num is 1
  ```


### 类相关
+ `getattr()`  
  这个自带函数是用来获取对象的属性的，eg:getttr(对象名，对象的属性名)
+ python是动态语言，它可以动态的实现对象属性和类属性的设置 <https://www.cnblogs.com/semon-code/p/8257826.html>

+ `__del__`函数
  与`__init__`相对，这是在对象析构的时候调用的，注意这里的析构是指回收的时候，在对象没有被回收的时候，即使显示调用`del xxx`，也无法调用这个函数：<http://c.biancheng.net/view/2371.html>




## logging模块
+ 单模块logger
  我们常见的单文件logger一般都是这么写的：
  ```
  # 创建一个logger日志对象
  logger = logging.getLogger()
  logger.setLevel(logging.INFO)  #设置默认的日志级别
  # 创建日志格式对象
  formatter = logging.Formatter('%(asctime)s-%(name)s-%(levelname)s-%(message)s')
  # 创建一个控制台输出的日志handler
  handler = logging.StreamHandler()
  handler.setFormatter(formatter)
  logger.addHandler(handler)
  ```
  1. 一个很有趣的地方在于，logging.info/logging.error/....这些函数都是默认取根logger的配置，当我们用logging.getLogger()这个方法返回的，就是根logger，但凡向logging.getLogger()这个方法里面传入任何名字，它就不再返回根logger还是返回这个特定名字的logger。因此上面这段代码很有趣，这段代码设置的是根logger，因此这段代码写了以后，后面再用logging.info/logging.error/....时，依然使用的是上面这段代码中设置的配置

### 注意事项
+ logging模块的输出占位符和print的输出占位符的形式是一样的，有一点要注意就是`%s`这个事实上是可以输出任何东西的，虽然他是字符串占位符，但它可以用于输出数字（通过把数字转换成字符串然后输出）

## python 编码问题
+ unicode是字符集，utf-8是编码规则，**unicode是一个字符对一个16进制的数**（注意这个数不是最后写入文件到的字节），**这个对应关系称为码点，这个16进制数称为码点值**。utf-8实际上是基于那个码点值对字符进行编码，具体的方式是：<https://blog.csdn.net/qq_27586341/article/details/120638514> 。注意，如果把ascii看成编码方案的话，它是无法编码unicode的

+ **ascii 实际上既是字符集，也是编码规则**，混乱核心原因就是在诞生之初没考虑字符集和编码方案要分开，所以ascii里面的码点对应的码点值，直接就是编码结果，这就妈的一张表把字符集和编码规则全部包含了。

+ str（python2的str，python3的bytes，python3的str已经是unicode了，python2中的unicode对应python3的str）转换成unicode是decode的过程，unicode转换成str是encode的过程。str实际上是二进制，unicode是字符集。python有两种格式的字符串，str和unicode。unicode经过encode后变成str。由于unicode是字符集，所以我们把unicode转成str的时候才是encode的过程——“把字符集编码成二进制”。所以当我们读取一个文本文件的时候，这个文件在系统中是基于unicode字符集通过某种编码规则（eg.unicode）把文本内容编码（encode）成二进制文件。当我们读取的时候我们传入的参数encoding是指用什么编码规则去将二进制文件解析出来，对文件内容进行编码的形式方式存储的。

+ 注意很有意思的一点是现代我们所有的系统都不会直接显示二进制，而是会通过**编码规则（utf-8，ascii）把二进制编码后展示给你的**。python的print也不例外

+ python2里面的str类型是一个一个字节（二进制数据）。python3里面有专门的bytes类型处理这种一个一个字节（二进制数据），而python3里面的str类型是unicode字符组成。
+ python3当你尝试去`print(b"...")`或者`print(bytes())`的时候会一个一个字节的使用ascii编码规则编码后展示，所以你`b`后面出现非ascii字符就废了，但是你可以通过`print("...".encode('utf-8'))`来解决。相当于py3默认对`bytes`类型是一个一个字节处理，编码规则默认是ascii，但是现在强制它用utf-8编码
+ python2的str类型和python3的bytes类型的处境是一样的，他是一个一个字节的，这种默认都是使用ascii编码，在读取文件的时候可能需要强制要求utf-8编码。但python3的str就不一样了，它本身就是unicode类型，这时候他的编码是python3解释器默认的utf-8编码（这个需要确认<https://stackoverflow.com/questions/2596714/why-does-python-print-unicode-characters-when-the-default-encoding-is-ascii>）

+ python3中的`len()`是unicode码点长度，但`len(二进制数据)`是bytes长度。python2里面`len()`是字节长度。

+ print函数自带解码（decode）的功能
+ 注意在python里面，字符串前面加上r意味着这个字符串是raw的，这个raw的含义仅仅是说这个字符串中的'/'字符不是转义字符


+ python交互模式下如何多行输入：<[python交互模式如何输入换行/输入多行命令](https://blog.csdn.net/qiudechao1/article/details/88757273)>
+ python 参数传递  
  关键字传递可以和位置传递混用，但位置参数要出现在关键字参数之前。eg.
  ```
  s3 = sub(9, b=3) 
  ```

+ %s占位符的诡异情况
```
a = [(1,2,3)]
b = [(4,5,6)]
c = a+b
print("%s" % c)  # 成功
print("%s" % a+b) # 不成功，list和str不兼容
print("%s" % (a+b)) # 成功
```
这种情况在pyspark里面需要非常注意

+ `sys.argv`这个数组中包含的**全是字符串**，如果有数字需要转换

字符串前面加上r什么意思
编码过程是什么
发http报文时默认设置头？
python这些网络接口函数都没有init，但是参数却传的很开心

## sqlalchemy
<https://zhuanlan.zhihu.com/p/466056973>
+ session
  session是一个事物吗，它只连接到一行数据上面？


## flask 
+ flask.Blueprint的name有啥用

## Numpy
### 使用技巧
+ 获取数组维度  
  `数组名.shape`获取维度，使用`数组名.shape[0],[1],[2]`获取行，列......的维度值

+ 按行随机抽取  
  详见：  
    <http://blog.sina.com.cn/s/blog_742859fb0102y3q7.html>

+ 随机生成数据  
  `numpy.random.randint`用于生成各种维度的随机数组，详见：  
  <https://numpy.org/doc/stable/reference/random/generated/numpy.random.randint.html>   

+ 一维数组中随机抽取数据  
  `np.random.choice()`详见<https://docs.scipy.org/doc//numpy-1.10.4/reference/generated/numpy.random.choice.html>

+ 一个numpy类型转换成标准python类型  
  对于多维数组，使用`.tolist`转换，对于单个元素可以使用`.item()`转换成`float`或者`int`

+ np.save和np.load  
  注意：当使用`np.save`的时候会自动把你传进去的类型外面加一个`np.array`，然后存到文件里面去，这里就要注意如果传的是dict，那么`np.load`的时候要使用`.item()`，但是如果传的是list，那么`np.load`的时候不能使用`.item()`，因为导进来的时候已经`array`类型了，这时如果想转list，要用`.tolist`方法，如果直接使用`.item()`则会报：
  ```
  ValueError: can only convert an array of size 1 to a Python scalar
  ```  


### 注意事项
1. 一个二维数组，如果你用list()去转换它，只能转换最外面一层，第二维的类型仍然是numpy.ndarray


## Pandas  
### 使用技巧
+ 获取dataframe，series的value  
  可以使用`dataframe名.values`或`series名.values`获得它们的值，返回值是一个array

+ 将Series中的值（有可能是dataframe中的一列）转换成别的值  
  可以使用`Series名.map()`实现，详见：  
  <https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.Series.map.html>
 
+ dataframe 三种索引  
  分别是`iloc,loc,[]`，注意：[]只能切片，不能直接索引，且只能索引行号，详见<https://pandas.pydata.org/pandas-docs/stable/user_guide/indexing.html>  
  <https://blog.csdn.net/weixin_38664232/article/details/89060331>  

+ 获取dataframe的维度  
  和numpy类似，使用`dataframe名.shape`索引

+ 随机抽取行  
  使用`dataframe名.sample()`  
  详见：<https://blog.csdn.net/zhengxu25689/article/details/87347700>   

+ 随机抽取训练集和测试集  
  详见：<https://blog.csdn.net/HHTNAN/article/details/93796160>  
  当训练集和测试集中的目标值分开的时候应该使用`sklearn.model_selection.train_test_split`详见本文`skleran`库的介绍

+ 读取csv文件  
  使用`pd.read_csv`


## TensorFlow
### 函数介绍
+ Tensorflow 中的损失函数（tf.losses专题）  
  <https://zhuanlan.zhihu.com/p/44216830>
+ `tf.variable_scope, tf.get_variable`
  <https://blog.csdn.net/gaoyueace/article/details/79079068>

+ `tf.nn.sparse_softmax_cross_entropy_with_logits`  
  `tf.nn.softmax_cross_entropy_with_logits_v2`
  <https://zhuanlan.zhihu.com/p/95793237>  
  tensorflow 官方文档

+ 稀疏张量使用  
  + `sparse_tensor`  
  <https://blog.csdn.net/weixin_36670529/article/details/100177454>    

  + `tf.sparse.sparse_dense_matmul`   
  [tensorflow官方文档](https://www.tensorflow.org/api_docs/python/tf)  

  + `tf.sparse.reorder`   
  [tensorflow官方文档](https://www.tensorflow.org/api_docs/python/tf)    

  + `tf.sparse_place_holder`  
  这个函数是占位符，用来喂数据的，因而这篇文章也介绍了教我们该怎么用sparse_tensor喂数据的
  <https://blog.csdn.net/haveanybody/article/details/86220140>   

  + `tf.nn.embedding_lookup_sparse`  
  <https://zhuanlan.zhihu.com/p/94212544>

+ `tf.reduce_mean`（参数）   
<https://www.cnblogs.com/junblog/p/10622896.html> 

+ `tf.contrib.layers.batch_norm`   
<https://blog.csdn.net/candy_gl/article/details/79551149>  
train阶段：reuse为False，is_training为True  
test阶段：reuse为True，is_training为False  
train时要新建整个网络的weights，因而reuse为False 

+ `tf.control_dependencies`, `tf.GraphKeys.UPDATE_OPS`  
<https://blog.csdn.net/wangdong2017/article/details/90082333>  

+ `tf.get_collection()`
<https://blog.csdn.net/qq_43088815/article/details/89926074>  

+ `tf.contrib.layers.l2_regularizer`，`tf.nn.l2_loss`  
[tensorflow官方文档](https://www.tensorflow.org/api_docs/python/tf)   

+ `tf.not_equal`,`tf.where`  
[tensorflow官方文档](https://www.tensorflow.org/api_docs/python/tf)   

+ `tf.cond()`  
[tensorflow官方文档](https://www.tensorflow.org/api_docs/python/tf)   

+ `tf.nn.embedding_lookup`  
  <https://www.cnblogs.com/gaofighting/p/9625868.html>  

+ `tf.gather`  
  <https://lcqbit11.blog.csdn.net/article/details/103134587>

+ `tf.set_random_seed`  
  这个函数是一个图级别的操作，设置的是图中所有random的种子  

+ `tf.ConfigProto()`
  + `device_count={"gpu": 0}`  
  这是用来指定特定的GPU的

+ `tf.train.exponential_decay`，`global_step`  
  <https://blog.csdn.net/leviopku/article/details/78508951>
  <https://blog.csdn.net/wuguangbin1230/article/details/77658229>

+ `tf.train.Saver()`，`tf.train.restore`    
  <https://zhuanlan.zhihu.com/p/31417693>
  <https://blog.csdn.net/thriving_fcl/article/details/71423039>
  <https://www.cnblogs.com/denny402/p/6940134.html>

+ `tf.train.get_checkpoint_state`  
  <https://blog.csdn.net/MrR1ght/article/details/81023330>  

+ `tf.Variable()`，`tf.get_variable()`
  <https://blog.csdn.net/u012223913/article/details/78533910>
  <https://blog.csdn.net/Touch_Dream/article/details/78998137>

+ `tf.global_variables`，`tf.all_variables`

+ `Tfrecord` 文件读取  
  <https://www.cnblogs.com/yanshw/p/12419616.html>  
  <https://www.jianshu.com/p/b480e5fcb638>

+ `tf.data.TFRecordDataset`  
  <https://blog.csdn.net/yeqiustu/article/details/79793454>    
  <https://www.cnblogs.com/yanshw/p/12419616.html>  
  常用的一些data transform 的操作  
  <https://zhuanlan.zhihu.com/p/38421397> 

+ `tf.tensordot`
  这个函数值得讲一讲，用好了非常的实用，我们分为`axes=1`和`axes=2`（`axes=k`的情况可以类推）两种情况来仔细说一说：  
  + `axes=1`时：比如对于(4,5,3,2)和(2,5,6,1,2,1)两个tensor之间tensordot。
  假设数据都是int型的，tensor1的最后一维是[int1, int2]，tensor1有 4\*5\*3 个这样的[int1, int2]，tensor2是[\(5,6,1,2,1), (5,6,1,2,1)]。  
  所谓`tensordot(axes=1)`的操作就是 (int1 \* 第一个(5,6,1,2,1) + int2 \* 第二个(5,6,1,2,1)，最终得到一个(5,6,1,2,1)。完整的`tensordot`的操作就是让tensor1的4\*5\*3 个这样的[int1, int2]与[\(5,6,1,2,1), (5,6,1,2,1)]\(即tensor2)都做这样的操作，注意这里[int1, int2]有4\*5\*3种不同的，但[\(5,6,1,2,1), (5,6,1,2,1)]只有一种，因而乘出来的结果只有4\*5\*3种不同的，最后结果的维度是(4, 5, 3, 5, 6, 1, 2, 1)

  + `axes=2`时：这个和`axes=1`的情况有点类似，比如对于(4,5,3,2,3)和(3,2,6,1,2,1)两个tensor之间tensordot。假设数据都是int型的，tensor1的最后两维是[[int11, int12, int13], [int21, int22, int23]]，tensor1有 4\*5\*3 个这样的东西，tensor2是[[(1,2,1), (1,2,1)], [(1,2,1), (1,2,1)], [(1,2,1), (1,2,1)]]。
  所谓`tensordot(axes=2)`的操作和`axes=1`时有一个不一样的地方在于，我们要先将tensor1和tensor2压平。对于tensor1，把他变成[int11, int12, int13, int14, int15, int16]，对于tensor2，把他变成[(1,2,1), (1,2,1), (1,2,1), (1,2,1), (1,2,1), (1,2,1)]，后面的操作和`axes=1`一样。（注意这里我这样讲是为了方便理解，其实应该按照矩阵乘法后再sum那样理解`axes=2`的tensordot，但是那样就太复杂了，结果都是一样的）  
    以上说的这些，都可以在<https://blog.csdn.net/sinat_36618660/article/details/100145804>这篇文章中验证一下
  
+ `tf.flags`(`tf.app.flags`)和`tf.app.run()`
  `tf.flags`的用法：<https://blog.csdn.net/spring_willow/article/details/80111993>
  `tf.app.run()`的用法：<https://stackoverflow.com/questions/33703624/how-does-tf-app-run-work>
  [tensorflow官方文档](https://www.tensorflow.org/api_docs/python/tf)  

+ tensorflow使用运行时的input形状初始化构图时的变量：  
  <https://stackoverflow.com/questions/34718736/dynamic-size-for-tf-zeros-for-use-with-placeholders-with-none-dimensions>   
  
+ `@tf_export`的使用  
  <https://blog.csdn.net/menghaocheng/article/details/83479754>

+ `tf.colocate_with`
<https://stackoverflow.com/questions/45341067/what-is-colocate-with-used-for-in-tensorflow>

+ `tf.TensorArray()`的使用
  注意：TensorArray不write()或者unstack()的话没办法read()和stack()，同时注意unstack()或write()以后要重新赋值。同时注意这个TensorArray是**只能写入一次**的，不能对同一个位置多次写入


+ tensorflow saved model保存模型步骤
  <https://www.jianshu.com/p/de8ae24d574a>


### tensorflow疑难解答
1. Variable name后面的":0"啥意思：一个op可能会有多个输出，":数字"是用来标识输出的
   <https://stackoverflow.com/questions/40925652/in-tensorflow-whats-the-meaning-of-0-in-a-variables-name>



  
  

### 注意事项及使用技巧
+ batch_norm api的几个坑  
<https://blog.csdn.net/u014061630/article/details/85104491> 

+ `tf.run` 和 `tf.eval()`的区别  
<https://stackoverflow.com/questions/33610685/in-tensorflow-what-is-the-difference-between-session-run-and-tensor-eval>  

+ tensorflow 中namescope 与variable scope的区别

+ `sess.run()`的注意事项
  + 括号内只能是op，或者是tensor
  + run的结果是array
  + feed_dict不能喂tensor，但可以喂list和dataFrame

+ `tf.data.TFRecordDataset`相关操作
  + `tf.data.TFRecordDataset.batch`   
  注意dataset.batch是不放回的取，因而需要将源数据赋值epoch个
  + `tf.data.TFRecordDataset.filter`  
  注意filter函数传进去的参数是一个布尔函数，这个布尔函数可以返回一个tf.bool的值

+ 如何将一个tensor转换成一个numpy array  
  <https://stackoverflow.com/questions/34097281/how-can-i-convert-a-tensor-into-a-numpy-array-in-tensorflow>  
    
+ 两个`tf.bool`型的tensor可以进行`&`运算，其他的都不行

+ `tf.less_equal`，`tf.greater`   
  这些都是可以传list或者数字进去的（两个参数位置都可以），因为他会内部转成tensor做运算，返回出来还是个tensor
  
+ tensorflow之Graph和Session的概念  
  <https://www.jianshu.com/p/5092d994573e>  
  <https://blog.csdn.net/xierhacker/article/details/53860379>

+ `tf.matmul()`   
  函数可以传入两个list（或者包含多个矩阵的tensor）相乘，要求list的length一样，这样两个list的元素会各自相乘。同时这个函数会把最外层的方括号变成矩阵的最外维。由此可推如果传入的两个参数第一维相同，或者第一第二第三....倒数第三维都相同（或一个参数的k维有值，另一个参数的k维没有，即符合broadcast原则），且最后两维是相反的，则仍然可以相乘且只有最后两维进行相乘。  
  另外这个函数也可以传入一个`batch*matrix`和一个`matrix'`，然后根据broadcast的原理，batch中的每一个matrix都会与`matrix'`独立相乘

+ `tf.reshape()`  
  这个函数挺坑爹的，因为这个函数网上讲的都有问题，如果第一维不为-1（假如为a），那么一定要注意，这里先把摊平的数组等分成a份。第二维如果还有值（假如为b），则应该再把第一步中分成的每一份等分成b份，以此类推（等分的时候是按摊平后先后顺序的，比如有矩阵是（3,4,5），那么（1,1,1）是摊平后的第一个，（1,1,2）是摊平后的第二个）

+ `tf.expand_dims()`
  这个函数的一个特点就是传进去的必须是tensor，除此之外如果axis=-1，则一定对应的是对最后一维的每个数字都加一个方括号，而不是对最后一维整体加一个方括号。（比如有tensor是[0,1,2]，tf.expand_dims(tensor([0,1,2], axis=-1)的结果一定是tensor([[0],[1],[2]])）

+ `tf.shape()`和`tensor.get_shape()`（`tensor.shape`）的区别
  <https://stackoverflow.com/questions/36966316/how-to-get-the-dimensions-of-a-tensor-in-tensorflow-at-graph-construction-time>
  <https://blog.csdn.net/wc996789331/article/details/89749796>
  这有一个非常重要的区别，就是tf.shape可以获取dynamic shape，这一点非常重要，给予做图巨大的方便。还有一点就是`tf.shape()`必须要在`sess.run()`中才能得出结果，如果直接`tf.shape(a)`一般只能给出一个`tensor`type，里面只会包含这个tensorshape的形状（即tensor.get_shape()的形状），注意：`tensor.get_shape()`和`tensor.shape`是一个东西
+ `tf.reshape()`和`tensor.set_shape()`的区别  
  <https://stackoverflow.com/questions/35451948/clarification-on-tf-tensor-set-shape>  

+ `tensor.shape.dims`，`tensor.shape.dims[0].value`， `tensor.shape.rank(ndims)`  
  第一个返回的是list（包含shape各个位置上的值（Dimension类型），相当于`list(tensor.shape)`），第二个返回的是int（是shape各个位置上的值），第三个返回的是`tensor`的秩。

+ `tensor`做了几个很重要的重载：
  1. tensor之间可以比较大小，tensorflow重载了比较运算符
  2. tensor可以与int型，float型相加，无论你是tf.Variable还是tf.constant
  3. tensor一个值可以与一组值比较大小：tf.constant(3) > tf.constant([1,2,3])，结果是一个tensor，里面有三个布尔值

+ `tensor.dtype`可以获取这个tensor的类型




我们可能认为dynamic rnn中的inputs是一个可能会嵌套的集合，nest.flatten就是会把它拉平，但是一定要每个元素的形状一样
_best_effort_input_batch_size 看看inputs里面有没有已经定义batch_size的，如果没有就使用第一个元素的dynamic size
sequence_length是集合，集合的长度必须是batch_size
_rnn_step这种事实上是先把所有的状态算出来，但是每次算出来的状态将根据sentence_length做一个tf.where()大于length的直接切掉  

```
def dynamic_rnn(cell, inputs, att_scores=None, sequence_length=None, initial_state=None,
                dtype=None, parallel_iterations=None, swap_memory=False,
                time_major=False, scope=None):
```  
这个函数做了以下几个操作，
1. 首先先把input变成flat_input（tensorflow认为input是nested的）
2. 再把每一个input从(B,T,D) => (T,B,D)
3. 再对sequence_length的秩的合法性做判断（sequence_length应该是一个vector）
4. 然后通过`_best_effort_input_batch_size`这个函数遍历每一个input，然后确定batch_size，这里注意每一个input的形状要一样，不然这个整个流程将出现问题。
5. 然后确定一个起始值state，注意如果参数中没有给`initial_state`那么就必须给出`dtype`那个参数，注意这个state并不是要做成一个nested的，因为
6. 再对sequence_length形状的合法性做判断，即sequence_length的长度应该是和batch_size一样。
7. 最后把flat_input再拼成input送到下一层`_dynamic_rnn_loop`

```
def _dynamic_rnn_loop(cell,
                      inputs,
                      initial_state,
                      parallel_iterations,
                      swap_memory,
                      att_scores = None,
                      sequence_length=None,
                      dtype=None):
```
这个函数做了一下几个操作，
1. 获取`state_size`，通过cell的state_size的属性获得。
2. 把input变成flat_input（tensorflow认为input是nested的），并把每一个cell里面的output_size也变成flat的，关键是是不是认为这两个flat的元素是对应的？
3. 然后对input的形状的合法性做一个判断，即第一维是time，第二维是batch，后面几维必须是确定的，同时保证每一个input的time和batch是一样的
4. 然后开始对每一个input都做一个初始的zero_output，这个是为了后面while_loop传参的方便，然后把这些个zero_output拼成一个和输入input形状一样的嵌套结构。
5. 接着获取一个batch里面的min_sequence_length，和max_sequence_length，以及设置一个初始time，这些都是为了后面while_loop传参
6. 接着这个其实挺重要，就是创建两个TensorArray——`output_ta`，`input_ta`，都适用于后面的传参，但是output_ta事实上是提前创建好一个容器，用于装填最后每个cell输出的state


## Sklearn
### 使用技巧
+ 随机抽取训练集和测试集  
  使用`sklearn.model_selection.train_test_split`，详见：
  <https://www.cnblogs.com/bonelee/p/8036024.html>  
  <https://scikit-learn.org/stable/modules/generated/sklearn.model_selection.train_test_split.html>


## Gunicorn


### 常见问题：
1. 如果他妈的报错说模块找不到，但是你看模块路径无比正确。这个是因为，这傻逼gunicorn必须要你在项目路径下启动（和模块同一路径下），如果过想在别的路径启动它，可以通过`--chdir 路径`指定模块路径。<https://stackoverflow.com/questions/42961409/how-to-run-gunicorn-from-a-folder-that-is-not-the-django-project-folder>



## collections 库
### 常用类型，函数
1. collections.OrderedDict
   有序字典经常会使用，一定要注意他这个有序字典是有条件有序的，即在定义时添加的键值对是无法做到有序的，只有后面加入的键值对是有序的。<https://zhuanlan.zhihu.com/p/98946805>

