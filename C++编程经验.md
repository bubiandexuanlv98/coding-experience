# C++常规语法部分  
1. 命名空间  
   一般命名空间就是在头文件中定义的
   + 同一命名空间可以散落在多个头文件中，当我们在同一个文件中`#include`这些文件的时候，这些散落的头文件中的同一命名空间的成员就会被合并。  
   
1. 类型宽度：
   
   无论在32位机还是64位机上，这些变量的宽度都是一样的：
   
   ```c++
   char:1字节；
   short:2字节；
   int:4字节；
   long:4字节；
   long long:8字节；
   float:4字节；
   double:8字节；
   long double:8字节；
   ```
   
   但是地址宽度是有区别的，32位机是4字节的地址，64位是8字节的地址
   
   + 结构体类型宽度
   
     c里面，结构体宽度sizeof(struct)是最宽的那个成员变量的整数倍，**但并不代表每个成员变量都必须占有最宽的那个变量的宽度**，比如：
   
     ```c
     struct st{
         int *p;
         int i;
         char a;
     };
     int sz = sizeof(struct st);
     ```
   
     sz是16，不是24，因为只要i和a在一块补够8就可以了，就满足整数倍的要求了。
   
2. 函数参数传递
   + 引用传递和指针传递：  
    引用传递中，形参假如是`int &x`，可以认为对它的每一步操作（即直接操作`x`），都相当于直接对外部的变量（实参）进行操作。但是这里引用事实上只是一个灵魂，如果查看`&x`事实上是外部实参的地址  
    而指针传递中，形参假如是`int *x`，可以认为对它的每一步**间接**操作（即操作`*x`）都相当于直接对外部的变量（实参）进行操作。但是与引用传递不同，如果查看`&x`事实上看到的是一个新的地址，而`x`才是外部实参的地址。此时如果直接修改了`x`则就相当于和外界断了联系（不会影响外部实参），这个时候再对`*x`做什么操作都不会影响外部变量
  
3. 引用
   + `int &p=8`是错误的，因为引用是内存地址的另一个门牌号，而`8`本身是一个字面量，是没有内存地址的。但是`const int &p=8`是可以的。也就是说引用
   + 常引用  
   常引用有两种初始化方式：1. `const int &p=8`（用字面量初始化）2. `const int &p=x`（用变量初始化），常引用和引用最重要的区别就在于常引用不能通过修改`p`去修改`x`，即`p`是不可修改的。但`x`自己还是可修改的
   + 引用和指针
   引用是一种受限的指针，他声明必须初始化（注意所有指针也是必须一声明就初始化，空指针绝对不允许，虽然只声明并不报错）。同时引用不能更换引用对象（从一而终），而且也不能指向别的数据类型（只能指向一种类型），这是因为他只是别名，不是地址，所带来的好处。指针可能指到任何一块地址（这块地址上可能存的是int，string，或野地址），所以这是指针危险的原因之一。
   + 注意事项  
   要注意引用被销毁的时候，只是销毁了别名，原对象并没有销毁。
   
4. 指针  
   + 指针是不需要释放的！！！，只有当指针申请了堆内存时，才需要释放，一个典型的例子就是：
   ```
   int a = 4;
   int *b = &a;
   ```
   a是存在栈上的，当函数一结束，自动被销毁，不需要指针去delete，指针本身也会在函数结束后被销毁。所谓要释放指针，并不是指针本身没有被释放（因为一般定义出来的指针都在栈上，栈上的内容，函数一结束自动释放），而是指针指向的堆内存需要释放，不然会引起内存泄露。
   + 指针释放完一定要置空，此时这个指针指向的是野地址，它不置空如果后面不用它是没有影响的，但是最好置空，这是一种很好的习惯，万一后面用了呢。
   + 指针还有一个危险的地方在于，一旦一个指针生存期一过，它就会被回收，然而它指向的自由存储区/堆中的内存（栈中的没关系，反正会被自动回收）不会被回收（这个问题被智能指针缓解）。但是有一个很关键的地方在于，假如一个生存期久的指针（甚至可能是自由存储区/堆）指向了一个生存期短的内存，这个块
   
6. 嵌套命名空间

7. include相当于什么？完全复制过来？

8. main函数中的`argc`和`argv`
   一般main函数都会这样写：`int main(int argc, char** argv)`注意这里面argc是参数个数，是一个int，而argv是一个指针数组，而不是一个简简单单的数组，指针数组意味着数组里面每一个元素都是一个字符串指针，因此用二级指针非常符合常理   


