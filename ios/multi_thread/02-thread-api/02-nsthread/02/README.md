[TOC]




## 1. 局部 thread 对象

### 1. 自定义 NSThread 子类

```objective-c
@interface MyThread : NSThread
@end
@implementation MyThread
- (void)dealloc {
  NSLog(@"[MyThread dealloc: %p] %@", self, self);
}
@end
```

### 2. ViewController 中创建、并使用一个 局部 MyThread 对象

```objective-c
@implementation ViewController

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  // 局部线程对象
  MyThread *t = [[MyThread alloc] initWithTarget:self selector:@selector(doWork) object:nil];
  [t start];
}

- (void)doWork {
  NSLog(@"[MyThread doWork: %p] %@", [NSThread currentThread], [NSThread currentThread]);
}

@end
```

### 3. 运行程序

```
2019-12-14 17:47:13.448897+0800 Haha[6143:716081] [MyThread doWork: 0x600000954900] <MyThread: 0x600000954900>{number = 7, name = (null)}
2019-12-14 17:47:13.449192+0800 Haha[6143:716081] [MyThread dealloc: 0x600000954900] <MyThread: 0x600000954900>{number = 7, name = (null)}

2019-12-14 17:47:18.222431+0800 Haha[6143:716184] [MyThread doWork: 0x600000952740] <MyThread: 0x600000952740>{number = 9, name = (null)}
2019-12-14 17:47:18.222710+0800 Haha[6143:716184] [MyThread dealloc: 0x600000952740] <MyThread: 0x600000952740>{number = 9, name = (null)}

2019-12-14 17:47:20.074074+0800 Haha[6143:716197] [MyThread doWork: 0x6000009582c0] <MyThread: 0x6000009582c0>{number = 10, name = (null)}
2019-12-14 17:47:20.074252+0800 Haha[6143:716197] [MyThread dealloc: 0x6000009582c0] <MyThread: 0x6000009582c0>{number = 10, name = (null)}

2019-12-14 17:47:21.885649+0800 Haha[6143:716302] [MyThread doWork: 0x60000093a500] <MyThread: 0x60000093a500>{number = 11, name = (null)}
2019-12-14 17:47:21.885959+0800 Haha[6143:716302] [MyThread dealloc: 0x60000093a500] <MyThread: 0x60000093a500>{number = 11, name = (null)}
```

结论：

- 每一个 thread 对象的 **内存地址** 都是不同的, 说明每一次创建的都是 **新的** 线程对象

## 2. 持有住 thread 对象

```objective-c
@interface MyThread : NSThread
@end
@implementation MyThread
- (void)dealloc {
  NSLog(@"[MyThread dealloc: %p] %@", self, self);
}
@end

@implementation ViewController {
  MyThread *_t;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  _t = [[MyThread alloc] initWithTarget:self
                               selector:@selector(doWork)
                                 object:nil];

  [_t start];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//   waitUntilDone:YES 会崩溃
//  [self performSelector:@selector(doWork)
//               onThread:_t
//             withObject:nil
//          waitUntilDone:YES];

  // waitUntilDone:NO 正常
  [self performSelector:@selector(doWork)
               onThread:_t
             withObject:nil
          waitUntilDone:NO];
}

- (void)doWork {
  NSLog(@"[MyThread doWork: %p] %@", [NSThread currentThread], [NSThread currentThread]);
}

@end
```

当程序运行起来，就会有如下输出

```
2019-12-14 17:52:37.231471+0800 Haha[7351:725823] [MyThread doWork: 0x600002abca00] <MyThread: 0x600002abca00>{number = 6, name = (null)}
```

- 然后当你无论点击多少次屏幕，都 **不再有任何的输出**
- 也就是说指定的线程回调方法 **doWork 不会再被执行**
- 这是为什么了？
- 可能你想实时打印一下 thread state 看看到底线程为什么不响应了？

## 3. 显示 线程对象的 state

