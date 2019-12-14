[TOC]



## 1. dispatch_get_global_queue(0, 0) 全局并发队列 

```c
#import "ViewController.h"

@implementation ViewController

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  for (int i = 0; i < 10; i++) {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
      NSLog(@"%@", [NSThread currentThread]);
    });
  }
}

@end
```

运行输出

```
2017-09-12 23:45:01.043 Demo[2451:40431] <NSThread: 0x7f817ad07240>{number = 2, name = (null)}
2017-09-12 23:45:01.043 Demo[2451:40435] <NSThread: 0x7f817ac1c7f0>{number = 4, name = (null)}
2017-09-12 23:45:01.043 Demo[2451:40432] <NSThread: 0x7f817adaf910>{number = 3, name = (null)}
2017-09-12 23:45:01.043 Demo[2451:40499] <NSThread: 0x7f817af1b3f0>{number = 5, name = (null)}
2017-09-12 23:45:01.043 Demo[2451:40500] <NSThread: 0x7f817ac0e6a0>{number = 6, name = (null)}
2017-09-12 23:45:01.043 Demo[2451:40431] <NSThread: 0x7f817ad07240>{number = 2, name = (null)}
2017-09-12 23:45:01.043 Demo[2451:40435] <NSThread: 0x7f817ac1c7f0>{number = 4, name = (null)}
2017-09-12 23:45:01.043 Demo[2451:40432] <NSThread: 0x7f817adaf910>{number = 3, name = (null)}
2017-09-12 23:45:01.043 Demo[2451:40499] <NSThread: 0x7f817af1b3f0>{number = 5, name = (null)}
2017-09-12 23:45:01.044 Demo[2451:40501] <NSThread: 0x7f817af139b0>{number = 7, name = (null)}
```

可以看到`concurrent`并发队列，一下子就创建`7`个新的子线程出来，虽然有线程池复用，但仍然创建了接近10个任务数的线程。

试想如果随意的使用global queue来做一些比较耗时的任务，那进程中同一时刻就会有`多个线程`来争夺CPU时间，肯定会降低CPU的效率。



## 2. dispatch_queue_create("queue_nane", concurrent) 手动创建并发队列

- 最好的情况下, 只有一个子线程
- 最差的情况下, N个子线程
- 随时可能线程数爆炸



## 3. 重量级的系统类对象

我亲自测试过, 创建 AVPlayer、AVPlayerLayer 对象时，会创建接近 **30个** gcd queue