9.  `va_list`, `va_start`, `va_arg`, `va_end`（省略符形参表la）  
   <https://www.jb51.net/article/53749.htm> 
10. 可变参数的形参表（同类型），可变参数的形参表（不同类型）  
    <https://www.jb51.net/article/53749.htm>   
11. explicit 和 implicit 修饰的构造函数：  
    <https://www.cnblogs.com/rednodel/p/9299251.html>  
12. do...while(0)的妙用  
      <https://blog.csdn.net/zhangxiao93/article/details/51514097>  
13. 宏定义中的 `__VA_ARGS__`    
    <https://blog.csdn.net/zhangkai19890929/article/details/82392300>  
14. 移动构造函数  
这种函数事实上就是把当前对象的资源转给了新的对象，同时把当前对象的资源销毁。这里面涉及到右值引用，在很多时候右值往往会意味着即将消亡的意思，普通引用一般为`类名 &对象名`，而右值引用一般为`类名 &&对象名`   
15.  vscode 编写c++代码，添加提示路径和编译依赖：<https://blog.csdn.net/liguan1102/article/details/108629033>  
17. c++函数使用throw()结尾  
      <https://www.cnblogs.com/xiangtingshen/p/11575154.html>    
17.  函数中的默认参数都是在声明中提供的，而不是在实现的时候。如果在实现的时候提供，有时候编译器会报错，这是因为实现（定义）的时候提供默认参数，使用这个函数的用户是看不见的，因此应该避免这种写法
19. 枚举类型    
    注意一个问题就是枚举类型里面的数据都是命名整数常量，他们不是字符串，而是代表着一个整数
    <http://c.biancheng.net/view/1367.html>
20. using的用法
   1. 命名空间
   2. typedef的作用，eg：`using Ustring = std::string;`就是使用`Ustring`代替`std::string`
   3. 继承体系中，改变部分接口的继承权限。有这样一种应用场景，比如我们需要私有继承一个基类，然后又想将基类中的某些public接口在子类对象实例化后对外开放直接使用<https://www.cnblogs.com/wangkeqin/p/9339862.html>。
   23.  注意：c++编译器不支持使用typedef关键词为模板类设置别名，但是使用using的方式声明一个模板类的别名却是允许的。
21. 成员函数最后加上const，表示它不能修改类中的成员变量
22. c++获取变量类型，并输出的方法：
```
#include <typeinfo>
std::cout<<typeid(variable)..name();
```
23. c++对于构造函数的处理是这样的：没有构造函数，编译器自动创建一个空的构造函数，如果定义了构造函数，编译器就不会再为你定义默认构造函数，但这样是不安全的，因此需要你自己定义默认构造函数，这里加不加default的区别可见<https://stackoverflow.com/questions/20828907/the-new-syntax-default-in-c11>，在我这个阶段，目前理解不了这个，暂时就全部加default吧。
24. new运算符分为两种，一种是normal new，就是我们平时用的那种，另一种是placement new，它是用来把数据放在一段已存在的内存地址上（可能在栈上，也可能在堆上），典型用法：（用法详解：<https://www.geeksforgeeks.org/placement-new-operator-cpp/>）
```
unsigned char buf[sizeof(int)*2] ; 
int *pInt = new (buf) int(3); // qInt指向buf中第一个元素地址（栈上）
int *qInt = new (buf + sizeof (int)) int(5); 

int X = 10; 
int *mem = new (&X) int(100); // 注意100覆盖了10 
```
25. static关键字（静态变量和静态函数（内部函数））
一个比较直观的概括就是，static修饰的变量和函数最关键的点是它被限制使用范围了，虽然所有static修饰的变量/函数与全局变量/函数都存储在静态存储区（生存期为整个源程序），但是static修饰的往往只在定义它的那个范围内才能使用，别的地方使用不了。
<https://www.cnblogs.com/daochong/p/6890520.html>

26. 许多库类型都定义了一些配套类型（比如string的string::size_type，rapidjson中的rapidjson::Sizetype），他们的好处就在于通过这些配套类型，库类型的使用就能与机器无关（machine-independent）。string::size_type 就是这些配套类型中的一种。它定义为与 unsigned 型（unsigned int 或 unsigned long）具有相同的含义，而且可以保证足够大能够存储任意 string 对象的长度。他这种类型就是一定能保证一定和本库中所需要的内容适配