```objective-c
@interface MyThread : NSThread
@end
@implementation MyThread
- (void)dealloc {
  NSLog(@"[MyThread dealloc: %p] %@", self, self);
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@ - %p>: \n\tisExecuting = %d, \n\tisCancelled = %d, \n\tisFinished = %d",
          [self class],
          self,
          self.isExecuting,
          self.isCancelled,
          self.isFinished];
}

- (NSString *)debugDescription {
  return [self description];
}
@end

@implementation ViewController {
  MyThread *_t;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  _t = [[MyThread alloc] initWithTarget:self
                               selector:@selector(doWork)
                                 object:nil];

  [_t start];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//   waitUntilDone:YES 会崩溃
//  [self performSelector:@selector(doWork)
//               onThread:_t
//             withObject:nil
//          waitUntilDone:YES];

  // waitUntilDone:NO 正常
  [self performSelector:@selector(doWork)
               onThread:_t
             withObject:nil
          waitUntilDone:NO];
}

- (void)doWork {
  NSLog(@"[MyThread doWork: %p] %@", [NSThread currentThread], [NSThread currentThread]);
}

@end
```

当程序运行起来，就会有如下输出

```
2019-12-14 17:56:38.123625+0800 Haha[8218:733939] [MyThread doWork: 0x600001585c00] <MyThread - 0x600001585c00>:
	isExecuting = 1,
	isCancelled = 0,
	isFinished = 0
```

但是点击屏幕，还是没任何输出，因为 doWork 方法压根就不走，根本打印不了线程的属性值。

那如何才能实时打印了？

## 4. 打开 线程的 ==runloop==, 并注册时间, 让线程处于 =不死==

### 1. 打开 runloop 错误方式

```objective-c
@implementation ViewController {
  MyThread *_t;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  // 1. 创建线程
  _t = [[MyThread alloc] initWithTarget:self
                               selector:@selector(doWork)
                                 object:nil];

  // 2. 打开线程 runloop 三部曲
  // 获取/打开 线程的 runloop
  NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
  // 给 runloop 注册了一个事件源，否则 runloop 会自动退出
  [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
  // 启动子线程的runloop
  [runLoop run];

  // 3. 启动线程
  NSLog(@"thread start .....");
  [_t setName:@"MyThread"];
  [_t start];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//   waitUntilDone:YES 会崩溃
//  [self performSelector:@selector(doWork)
//               onThread:_t
//             withObject:nil
//          waitUntilDone:YES];

  // waitUntilDone:NO 正常
  [self performSelector:@selector(doWork)
               onThread:_t
             withObject:nil
          waitUntilDone:NO];
}

- (void)doWork {
  NSLog(@"[MyThread doWork: %p] %@", [NSThread currentThread], [NSThread currentThread]);
}

@end
```

- 如上代码当程序起来后，并没有输出 **thread start .....**
- 而且你怎么点击屏幕，也不会有任何的输出
- 为什么了？
- 因为 **[runLoop run];** 会卡住当前线程，不再往下执行

### 2. 打开 runloop 正确方式

```objective-c
@interface MyThread : NSThread
@end
@implementation MyThread
- (void)dealloc {
  NSLog(@"[MyThread dealloc: %p] %@", self, self);
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@ - %p>: \n\tisExecuting = %d, \n\tisCancelled = %d, \n\tisFinished = %d",
          [self class],
          self,
          self.isExecuting,
          self.isCancelled,
          self.isFinished];
}

- (NSString *)debugDescription {
  return [self description];
}
@end

@implementation ViewController {
  MyThread *_t;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  // 1. 创建线程
  _t = [[MyThread alloc] initWithTarget:self
                               selector:@selector(thread_entry)
                                 object:nil];

  // 2. 启动线程
  NSLog(@"thread start .....");
  [_t setName:@"MyThread"];
  [_t start];
}

- (void)thread_entry
{
  /**
   * 打开线程 runloop 三部曲
   */

  // 1. 获取/打开 线程的 runloop
  NSRunLoop *runLoop = [NSRunLoop currentRunLoop];

  // 2. 给 runloop 注册了一个事件源，否则 runloop 会自动退出
  [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];

  // 3. 启动子线程的runloop
  [runLoop run];

  // 4.
  NSLog(@"runloop finished run .....");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//   waitUntilDone:YES 会崩溃
//  [self performSelector:@selector(doWork)
//               onThread:_t
//             withObject:nil
//          waitUntilDone:YES];

  // waitUntilDone:NO 正常
  [self performSelector:@selector(doWork)
               onThread:_t
             withObject:nil
          waitUntilDone:NO];
}

- (void)doWork {
  NSLog(@"[MyThread doWork: %p] %@", [NSThread currentThread], [NSThread currentThread]);
}

@end
```

