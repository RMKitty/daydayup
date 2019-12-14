[TOC]



## 1. 涉及到的 API

### 1. 同步 ==多个 queue==

#### 1. 一步到位

```c
dispatch_group_async(group, queue, block)
```

#### 2. 手动 +1 和 -1

```c
dispatch_group_enter(group) // +1 queue
```

```c
dispatch_group_leave(group) // -1 queue
```

### 2. 当所有队列完成时的 ==统一回调==

```c
dispatch_group_notify()
```

### 3. 设置 ==等待== group 内的 队列完成

```c
dispatch_group_wait()
```



## 2. dispatch_group_notify ==多个队列== 全部完成时, ==统一回调==

### 1. dispatch_group_async

等待多个queue种的任务全部完成后，再最后执行一个任务：

```c
#import "ViewController.h"

@implementation ViewController {
  dispatch_group_t group;
  dispatch_queue_t queue1;
  dispatch_queue_t queue2;
  dispatch_queue_t queue3;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // 组
  group = dispatch_group_create();

  // 3个 队列
  queue1 = dispatch_get_global_queue(0, 0); 	// default 
  queue2 = dispatch_get_global_queue(2, 0);		// high
  queue3 = dispatch_get_global_queue(-2, 0);	// backgroud
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  //1.
  NSLog(@"1");
  
  //2. 向三个不同的队列中传入异步任务
  dispatch_group_async(group, queue1, ^{
    NSLog(@"任务1: %@", [NSThread currentThread]);
  });
  
  dispatch_group_async(group, queue2, ^{
    NSLog(@"任务2: %@", [NSThread currentThread]);
  });
  
  dispatch_group_async(group, queue3, ^{
    NSLog(@"任务3: %@", [NSThread currentThread]);
  });

  //3.
  NSLog(@"2");

  //4. 等待三个队列中任务都完成的时候执行点事情
  dispatch_group_notify(group, dispatch_get_main_queue(), ^{
    NSLog(@"组执行完毕");
  });
  
  //5.
  NSLog(@"3");
}

@end
```

```
2017-09-12 20:29:05.022 Demo[3075:61855] 1
2017-09-12 20:29:05.023 Demo[3075:61855] 2
2017-09-12 20:29:05.023 Demo[3075:61893] 任务2: <NSThread: 0x7fed3167bba0>{number = 2, name = (null)}
2017-09-12 20:29:05.023 Demo[3075:61855] 3
2017-09-12 20:29:05.023 Demo[3075:61895] 任务1: <NSThread: 0x7fed3150c560>{number = 3, name = (null)}
2017-09-12 20:29:05.024 Demo[3075:61998] 任务3: <NSThread: 0x7fed31715c90>{number = 4, name = (null)}
2017-09-12 20:29:05.024 Demo[3075:61855] 组执行完毕
```

- 1、三个不同的 queue，在不同的 **子线程** 上，调度执行 block 任务
- 2、等待三个不同的 queue 调度任务 执行完毕，最后执行 `dispatch_group_notify()` 代码块
- 3、`dispatch_group_notify()` 代码块
  - 1）在 **main** queue 上执行
  - 2）block 是 **异步** 执行

### 2. dispatch_group_enter + dispatch_async + dispatch_group_level

- 1）dispatch_group_**enter()**：通知 group，已经 **加入** 1个新的任务，**+1**
- 2）dispatch_group_**leave()**：通知 group，已经 **完成** 1个存在任务，**-1**
- 3）当任务计数器值 == **0**：dispatch_group_**notify()** 设置的 **block** 被回调执行

```c
@implementation ViewController
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  // 创建group
  dispatch_group_t group = dispatch_group_create();
  
#if 1
  dispatch_group_enter(group); // 任务加入group
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    NSLog(@"task 1");
    dispatch_group_leave(group); // 任务从group移除
  });
  
  dispatch_group_enter(group); // 任务加入group
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    NSLog(@"task 2");
    dispatch_group_leave(group); // 任务从group移除
  });
  
  dispatch_group_enter(group); // 任务加入group
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    NSLog(@"task 3");
    dispatch_group_leave(group); // 任务从group移除
  });

  // 所有任务完成时统一回调
  dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
    NSLog(@"all task done");
  });

#else

  // 效果同上使用 dispatch_group_enter(group); 与 dispatch_group_leave(group);
  dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSLog(@"task 1");
  });
  
  dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSLog(@"task 2");
  });
  
  dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSLog(@"task 3");
  });
  
  dispatch_group_notify(group, dispatch_get_main_queue(), ^{
    NSLog(@"all task done");
  });
  
#endif
  
}
@end
```