27. const 常量的fun fact：它修饰的变量并没有存储在某一个区域（他可以修饰任何一个区域的变量），他所做的操作只不过是类似于#define的操作，在编译阶段就把const修饰的变量用值替换掉。

28. 在C++中，内存区分为5个区，分别是堆、栈、自由存储区、全局/静态存储区、常量存储区，
    + 注意堆和自由存储区的区别：<https://blog.csdn.net/qq_28584889/article/details/88756489> malloc和free针对堆，new和delete针对自由存储区。自由存储区大部分在堆上（几乎所有的cpp编译器都会用这种方式处理），也可以别的地方，很多会把堆和自由存储区混为一块，这是有道理的。
    + 自由存储区/堆上的内存是动态存储，即编译器在程序运行时才分配内存，c++不针对动态存储的内容做垃圾回收，因此需要手动释放，但是程序结束后操作系统会自动回收这一部分。其他都是静态存储，即编译器在编译阶段就知道要分配多少内存，栈上的内容一般由程序自动分配和释放，常量和全局都是由程序分配，但是程序结束时才会释放。
    + 各个区存的哪些东西？
      静态存储区的生存周期是全局
   
29. c++的pass直接写一个`;`就可以了

30. c++如果函数内部需要参数的一个副本，那就应该使用值传递的方法，在函数内部显示复制，编译器无法优化。

31. c++中声明/定义的区别：  
    ①变量的定义：用于为变量分配存储空间，还可以为变量指定初始值。在一个程序中，变量有且仅有一个定义。  
    ②变量的声明：用于向程序表明变量的类型和名字。定义也是声明：当定义变量时我们声明了它的类型和名字。
    简单来说：定义就分配内存空间。声明只是做个标识
  
32. c++中初始化/赋值的区别：
    定义时的赋值是初始化，定义后再赋值是赋值，这句话很糙，但可以这么理解。对于简单类型变量，这两个概念可以不区分，但对于一个类其实初始化调用的是构造函数或拷贝构造函数，而赋值可能是调用的重载的=运算符。例子：<https://www.cnblogs.com/lxy-xf/p/11049963.html>
    
33. c++中extern关键字的用法：extern牛逼的地方就是他是只声明而不定义，这个其实很牛逼，因为如果不加extern，直接弄，它就是一个定义：
    ```
    int i; //声明并且定义了一个变量i
    extern int i; //声明一个变量i，但是并没有定义
    ```
    由于定义只能有且只有一个，因此如果你想使用一个外部变量（这个外部变量又很不幸的没有出现在任何一个头文件中），那么你必须用extern声明一下才能用，为啥会有这种设计风格，因为一般情况下我们不会把变量的定义（尤其是简单变量）写到某个头文件里面，因为这样容易出现重复定义的错误。
    虽然extern也可以把声明，定义，初始化全做了，但这种愚蠢的写法非常不建议：`extern int i = 0;`
    参考博客：<https://www.cnblogs.com/vivian187/p/12737534.html>
    
34. 常指针和指针常量：
    1. 常指针：`const int* p`,`int const* p`这两个其实是同一个意思，但是第二个容易混淆，所以一般都用第一个，这个的含义是指指针指向的内容不能变
    2. 指针常量：`int* const p`这个是指指针常量，指针所指向的值是可以变化的，而指针本身是不能变化的
     指向const的指针（指针指向的内容不能被修改）const关健字总是出现在\*的左边而const指针（指针本身不能被修改）const关健字总是出现在\*的右边，那不用说两个const中间加个*肯定是指针本身和它指向的内容都是不能被改变的。

35. 运算符优先级：
    1. ->的优先级高于*，这就意味着指针p，*p->method，是先p->method再去做取值运算符\*。
    
35. 数组类型
    
    首先对编译器来说没有数组这一概念，数组都被看成指针，所以a[ ]就是*a，\*a[]就是**a


36. __attribute__的作用（用于编译器检查）
37. 枚举类型enum
    1. 枚举类型声明时可以没有类型名，如果声明枚举类型时没有指定枚举名，其作用就和#define类似，例如：
      ```
      enum {
         CACHE_TYPE_1, 
         CACHE_TYPE_2,
         CACHE_TYPE_MAX,
      };
      ```
      这里声明了一个枚举类型确没有指定其枚举名，那么它就相当于用#define定义了三个名称和其对应的值，从0开始赋值每次加1。相当于
      ```
      #define CACHE_TYPE_1 = 0;
      #define CACHE_TYPE_2 = 1;
      #define CACHE_TYPE_MAX = 2;
      ```