这次当程序起来后，就会有输出了

```
2019-12-14 18:09:00.717222+0800 Haha[11414:755110] thread start .....
```

- 解决了卡在 **[runLoop run];** 的问题

接下来，第一次点击屏幕的输出

```
2019-12-14 18:09:36.599495+0800 Haha[11414:755275] [MyThread doWork: 0x6000017c9380] <MyThread - 0x6000017c9380>:
	isExecuting = 1,
	isCancelled = 0,
	isFinished = 0
```

第二次点击屏幕的输出

```
2019-12-14 18:09:52.180026+0800 Haha[11414:755275] [MyThread doWork: 0x6000017c9380] <MyThread - 0x6000017c9380>:
	isExecuting = 1,
	isCancelled = 0,
	isFinished = 0
```

第三次点击屏幕的输出

```
2019-12-14 18:10:09.593516+0800 Haha[11414:755275] [MyThread doWork: 0x6000017c9380] <MyThread - 0x6000017c9380>:
	isExecuting = 1,
	isCancelled = 0,
	isFinished = 0
```

- 点击N次，doWork 方法，都能够正常被回调执行
- 说明只要正确开启了线程的 runloop，那么这个线程就永远处于 **不死** ，也称为 **线程保活**

## 5. 但是上例代码的问题: 线程对象 ==无法释放、废弃==

```objective-c
@interface MyThread : NSThread
@end
@implementation MyThread
- (void)dealloc {
  NSLog(@"[MyThread dealloc: %p] %@", self, self);
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@ - %p>: \n\tisExecuting = %d, \n\tisCancelled = %d, \n\tisFinished = %d",
          [self class],
          self,
          self.isExecuting,
          self.isCancelled,
          self.isFinished];
}

- (NSString *)debugDescription {
  return [self description];
}
@end

@implementation ViewController {
  MyThread *_t;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  // 1. 创建线程
  _t = [[MyThread alloc] initWithTarget:self
                               selector:@selector(thread_entry)
                                 object:nil];

  // 2. 启动线程
  NSLog(@"thread start .....");
  [_t setName:@"MyThread"];
  [_t start];
}

- (void)thread_entry
{
  /**
   * 打开线程 runloop 三部曲
   */

  // 1. 获取/打开 线程的 runloop
  NSRunLoop *runLoop = [NSRunLoop currentRunLoop];

  // 2. 给 runloop 注册了一个事件源，否则 runloop 会自动退出
  [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];

  // 3. 启动子线程的runloop
  [runLoop run];

  // 4.
  NSLog(@"runloop finished run .....");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//   waitUntilDone:YES 会崩溃
//  [self performSelector:@selector(doWork)
//               onThread:_t
//             withObject:nil
//          waitUntilDone:YES];

  // waitUntilDone:NO 正常
  [self performSelector:@selector(doWork)
               onThread:_t
             withObject:nil
          waitUntilDone:NO];
}

- (void)doWork {
  NSLog(@"[MyThread doWork: %p] %@", [NSThread currentThread], [NSThread currentThread]);

  // 尝试 取消、释放 线程对象
  // 1. 尝试结束线程的 runloop , 但是这样能取消 runloop ???
  CFRunLoopStop(CFRunLoopGetCurrent());
  // 2. 尝试取消线程执行 , 获取能取消执行
  [_t cancel];
  // 3. 尝试释放线程对象 , 这里能释放掉 ???
  _t = nil;
}

@end
```

程序运行起来后的输出