```
2018-06-09 15:56:11.527 Test[3466:44588] task 1
2018-06-09 15:56:11.527 Test[3466:44592] task 2
2018-06-09 15:56:11.527 Test[3466:44591] task 3
2018-06-09 15:56:11.528 Test[3466:42625] all task done
2018-06-09 15:56:11.709 Test[3466:44588] task 2
2018-06-09 15:56:11.709 Test[3466:44591] task 1
2018-06-09 15:56:11.710 Test[3466:44597] task 3
2018-06-09 15:56:11.710 Test[3466:42625] all task done
```


### 3. 如上两种方式是等价

#### 1. dispatch_group_async()

```c
dispatch_group_async(group, queue, ^{
  NSLog(@"task 3");
});
```

#### 2. dispatch_group_enter() + dispatch_group_leave()

```c
dispatch_group_enter(group); // 任务加入group
dispatch_async(dispatch_get_global_queue(0, 0), ^{
  NSLog(@"task 3");
  dispatch_group_leave(group); // 任务从group移除
});
```



## 3. dispatch_group_wait ==同步等待== 组内 ==所有队列== 执行完毕

```c
#import "ViewController.h"

@implementation ViewController {
  dispatch_group_t group;
  dispatch_queue_t queue1;
  dispatch_queue_t queue2;
  dispatch_queue_t queue3;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  group = dispatch_group_create();
  queue1 = dispatch_get_global_queue(0, 0);
  queue2 = dispatch_get_global_queue(2, 0);
  queue3 = dispatch_get_global_queue(-2, 0);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  //1. 分配三个无序的队列任务
  dispatch_group_async(group, queue1, ^{
    NSLog(@"任务1: %@", [NSThread currentThread]);
  });
  
  dispatch_group_async(group, queue2, ^{
    NSLog(@"任务2: %@", [NSThread currentThread]);
  });
  
  dispatch_group_async(group, queue3, ^{
    NSLog(@"任务3: %@", [NSThread currentThread]);
  });
  
  //2. 阻塞在此，同步等待上面的任务全部完成
  dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
  NSLog(@"---------------- dispatch_group_wait() ------------------");
  
  //3. 当所有的queue调度执行完毕之后，再继续分配一个异步任务
  dispatch_group_async(group, queue1, ^{
    NSLog(@"任务4: %@", [NSThread currentThread]);
  });
  
  dispatch_group_async(group, queue2, ^{
    NSLog(@"任务5: %@", [NSThread currentThread]);
  });
  
  dispatch_group_async(group, queue3, ^{
    NSLog(@"任务6: %@", [NSThread currentThread]);
  });
  
  //5. 设置最后一定执行的任务
  dispatch_group_notify(group, dispatch_get_main_queue(), ^{
    NSLog(@"---------------- dispatch_group_notify() ------------------");
  });
}

@end
```

```
2018-06-15 17:55:33.851 Test[15313:934952] 任务2: <NSThread: 0x7fba71f2c7c0>{number = 5, name = (null)}
2018-06-15 17:55:33.851 Test[15313:934767] 任务1: <NSThread: 0x7fba71f23f70>{number = 3, name = (null)}
2018-06-15 17:55:33.852 Test[15313:935142] 任务3: <NSThread: 0x7fba71f01b30>{number = 6, name = (null)}
2018-06-15 17:55:33.852 Test[15313:934240] ---------------- dispatch_group_wait() ------------------
2018-06-15 17:55:33.852 Test[15313:934767] 任务5: <NSThread: 0x7fba71f23f70>{number = 3, name = (null)}
2018-06-15 17:55:33.852 Test[15313:935142] 任务4: <NSThread: 0x7fba71f01b30>{number = 6, name = (null)}
2018-06-15 17:55:33.853 Test[15313:934952] 任务6: <NSThread: 0x7fba71f2c7c0>{number = 5, name = (null)}
2018-06-15 17:55:33.853 Test[15313:934240] ---------------- dispatch_group_notify() ------------------
```

- 1）【任务 1、2、3】并发无序执行
- 2）等待【任务 1、2、3】全部执行完毕
- 2）再开始执行【任务 4、5、6】并发无序执行



## 4. 并发先执 a、b, 最后执行 c

```c
dispatch_group_t group = dispatch_group_create();

dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
  //事件a
});

dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
  //事件b
});

dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
  //事件c
});
```