38. C++ 模板（泛型）

## 注意事项
1. c++不允许类内用圆括号进行初始化（类初始化列表除外）
2. 注意c++函数返回值如果不是引用，会发生复制，此时外面接收的变量不能是引用类型。如果想不发生复制必须要返回值是引用类型，外面接收的变量也必须是引用类型，如果此时外面变量不是引用类型，仍然会发生复制。
3. 指针在删除以后一定要置NULL，因为`delete 指针`并没有删掉指针本身，只是删掉了指针指向的内存
4. 在c++中，尽量使用++i，而不使用i++，因为这样有助于减少开销，i++一般会先创建一个i的副本，虽然对于int型，这种会被编译器优化掉，但别的情况（比如容器的迭代器，这个就没法处理）。其他高级的原因可以见<https://stackoverflow.com/questions/4706199/post-increment-and-pre-increment-within-a-for-loop-produce-same-output>这里面后面有一个答案讲的很详细，前几个答案都没意义
5. **c++所有函数的返回值都是临时右值，临时右值如果不接收是立马销毁的，如果被接收，则和被接收的变量的生存期一致**问问问问！！！！！！



# 函数相关问题
## 重载问题
1. 函数形参被const修饰一般不能作为重载的依据，有极少数情况可以，见<https://www.cnblogs.com/qingergege/p/7609533.html>


# 类相关问题
## 成员函数相关
1. 常成员函数  
   成员函数后缀const，加不加这个const可以作为重载的标准之一。这种函数专门处理常对象（有重载的情况下），它相当于是一个保证，就是我绝对不改变对象的状态，即不改变类中的成员变量。其实这个函数也会被一般对象调用（没有重载的情况下）
   ```
   eg.
   const object b(20, 52)
   b.print() //这个会专门去调用带const后缀的print函数
   ```
2. 类的静态成员

   类的静态方法只能访问该类的静态成员函数和静态成员变量（即类定义中所有用static修饰的内容），不能访问实例变量和实例方法

3. 定义在Class声明内的成员函数默认是inline函数

## 初始化相关

1. 初始化列表
   + 子类初始化列表可以调用父类初始化列表，一般写法是这样，在子类初始化列表里面写父类的初始化列表：<https://blog.csdn.net/hanshihao1336295654/article/details/85085274>  
   ```
   子类构造函数（数据类型  数值1，数据类型  数值2）：父类构造函数（），变量名1（数值1），变量名2（数值2）{} 
   ```

   + 有几种情况是必须要用初始化列表的：
   在创建对象调用构造函数之前会对所有的成员变量进行默认初始化，然后再执行构造函数体里的内容，初始化列表是先于这两步的，因此他对那种成员变量没有无参构造函数的对象管用。（注意事项第1点要注意）
   <https://blog.csdn.net/u011857683/article/details/79720782>

2. 无参构造函数不是默认构造函数！！！，一定要注意表述，有时候是要求你必须有默认构造函数，有时候只要有无参构造函数就行了

3. 构造函数
   + 如果定义了构造函数，那么编译器不会生成默认构造函数的
   + 

## 成员变量相关
1. 类成员函数不能把类私有变量直接弹出去（即返回引用或者指针的那种），一个会有线程安全的问题，另一个也是一个糟糕的设计结构，如果外面想获得私有变量，中间应该有一层复制，即外面不能直接获得私有变量的所有权。

## 继承/多态问题
### 多态问题
1. 注意，对于C++里面的多态，只关心行为，不关心变量，也就是说，不存在变量重写覆盖，只有对函数的重写，事实上对于如下的代码：
   ```
   #include <iostream>
   #include <string>
   
   class Person
   {
   public:
   Person(){ name = "fuck"; }
   
   virtual std::string get_name() {
     return name;
   };
   
   std::string name;
   };
   
   // BaseballPlayer publicly inheriting Person
   class BaseballPlayer : public Person
   {
   public:
   BaseballPlayer(const std::string& t):name(t){}
   std::string get_name();
   std::string name;
   };
   
   std::string BaseballPlayer::get_name() {
   return name;
   }
   
   void test(Person& p) {
   std::cout << p.get_name() << std::endl;
   }
   ```
   当BaseballPlayer继承了Person以后，在BaseballPlayer里面Person的name就变成了：Person::name，名字变了

