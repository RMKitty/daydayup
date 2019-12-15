[TOC]



## 1. GNUStep NSCondition 源码


```c
@implementation NSCondition

MDEALLOC
MDESCRIPTION

- (void) finalize
{
  pthread_cond_destroy(&_condition);
  pthread_mutex_destroy(&_mutex);
}

- (id) init
{
  if (nil != (self = [super init]))
  {
    if (0 != pthread_cond_init(&_condition, NULL)) // condition
    {
      DESTROY(self);
    }
    else if (0 != pthread_mutex_init(&_mutex, &attr_reporting)) // 普通 mutex 
    {
      pthread_cond_destroy(&_condition);
      DESTROY(self);
    }
  }
  return self;
}

- (void) signal
{
  pthread_cond_signal(&_condition);
}

- (void) broadcast
{
  pthread_cond_broadcast(&_condition);
}

- (void) wait
{
  pthread_cond_wait(&_condition, &_mutex);
}

- (BOOL) waitUntilDate: (NSDate*)limit
{
  NSTimeInterval t = [limit timeIntervalSince1970];
  double secs, subsecs;
  struct timespec timeout;
  int retVal = 0;

  // Split the float into seconds and fractions of a second
  subsecs = modf(t, &secs);
  timeout.tv_sec = secs;
  // Convert fractions of a second to nanoseconds
  timeout.tv_nsec = subsecs * 1e9;

  retVal = pthread_cond_timedwait(&_condition, &_mutex, &timeout);

  if (retVal == 0)
  {
    return YES;
  }
  else if (retVal == EINVAL)
  {
    NSLog(@"Invalid arguments to pthread_cond_timedwait");
  }

  return NO;
}

@end
```

- NSCondition 结构
  - 对 **pthread condtion** 的 api 封装
  - 提供 **signal** 和 **wait** 的线程通信
- 使用 **Default** 普通版本的 **pthread_mutex_t 互斥锁**
  
- wait 完成的事情
  - 挂起休眠线程，等到 condtion 信号，并且会释放 mutex 互斥锁
  - 当 signal 信号发送被唤醒时，又会 重新获取 mutex 互斥锁
  
- signal 只会发送 condtion 信号，唤醒执行 wait 被挂起的 线程

- 既提供了线程间的 **生产者与消费者** 的通信，也同时通过 mutex 普通锁 完成 **互斥**



## 2. 实现 生产者 与 消费者

```c
@interface NSConditionDemo()
@property (strong, nonatomic) NSCondition *condition;
@property (strong, nonatomic) NSMutableArray *data;
@end

@implementation NSConditionDemo

- (instancetype)init
{
  if (self = [super init]) {
    self.condition = [[NSCondition alloc] init];
    self.data = [NSMutableArray array];
  }
  return self;
}

- (void)otherTest
{
  // 两个线程
  [[[NSThread alloc] initWithTarget:self selector:@selector(remove) object:nil] start];
  [[[NSThread alloc] initWithTarget:self selector:@selector(add) object:nil] start];
}

// 生产者-消费者模式

// 线程1
// 删除数组中的元素
- (void)remove
{
  // 1、lock
  [self.condition lock];  
  
  // 2、wait
  for (; self.data.count == 0 ;) 
  {
    [self.condition wait];
  }
  
  // 3、读写临界区
  [self.data removeLastObject]; 
  
  // 4、unlock
  [self.condition unlock]; 
}

// 线程2
// 往数组中添加元素
- (void)add
{
  // 1、lock
  [self.condition lock]; 

  // 2、读写临界区
  sleep(1);
  [self.data addObject:@"Test"]; 
  
  // 3、signal
  [self.condition signal]; // signal 1人
  // [self.condition broadcast]; // signal 所有人

  // 4、unlock
  [self.condition unlock];
}
@end
```

- 1、mutex：控制多线程的【互斥】按照顺序执行
  - 1）lock
  - 2）unlock

- 2、condition：控制多线程之间的【同步协作】通知
  - 1）wait
  - 2）signal