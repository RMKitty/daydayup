[TOC]



## 1. 多个队列 ==组合== 成 一个队列

- 不管被组合的队列，是 串行队列 or 并发队列
- 都可组合到 **一个串行队列** 中，从而 **串行** 执行

```objc
//1. 修饰变量值不能改变、指向也不能改变
static const void* const kContext = &kContext;

@implementation ViewController {
  //1. 组织 其他所有串行队列的 最终串行队列
  dispatch_queue_t targetQueue;
  
  //2. 其他的待组合的子队列
  dispatch_queue_t queue1;
  dispatch_queue_t queue2;
  dispatch_queue_t queue3;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  //1. target queue 是串行的
  targetQueue = dispatch_queue_create("test.target.queue", DISPATCH_QUEUE_SERIAL);
  
  //2. 子队列随便是【串行】还是【并发】都可以
  queue1 = dispatch_queue_create("test.1", DISPATCH_QUEUE_SERIAL);
  queue2 = dispatch_queue_create("test.2", DISPATCH_QUEUE_CONCURRENT);
  queue3 = dispatch_queue_create("test.3", DISPATCH_QUEUE_CONCURRENT);
  
  //3. 将queue1、queue2、queue3，组织到 targetQueue 中【串行】执行
  dispatch_set_target_queue(queue1, targetQueue);
  dispatch_set_target_queue(queue2, targetQueue);
  dispatch_set_target_queue(queue3, targetQueue);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  dispatch_async(queue1, ^{
    NSLog(@"1 in");
    NSLog(@"thread = %@\n", [NSThread currentThread]);
    NSLog(@"1 out");
  });

  dispatch_async(queue2, ^{
    NSLog(@"2 in");
    NSLog(@"thread = %@\n", [NSThread currentThread]);
    NSLog(@"2 out");
  });

  dispatch_async(queue2, ^{
    NSLog(@"3 in");
    NSLog(@"thread = %@\n", [NSThread currentThread]);
    NSLog(@"3 out");
  });

  dispatch_async(queue3, ^{
    NSLog(@"4 in");
    NSLog(@"thread = %@\n", [NSThread currentThread]);
    NSLog(@"4 out");
  });

  dispatch_async(queue3, ^{
    NSLog(@"5 in");
    NSLog(@"thread = %@\n", [NSThread currentThread]);
    NSLog(@"5 out");
  });
}

@end
```

```
2017-09-12 21:05:32.131 Demo[3941:84585] 1 in
2017-09-12 21:05:32.131 Demo[3941:84585] thread = <NSThread: 0x7ff14251dfb0>{number = 3, name = (null)}
2017-09-12 21:05:32.131 Demo[3941:84585] 1 out
2017-09-12 21:05:32.132 Demo[3941:84585] 2 in
2017-09-12 21:05:32.132 Demo[3941:84585] thread = <NSThread: 0x7ff14251dfb0>{number = 3, name = (null)}
2017-09-12 21:05:32.132 Demo[3941:84585] 2 out
2017-09-12 21:05:32.132 Demo[3941:84585] 3 in
2017-09-12 21:05:32.132 Demo[3941:84585] thread = <NSThread: 0x7ff14251dfb0>{number = 3, name = (null)}
2017-09-12 21:05:32.133 Demo[3941:84585] 3 out
2017-09-12 21:05:32.133 Demo[3941:84585] 4 in
2017-09-12 21:05:32.133 Demo[3941:84585] thread = <NSThread: 0x7ff14251dfb0>{number = 3, name = (null)}
2017-09-12 21:05:32.133 Demo[3941:84585] 4 out
2017-09-12 21:05:32.133 Demo[3941:84585] 5 in
2017-09-12 21:05:32.134 Demo[3941:84585] thread = <NSThread: 0x7ff14251dfb0>{number = 3, name = (null)}
2017-09-12 21:05:32.134 Demo[3941:84585] 5 out

```

可以看到，无论 **串行** or **并发** 队列，最终都是按照 **串行** 进行调度。



## 2. ==复制== 队列的 ==优先级==

- iOS8 以前, 无法直接 **指定队列的优先级**
- 必须先 **创建** 出一个 具备你要指定的优先级的 **系统队列**
- 然后将 **系统队列** 的优先级 **复制** 给创建的队列

```objc
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  //1. 自己创建的队列
  dispatch_queue_t serialQueue = dispatch_queue_create("队列名字",NULL);
  
  //2. 获取要复制优先级对应的系统队列
  dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0);
  
  //3. 将【第二个队列】的优先级【复制】给【第一个队列】
  dispatch_set_target_queue(serialQueue, globalQueue);
}
```



## 3. iOS8 创建队列, 可直接使用 qos 指定 队列的 优先级

```objc
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  //1. 指定队列的服务质量
  dispatch_queue_attr_t queue_attr;
  queue_attr = dispatch_queue_attr_make_with_qos_class(
    DISPATCH_QUEUE_SERIAL, // 队列类型 
    QOS_CLASS_UTILITY,     // qos 指定队列的优先级
    -1                     // 默认值 -1
  );

  //2. 创建队列时，传入设置的服务质量
  dispatch_queue_t queue = dispatch_queue_create(
    "queue name", 
    queue_attr // 队列的【权限属性】
  );
}
```