### 继承问题
1. 派生类一般只给直接继承的基类的构造函数传参数
2. 虚继承是为了解决类似于钻石继承的问题，减少冗余复制和二义性（防止把最远基类复制多次，以及防止把最远基类初始化多次）它的形式类似于：
```
class ProfileIfSingletonFactory : virtual public ProfileIfFactory
```
此时`ProfileIfFactory`这个类就是虚基类，这种继承也叫虚继承。有两个问题，第一就是虚继承必须发生在第一级继承，第二就是虚基类的构造一般发生在最远派生类中，也就是最远派生类要给虚基类构造函数传参，同时其他虚基类的派生类传的构造函数全部失效。如果最远派生类没有给虚基类传参，那么不管其他派生类有没有给它传参，它都会默认调用默认构造函数。

### 虚函数
几个概念明确一下：定义一个函数为虚函数，不代表函数为不被实现的函数。定义他为虚函数是为了允许用基类的指针来调用子类的这个函数。定义一个函数为纯虚函数，才代表函数没有被实现。
1. 纯虚函数的类是一个抽象类。所以，**用户不能创建类的实例**，只能创建它的派生类的实例。纯虚函数最显著的特征是：它们必须在继承类中重新声明函数（不要后面的＝0，否则该派生类也不能实例化），而且它们**在抽象类中往往没有定义**。
   
## 注意事项



# C++ 智能指针
## shared_ptr
1. 这个指针的含义是：同一个对象可由多个shared_ptr托管，此时这些托管同一个对象的（这里的对象就是指针）shared_ptr会共享一个托管计数器，多一个shared_ptr托管这个对象，计数器就会加1，少一个就会减1，这个托管计数器减为0时，这个对象就会被销毁。注意当shared_ptr生存期过了或者reset了以后，都算解除托管
2. 注意：这里的托管计数器可看成是那个被托管的对象（指针）的属性，而不是shared_ptr内部的属性。
3. 注意：这个指针只能指向new出来的内存，其他都指不了
4. 注意：和unique_ptr不一样，shared_ptr可以传递给别的指针，因为它是计数销毁的，不是一个shared_ptr没了别的都没了，所以传递时很安全
5. 注意：shared_ptr的声明时的初始化，和声明后再初始化所用的方法不一样，声明时可以直接`shared_ptr ptr(new  ...)`，但声明后再初始化就得用`ptr.reset(new ...)`。这个的原因比较有趣：是因为如果声明后再初始化就相当于是reassign，shared_ptr不能以`()`或者`=`的方式reassign给一个普通指针，但是可以以这两种方式reassign给一个shared_ptr，因此使用`shared_ptr ptr(std::make_shared<...>(...))`是可以的。而对于`shared_ptr.reset`的方法，是没有这个限制的，可以参考：<https://stackoverflow.com/questions/31438714/stdshared-ptr-reset-vs-assignment>。注意一下为啥我那个情况下`()`不行？

# C++中的锁
## mutex（互斥锁）
1. `std::lock_guard`这个类相比于直接用mutex.lock和mutex.unlock，它最大的好处（我现在能理解的）就在于当mutex被销毁以后，mutex.unlock自动被调用。假如程序在mutex.lock和mutex.unlock之间发生异常时，锁被销毁，但锁依然没有被放开（程序发生异常时锁会销毁）。
其他好处（相较于mutex.lock）：
<https://blog.csdn.net/y396397735/article/details/81024755>  
<http://jakascorner.com/blog/2016/01/deadlock.html> 这篇文章是理解死锁的一篇好文章
2. 死锁现象 
<http://jakascorner.com/blog/2016/01/deadlock.html>




