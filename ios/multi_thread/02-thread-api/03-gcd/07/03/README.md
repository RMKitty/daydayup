[TOC]



## 1. 直接缓存 NSThread 对象是不行的，必须经过如下步骤

- 1、给 thread 获取一个 **RunLoop**
- 2、向 runloop 添加 **RunLoopSource**
- 3、开启 thread 的 runloop
  - 1）这样才能保证 thread 一直处于 **executing** 状态
  - 2）只有处于 **executing** 状态的线程，也才能接受任务执行
- 4、在线程退出时，必须首先 **stop runloop**，线程才能释放

这还是略显麻烦了，而且苹果已经提供了 `dispatch_queue_t` 这么高级的 API 了，何必再走原始的路了 ....。



## 2. 转向缓存 `dispatch_queue_t` 实例，相对就简单多了

- 1、初始时，创建多个 `dispatch_queue_t` 对象，并缓存到内存中
- 2、想用的时候取出 `dispatch_queue_t` 实例
- 3、直接 `dispatch_async()` 即可分配线程任务



## 3. 测试缓存 `dispatch_queue_t` 实例的任务调度情况

```c
#import "ViewController.h"
#import <pthread.h>
#import <semaphore.h>

/**
 *  保存dispatch_queue_t实例的容器
 */
struct dispatch_queue_context
{
  void **queues; // void* arr[] 指针数组
};

/**
 *  全局的 dispatch_queue_context 对象
 */
static struct dispatch_queue_context context;

/**
 *  创建 dispatch_queue_t 对象的缓存
 */
static void queue_pool_create()
{
  //1. 给 context.queues 分配【指向】的连续内存，即 5个 void* 内存长度
  context.queues = malloc(sizeof(void*) * 5);
  
  //2. 继续分配 context.queues[i] 指向的 内存块
  for (int i = 0; i < 5; i++) 
  {
    //2.1 临时内存 queue 对象
    dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
    
    //2.2 context.queues[i] 指向分配的内存块
    // 注意：一定要 retain一下 queue，
    // 因为【void*】是 c 类型, 无法持有 objc 对象
    // 就会直接就 free 掉了
    context.queues[i] = (__bridge_retained void*)(queue);
  } // 超出作用域，局部queue指针不再持有局部的queue实例内存
}

/**
 *  废弃 dispatch_queue_t 对象的缓存
 */
static void queue_pool_free()
{
  // 1. 依次释放 context.queues[i] 存储的 dispatch_queue_t实例内存
  for (int i = 0; i < 5; i++) 
  {
    // 1.1 release
    dispatch_queue_t queue = (__bridge_transfer dispatch_queue_t)context.queues[i];
    
    // 1.2 为了 不报警告 而已
    NSLog(@"queue: %@", queue);
    
    // 1.3 不要做如下步骤了
    // 因为上面 1.1 已经完成了 free(context.queues[i]) 内存废弃 的操作
    // 再执行下面的 free() 就会造成 重复释放 野指针, 导致程序崩溃
    // free(context.queues[i]);
  }
  
  // 2. 释放 context.queues[i] 数组的堆区内存
  free(context.queues);
}

@implementation ViewController

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  // 1.
  queue_pool_create();

  // 2. 从 context 中取出 queue
  for (int i = 0; i < 5; i++)
  {
    // 2.1 从缓存中取出 queue 对象，注意此处只做类型转换，不做 retain/release
    dispatch_queue_t queue = (__bridge dispatch_queue_t)(context.queues[i]);
    
    // 2.2 给缓存 queue 提交任务
    dispatch_async(queue, ^{
      NSThread *t = [NSThread currentThread];
      NSLog(@"线程状态: isCanceled=%d, isExecuting=%d, isFinish=%d", t.isCancelled, t.isExecuting, t.isFinished);
    });
  }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  queue_pool_free();
}

@end
```

运行输出

```
2017-09-13 00:12:45.706 Demo[3112:54896] 线程状态: isCanceled=0, isExecuting=1, isFinish=0
2017-09-13 00:12:45.706 Demo[3112:54895] 线程状态: isCanceled=0, isExecuting=1, isFinish=0
2017-09-13 00:12:45.706 Demo[3112:54897] 线程状态: isCanceled=0, isExecuting=1, isFinish=0
2017-09-13 00:12:45.706 Demo[3112:54899] 线程状态: isCanceled=0, isExecuting=1, isFinish=0
2017-09-13 00:12:45.706 Demo[3112:54900] 线程状态: isCanceled=0, isExecuting=1, isFinish=0
```

线程状态一直是`isExecuting=1`，表明线程一直是存活的。且运行正常，说明长期缓存`dispatch_queue_t`实例是可行的。

