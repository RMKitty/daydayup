[TOC]



## 1. NSRecursiveLock 

```c
pthread_mutexattr_init(&attr_recursive);
pthread_mutexattr_settype(&attr_recursive, PTHREAD_MUTEX_RECURSIVE); // 递归锁
```

- 基本上与 NSLock 一致
- 只是 `PTHREAD_MUTEX_RECURSIVE` 类型的 **pthread_mutext_t** 实例
- 核心区别是使用的【递归锁】类型，当【重复加锁】时【不会】导致【线程死锁】



## 2. NSRecursiveLock 【重复加锁】【不会】导致【线程死锁】

```objective-c
#import "ViewController.h"

@implementation ViewController {
  NSRecursiveLock *_lock;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  _lock = [[NSRecursiveLock alloc] init]; // 一旦将换成【NSLock】就会导致线程死锁
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  NSLog(@"1");
  [_lock lock];
  [_lock lock];
  [_lock lock];
  [_lock lock];
  NSLog(@"2");
  [_lock unlock];
  NSLog(@"3");
}

@end
```

```
2019-02-27 16:39:03.320317+0800 app[10431:264764] 1
2019-02-27 16:39:03.320434+0800 app[10431:264764] 2
2019-02-27 16:39:03.320513+0800 app[10431:264764] 3
```