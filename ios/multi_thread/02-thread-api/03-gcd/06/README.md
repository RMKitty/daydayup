[TOC]



## 1. dispatch_source_t 基于「内核」的事件

```
DISPATCH_SOURCE_TYPE_DATA_ADD   变量增加
DISPATCH_SOURCE_TYPE_DATA_OR    变量OR
DISPATCH_SOURCE_TYPE_MACH_SEND  Mach端口发送
DISPATCH_SOURCE_TYPE_MACH_RECV  Mach端口接收
DISPATCH_SOURCE_TYPE_MEMORYPRESSURE 内存压力情况变化
DISPATCH_SOURCE_TYPE_PROC       与进程相关的事件
DISPATCH_SOURCE_TYPE_READ       可读取文件映像
DISPATCH_SOURCE_TYPE_SIGNAL     接收信号
DISPATCH_SOURCE_TYPE_TIMER      定时器事件
DISPATCH_SOURCE_TYPE_VNODE      文件系统变更
DISPATCH_SOURCE_TYPE_WRITE      可写入文件映像
```

主要分为如下6类

```
1. Timer Dispatch Source：定时调度源。
2. Signal Dispatch Source：监听UNIX信号调度源，比如监听代表挂起指令的 SIGSTOP信号。
3. Descriptor Dispatch Source：监听文件相关操作和Socket相关操作的调度源。
4. Process Dispatch Source：监听进程相关状态的调度源。
5. Mach port Dispatch Source：监听Mach相关事件的调度源。
6. Custom Dispatch Source：监听自定义事件的调度源。
```



## 2. 「timer 定时器」事件

```objective-c
#import "ViewController.h"

@implementation ViewController {
  dispatch_queue_t queue;
  dispatch_source_t timer;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  queue = dispatch_get_main_queue();
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  // 1. 创建 source
  timer = dispatch_source_create(
    DISPATCH_SOURCE_TYPE_TIMER, // timer 类型的 gcd dispatch source
    0, 
    0, 
    queue // 指定回调执行的 gcd queue
  );
  
  // 2. 开始时间
  dispatch_time_t start = dispatch_time(
    DISPATCH_TIME_NOW, 
    0 * NSEC_PER_SEC
  );
  
  // 3. 时间间隔
  uint64_t interval = 2 * NSEC_PER_SEC;
  
  // 4. 设置gcd timer的开始时间、时间间隔
  dispatch_source_set_timer(
    timer, 		// source
    start,  	// 开始 - 触发的时间
    interval, // 间隔 - 触发的时间
    0
  );
  
  // 5. 设置 gcd timer 的回调代码块
  dispatch_source_set_event_handler(timer, ^{
    NSLog(@"%@", [NSThread currentThread]);
  });
  
  // 6. 启动 gcd timer
  dispatch_resume(timer);

  // 7. 不再使用时取消删除gcd timer
  dispatch_source_cancel(timer);
  
  // 8. 释放掉 timer 对象的内存
  timer = nil;
}

@end
```

每隔2秒打印输出

```
2017-09-12 20:38:52.441 Demo[3298:67939] <NSThread: 0x7ffe4b504670>{number = 1, name = main}
2017-09-12 20:38:54.446 Demo[3298:67939] <NSThread: 0x7ffe4b504670>{number = 1, name = main}
2017-09-12 20:38:56.446 Demo[3298:67939] <NSThread: 0x7ffe4b504670>{number = 1, name = main}
2017-09-12 20:38:58.441 Demo[3298:67939] <NSThread: 0x7ffe4b504670>{number = 1, name = main}
2017-09-12 20:39:00.444 Demo[3298:67939] <NSThread: 0x7ffe4b504670>{number = 1, name = main}
...............
```



## 3. 创建 dispatch source 

```c
dispatch_source_t dispatch_source_create(
  dispatch_source_type_t type, // (1)
  uintptr_t handle,	// (2)
  unsigned long mask,	// (3)
  dispatch_queue_t queue	// (4)
);	
```

type：第一个参数用于标识Dispatch Source要监听的事件类型，共有11个类型。

handle：第二个参数是取决于要监听的事件类型。比如：

- (1) 如果是监听 `Mach端口` 相关的事件，那么该参数就是 `mach_port_t` 类型的 `Mach端口号`
- (2) 其他一般情况下，设置为 `0` 就可以了

mask：第三个参数同样取决于要监听的事件类型。比如如果是监听 `文件属性更改` 的事件，那么该参数就标识 `文件的哪个属性`，比如 `DISPATCH_VNODE_RENAME`。

queue：第四个参数设置回调函数所在的队列。



## 4. 获取创建的 disaptch source 的 type 值

```c
uintptr_t
dispatch_source_get_handle(dispatch_source_t source);
```

返回值如下

```
 *  DISPATCH_SOURCE_TYPE_DATA_ADD:        n/a
 *  DISPATCH_SOURCE_TYPE_DATA_OR:         n/a
 *  DISPATCH_SOURCE_TYPE_MACH_SEND:       mach port (mach_port_t)
 *  DISPATCH_SOURCE_TYPE_MACH_RECV:       mach port (mach_port_t)
 *  DISPATCH_SOURCE_TYPE_MEMORYPRESSURE   n/a
 *  DISPATCH_SOURCE_TYPE_PROC:            process identifier (pid_t)
 *  DISPATCH_SOURCE_TYPE_READ:            file descriptor (int)
 *  DISPATCH_SOURCE_TYPE_SIGNAL:          signal number (int)
 *  DISPATCH_SOURCE_TYPE_TIMER:           n/a
 *  DISPATCH_SOURCE_TYPE_VNODE:           file descriptor (int)
 *  DISPATCH_SOURCE_TYPE_WRITE:           file descriptor (int)
```



## 5. 设置 dipatch source 被「取消时」的回调

```c
void
dispatch_source_set_cancel_handler(
  dispatch_source_t source,
  dispatch_block_t handler
);
```