# STL相关  
## STL容器
STL容器是一个很神奇的东西，它事实上是一个可存放数据的类模板，换句话说它是一个定义好的类，只不过存放数据的类型是模板参数，需要我们指定，那么一个类自然有析构函数，STL容器的牛逼之处就是在于当我们在函数中声明一个容器a，a相当于一个对象！！！。这个对象存在栈上面，但对象中某个成员是一个指针，这个指针会申请一块堆内存，然后把数据存在堆上，所以你打a的大小，只能打出这个STL容器类的成员变量的大小，并不是堆上数据的大小（即不是容器存储内容的大小）
以vector为例：
这个对象有很多成员变量（a.begin，a.end等等）。在a的生存期结束以后容器类的析构函数会**自动执行释放堆内存**。除此之外vector重载了`[]`运算符，使得可使用`对象名[]`索引
1. vector使用
   vector 是动态数组 
   声明：`std::vector<类型> 名字`   
   + 往vector的末尾加一个元素：`vector名.push_bask(元素)`，以后尽量使用`emplace_back`代替`push_back`（对于所有顺序容器，vector,deque,list），因为`emplace_back`是直接调用被加入类型的移动构造函数，`push_back`是先拷贝一份临时变量，再移动构造，类似于值传递。二者区别简析：<https://blog.csdn.net/messi_31/article/details/98444744>，二者区别详解：<https://zhuanlan.zhihu.com/p/183861524>。但有的时候我们可能需要值传递而不是地址传递！！！
   + vector不是自动排好序的，它也没有find函数
   + vector遍历方法：<https://blog.csdn.net/weixin_44635198/article/details/104538995>其中`.at(i)`的访问挺有意思，他能防止越界。


2. set使用  
   set 是集合，它和python中set不同的是，默认情况下会自动对元素进行升序排列（其实内部是红黑树，遍历实际上是中序遍历），其余都差不多，set中元素都是唯一的，注意set不能用index索引  
   <https://blog.csdn.net/shuaizhijun/article/details/88955081>这个可能不好
   + set的添加元素操作和map一样，可以参考map的添加操作，现阶段也是最好用insert
   + 查找元素：set.find()  
      查找一个元素，如果容器中不存在该元素，返回值等于s.end()  
   + set的遍历：set不能用index索引，因此它的常用遍历方法有两种：一种是靠迭代器遍历（注意要用*iterator访问具体内容），另一种是靠c++11的新特性：range-based for loop 来回收，两种方法具体可见<https://stackoverflow.com/questions/12863256/how-to-iterate-stdset>
   + set的lower_bound和upper_bound
      set.lower_bound(a)指的是set里面不小于a的第一个元素。set.upper_bound(a)指的是set里面大于a的第一个元素。

3. map使用  
   map存储的是key，value的键值对，map中的元素是按照key升序排列，和set的情况是一样的。  
   <https://blog.csdn.net/qq_28351609/article/details/84630535>  
   + map必须要求key可比较，不然无法运作，如果是自定义类型加入map则要满足：要么自己定一个比较函数对象（函数对象的概念自己查一下，就是可以用函数小括号方式使用的对象），要么重载比较运算符。
   + map的添加元素的方法有insert 和 emplace/emplace_hint等 但是现阶段暂时都用insert，因为map的emplace在临时变量构建的代价不大时，和insert比没有优势：<https://www.cnblogs.com/narjaja/p/10039509.html>，emplace/emplace_hint的详细用法可以查阅：<http://m.biancheng.net/view/7182.html>。
   + map插入元素方法insert中，最好使用这种插入方式：`map名.insert(map<int, double>::value_type(1, 9.8))`。几种insert方式的开销比较：<https://blog.csdn.net/hisinwang/article/details/45133379>

4. std::move(a)  
   这个强制把左值引用转换为右值引用，这是句废话，其实就是把a里面的内容掏空，赋给承接这个表达式的值，这样操作以后，a就空了，这样节省了内存。 
   <https://blog.csdn.net/p942005405/article/details/84644069>  

5. boost::any  
   在boost库中，any是一种特殊容器，只能容纳一个元素，但这个元素可以是任意的类型----int、double、string、标准容器或者任何自定义类型。程序可以用any保存任意的数据，也可以在任何需要的时候取出any中的数据。这个语法只能在c++17中使用
   <https://www.cnblogs.com/japelly/p/9957759.html>   

6. std::sort
   sort只能用来sort容器，不能用来sort map

7. std::容器::swap()（这是STL容器类中的一个成员函数）
   一定要注意这个swap是指针交换，所以它很快，它并没有拷贝一个容器的内容到另一个内容，而是只是用泛型函数swap交换了两个容器的首指针和尾指针。
   <https://www.cnblogs.com/xiaobingqianrui/p/9092051.html>

