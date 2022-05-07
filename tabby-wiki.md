[]*Pool{p} 啥意思，为啥要用这种？

xconf.UnmarshalKey 咋解析的

返回的是pools而不是pool

pkg/conf/conf.go 里面的configuration啥时候初始化的


## tabby框架的log问题
在tabby框架中，有四种类型的日志，具体见conf.yaml，所有的xlog打出来的日志都会送到kibana上面去，如果不加WithContext，则默认打到running类型的key上去
+ 加上WithContext(ctx)，是为了加上上下文，这个有两个作用：
  1. 对于非`Error`，`Errorf`的日志，加上上下文可以将此处打出的log，上传至kibana时，日志类型key是跟调用此函数的调用方保持一致的，如果调用方没有设置，就一直向上追溯直到找到设置类型的位置为止，发送到指定日志类型key的kibana上面（kibana上面根据四种类型的日志，有四种不同的key），一般的`ctx := tcontext.WithContext(c)`都是默认running类型，如果看到有`ctx := TaskLoggerContext()`，则说明是task类型
  2. 还有一个非常重要的作用，就是这样打出来的日志会带上traceId，未来可以用通过traceId去看整个链路，即这一个请求是如何从最初生成，如果过的各级调用等等，但是这个前提是链路上的调用都使用了tabby或者日志模块都带traceId的那种。
注意如果是`Error`，`Errorf`类型的日志。无论如何都会把内容打到error类型的key下面
+ 不加上WithContext(ctx)，则默认打到running类型的key下面，但是`Error`，`Errorf`的日志都是打到error的key下面的
+ 不要改logging里面default的设置，那是框架用的，一般改running里面就可以了


## tabby中的定时任务注册-启动流程
1. 自行实现一个定时任务的struct，假设叫CronJob，这个类要实现接口xtask.Handlers
2. 这个CronJob在engine.go里面的initJob中被注册到eng里，实际上是由tabby.App中的taskManager中的xtask.Tasker中的RegisterHandler注册到cron包中，注意xtask.Tasker是一个接口，tabby里面专门处理任务的包xtask中的xcron实现了一个XCron结构体，这个玩意实现了xtask.Tasker这个接口
3. 运行的时候，是由tabby.go 中的`app.cycle.Run(app.startCronTasks)`运行xtask.Tasker.run()，实际运行的是xcron.Run()，实际运行的是cron包中的Run()，cron包里面的Run()实际运行的是cron包里面Entry里面的WrappedJob的Run()，而这个WrappedJob是一个Job类型的变量，Job是一个接口，在定时任务里面，这个接口被xcron中的xconfig中的wrappedJob实现了，wrappedJob中的Run()实际上执行的是它里面NameJob的Run()，NameJob是一个接口类型，它是在xcron/cron.go中的schedule 函数中被赋值，这个值是由schedule函数传进去的，schedule又是由addJob()函数调用的，addJob()又是由RegisterHandler()调用的，那个NameJob类型就是在这里被传进去的，注意NameJob是个接口，tabby中是用一个函数实现了这个接口，这个函数叫FuncJob，FuncJob的Run()就是运行自己本身。而FuncJob本身里面就有Exec()函数，也就是我们实现的那个CronJob里面的函数
 