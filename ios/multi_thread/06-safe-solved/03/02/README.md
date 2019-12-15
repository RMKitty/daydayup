[TOC]



## 1. atomic : 将多条指令, 强制合并在 ==一个CPU周期== 内完成

```asm
static __inline__ void atomic_add(int i, atomic_t *v)
{
  __asm__ __volatile__(
    LOCK "addl %1, %0"
    :"=m" (v->counter)
    :"ir" (i), "m" (v->counter)
  );
}
```

- 1、LOCK 锁总线
- 2、"addl %1, %0"
- 3、"=m" (v->counter) 内存数据读取到寄存器
- 4、"ir" (i), "m" (v->counter) 变量i内存值读取到寄存器，加到v->count中

所以就是将多条读取内存的操作，打包为一条汇编指令完成。



## 2. 存在 线程安全 的代码

```c
#import "ViewController.h"

@implementation ViewController {
  int index; // 存在【线程安全】的成员变量
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  // 5张票
  index = 5;
  
  // 10个人抢
  __block ViewController* blockSelf = self;
  for (int i = 0; i < 10; i++) {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
      if (index > 0)
      {
        // 模拟卖票耗时
        sleep(1);
        
        // 买到票后，让总票数-1
        NSLog(@"%d", (blockSelf->index)--);
      }
      else
      {
        NSLog(@"没抢到票");
      }
    });
  }
}

@end
```

```
2017-09-13 12:04:07.705 Demo[4760:97515] 1
2017-09-13 12:04:07.705 Demo[4760:97513] 2
2017-09-13 12:04:07.705 Demo[4760:97422] 4
2017-09-13 12:04:07.705 Demo[4760:97421] 5
2017-09-13 12:04:07.705 Demo[4760:97420] 3
2017-09-13 12:04:07.705 Demo[4760:97514] 1
2017-09-13 12:04:07.705 Demo[4760:97516] 0
2017-09-13 12:04:07.705 Demo[4760:97517] -1
2017-09-13 12:04:07.705 Demo[4760:97519] -2
2017-09-13 12:04:07.705 Demo[4760:97518] -2
```

出现了负数，肯定是不正常的。



## 3. `<libkern/OSAtomic.h>` 库函数, 提供 ==原子操作== 读写内存

```c
#import "ViewController.h"
#import <libkern/OSAtomic.h>

@implementation ViewController {
  int index;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  // 5张票
  index = 5;
  
  // 10个人抢
  __block ViewController* blockSelf = self;
  for (int i = 0; i < 10; i++) {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
      /**
       * OSAtomicDecrement32() 原子操作函数，原子操作读写变量关联的内存
       */
      if (OSAtomicDecrement32(&(blockSelf->index)) >= 0)
      {
        sleep(1);
        NSLog(@"买到票");
      }
      else
      {
        NSLog(@"未买到票");
      }
    });
  }
}

@end
```

```
2018-04-13 10:44:44.301 iOS[7291:92026] 未买到票
2018-04-13 10:44:44.301 iOS[7291:92025] 未买到票
2018-04-13 10:44:44.302 iOS[7291:92027] 未买到票
2018-04-13 10:44:44.302 iOS[7291:92025] 未买到票
2018-04-13 10:44:44.302 iOS[7291:92026] 未买到票
2018-04-13 10:44:45.305 iOS[7291:92005] 买到票
2018-04-13 10:44:45.305 iOS[7291:92006] 买到票
2018-04-13 10:44:45.305 iOS[7291:92013] 买到票
2018-04-13 10:44:45.305 iOS[7291:92024] 买到票
2018-04-13 10:44:45.305 iOS[7291:92014] 买到票
```

还有待学习更多深入的 atomic 原子操作函数。