```
2019-12-14 18:15:50.308163+0800 Haha[12848:765812] thread start .....
```

点击N次的输出

```
2019-12-14 18:16:16.916509+0800 Haha[12848:765968] [MyThread doWork: 0x60000222d080] <MyThread - 0x60000222d080>:
	isExecuting = 1,
	isCancelled = 0,
	isFinished = 0
```

- 不管你点击多少次，只会有这一次输出
- 而且关键是没有看到 **-[MyThread dealloc]** 方法的打印
- 所以只要不退出进程，这个线程对象，根本是 **没有机会** 去释放、废弃的

## 6. `+[NSRunLoop run]`

### 1. Foundation 提供 3 种 打开线程 runloop

```objective-c
@interface NSRunLoop (NSRunLoopConveniences)

- (void)run;
- (void)runUntilDate:(NSDate *)limitDate;
- (BOOL)runMode:(NSRunLoopMode)mode beforeDate:(NSDate *)limitDate;

@end
```

### 2. `+[NSRunLoop run]`

```objective-c
#import "ViewController.h"

@interface MyThread : NSThread
@end
@implementation MyThread
- (void)dealloc {
  NSLog(@"MyThread dealloc >>>> %@", self);
}
- (NSString *)description {
  return [NSString stringWithFormat:@"<%@ - %p>: isExecuting = %d, isCancelled = %d, isFinished = %d", [self class], self, self.isExecuting, self.isCancelled, self.isFinished];
}
- (NSString *)debugDescription {
  return [self description];
}
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  // 局部thread对象
  MyThread *t = [[MyThread alloc] initWithTarget:self
                                        selector:@selector(doInitThread)
                                          object:nil];

  // 启动线程
  [t start];
}

- (void)doInitThread
{
  // 1、
  NSThread *t = [NSThread currentThread];
  [t setName:@"MyThread"];

  // 2、
  NSRunLoop *runloop = [NSRunLoop currentRunLoop];
  NSLog(@"doInitThread >>>> 添加port事件之前");

  // 3、【重要】 注释下面这句添加事件源的代码
  [RUNLOOP ADDPORT:[NSMACHPORT PORT] FORMODE:NSDEFAULTRUNLOOPMODE];
  NSLOG(@"DOINITTHREAD >>>> 添加PORT事件之后, RUNLOOP还未开启");

  /**
   * 4、启动 runloop
   * -------------------------------------------------------------------
   * - 1) -[NSRunLoop run] 内部开启【do-while 循环】执行 -[NSRunLoop runMode:beforeDate:]，
   * - 2) 导致当前线程的【runloop 永远不会被退出】，
   * - 3) 即使执行 CFRunLoopStop()，也【无法停止】runloop
   *  - 3.1) CFRunLoopStop() 只是停止 -[NSRunLoop run] 内部开启的【do-while 循环】中的【当前】正在运行的【一次】执行
   *  - 3.2) 但是[do-while 循环】又会在【下一次】循环执行时，【重新启动】一个【新的】runloop
   */
  [runloop run];
  NSLog(@"doInitThread >>>> runlop开始执行");
}

@end
```

- 不管点击屏幕多少次，时钟 **看不到** 线程 **废弃** 的打印消息
- 必须先能够停止运行 runloop，才能够释放掉线程对象
- 因为 runloop 会 **强引用**  线程对象 , 防止 线程对象 被释放、废弃
- 所以上例执行的 **CFRunLoopStop(CFRunLoopGetCurrent());** 根本就 **无法停止 runloop**
- 至于为什么无法停止 runloop , 这里简单的提一下, 深入的话就要聊到 **CFRunLoopRun()** 具体实现了
- 主要是因为  `+[NSRunLoop run]` 调用的 runloop 底层实现函数中, 有一段 **do { … } while(条件)** 主逻辑
- 这样的话, stop 只是 **关掉了当前运行的一次 runloop** , 但是马上又会 **重新执行 do { … }** 又开启了一次新的 runloop

到这里，NSThread 基本了解的差不多了，更深入的就需要往 **RunLoop** 刨了，就不属于多线程的范畴了。