### 注意事项
1. 一定要注意这些容器的`.end()`的地址是最后一个元素的下一个元素的地址（即`.end()`是最后一个元素下一个元素），此时`rbegin()`才是真正的最后一个元素，`.begin`和`.rend()`同理
2. `.begin()`和`.cbegin()`的区别在于.begin()返回的不一定是一个常量迭代器（一种类似于指针的东西），只有对于一个常量容器，才会返回一个常量迭代器，而.cbegin()这个返回的一定是一个常量迭代器，因此.begin()这个有一点危险，用.begin()返回出来的迭代器是可以修改的（这可能会导致迭代混乱），但编译器也注意到这个问题，所以.begin()返回出来的迭代器不能用引用接收，只能复制一份用于修改容器内部的元素。
3. 容器有一个非常棘手的问题，尤其是顺序容器，他们的索引是指针操作，索引越界就会出现**段错误的风险**！！！！，所以你有的时候看自己并没有使用指针，但是他妈的却报段错误，就是这个原因。这个也是动态内存分配所带来的后果，动态内存分配无法检查索引越界问题！！！

## string类型（本质上也是STL容器） 
1. `std::string::find()` 和 `std::string::npos`  
   <https://www.cnblogs.com/shmilxu/p/4837660.html>  
   实现python中的split的功能：`C:\Users\10956\Desktop\recommend-tf21cpp-project\util\string_util.cpp`中的Split，这个函数在`C:\Users\10956\Desktop\recommend-tf21cpp-project\tensorflow_serving\model_servers\extend\afm_feature_constructor.cpp`中的`_construct`中被调用
2. `std::string::find_first_of()`和`std::string::find_last_of()`  
   这两个函数非常脑残，find_first_of()很显然不用解释，但最脑残的是find_last_of()，它是从字串从后往前数最后一个匹配串，即从前往后数第一个匹配串（显然是find_first_of()的结果），他俩唯一的区别在于first是返回的从头往后第一个匹配串的第一个字符的位置，last是从头往后第一个匹配串的最后一个字符的位置
   <https://www.cnblogs.com/zh20130424/p/11099932.html> 注意他们返回的都是size_t
3. string实现split方法：<https://www.zhihu.com/question/36642771>
4. string::npos 表示string的最后一个位置的地址
### 注意事项
1. 人生中第一次全量上线犯的巨大错误：不要妄图使用`std::string::find`去代替`=`号或者`std::set::find`，这个非常危险，因为可能一个string会包含另一个string！！！！！！！！，这时候虽然find成功，但结果可能是错误的，这个非常可怕！非常可怕！非常可怕！因为不仔细查根本查不出来

## STL算法
1. random_shuffle
    注意这个算法不能对set，map这样的数据结构进行操作，不然编译通不过，c++14开始就没有这个算法了，得切换到shuffle：<https://stackoverflow.com/questions/45013977/random-shuffle-is-not-a-member-of-std-error>
2. shuffle
    random_shuffle和shuffle的用法和区别：<https://www.geeksforgeeks.org/shuffle-vs-random_shuffle-c/>
3. 

# Protobuf  
1. packed = True 就是规定一种对repeated的field的编码方式，proto3中自动对repeated field 使用这种编码方式  


# Bazel 编译  
1. 


# rapidjson
## Array操作（即对数组类型操作）
1. rapidjson如果解析出来的是一个Array，那么你GetArray()再索引，和你直接索引是一样的，除此之外，没有必要在索引之前写一个`const rapidjson::Value& = a.GetArray()`或`const rapidjson::Value& = a`这种东西。但是如果想使用c++11功能的for循环，即`for (auto& v : a.GetArray())`，则必须要用`a.GetArray()`。如果不加`GetArray()`，则必须要使用`for (Value::ConstValueIterator itr = a.Begin(); itr != a.End(); ++itr)`。`.Size()`这个东西只有Array才有，它是既可以在`GetArray`后面，也可以直接跟在`Array`后面
## 注意事项
1. rapidjson使用字符数组表示字符串，没有string类型。
2. **这个点是我遇到最最恶心的一个点**，这也是C++的问题：大家给解释解释什么叫他妈的行为是“未定义”的
RapidJSON 并不自动转换各种 JSON 类型。例如，对一个 String 的 Value 调用 GetInt() 是非法的。在调试模式下，它会被断言失败。在发布模式下，**其行为是未定义的。** C++中的库如果出现行为是未定义（undefined）这样的字眼一定要注意就是他妈的**服务端不报任何错误**，服务也没有挂掉，但就是这个请求没有继续解析下去。