[TOC]



## 1. dispatch_semaphore_t ==值==

### 1. semephore == 1

- 一个时刻只能有 **一个线程** 读写公共区
- 就是普通的 **互斥锁**

### 2. semephore > 1

- 一个时刻可以并发 **n个线程** 读写公共区

- **临界区** 仍然需要单独做 **线程安全** 处理
  - **临界区** 同时会进入多个角色，
  - 所以仍然需要 **手动互斥**

- 生产者与消费者
  - 消费者: **semephore - 1**
  - 生产者: **semephore + 1**


### 3. semephore == 0

- 当前线程会被 **挂起**
- 只有 **等待唤醒** 之后，才能继续执行



## 2. 信号值【大于1】时, 可【并发多个线程】进入临界区

- 1、semephore = n：控制同时并发多个线程进入临界区
- 2、pthread_mutext_t：临界区内控制多个角色顺序执行

```c
#import "ViewController.h"

#import <dispatch/semaphore.h>
#import <pthread.h>

static dispatch_semaphore_t semaphore;
static pthread_mutex_t mutex;

@implementation ViewController {
  NSString* name;
  int num;
}

+ (void)initialize {
  /**
   *  1. 初始化信号量值为5，
   *  同时并发5个线程访问公共区
   */
  semaphore = dispatch_semaphore_create(5);
  
  /**
   *  2. mutex 互斥量
   *  控制临界区一个时刻，实际上还是只有一个线程读写
   */
  pthread_mutex_init(&mutex, NULL);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  // 临界数据
  num = 0;
  
  // 模拟100个子线程并发访问互斥变量
  for (int i = 0; i <10; i++) {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
      // 1. 进入临界区，信号量 - 1，放一个线程进入临界区
      dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
      
      // 2. 临界数据，仍然需要使用mutex互斥按照顺序【写】操作
      {
        // 2.1 lock()
        pthread_mutex_lock(&mutex);

        // 2.2 读写临界区
        self->num++;
        printf("num = %d\n", self->num);

        // 2.3 unlock()
        pthread_mutex_unlock(&mutex);
      }
      
      // 3. 访问完临界区，信号量 + 1，可以继续进入一个线程
      dispatch_semaphore_signal(semaphore);
    });
  }
}

@end
```

```
num = 1
num = 2
num = 3
num = 4
num = 5
num = 6
num = 7
num = 8
num = 9
num = 10
```

- (1) `semaphore(5)` 同时放入`5`个子线程进来
- (2) `mutex`仍然只让`1`个线程进入临界区读写



## 3. ==异步==方法, 强制 ==同步==执行, 并获取 ==返回值==

### 1. 异步方法

```c
#import "ViewController.h"

@implementation ViewController

- (void)asyncFunc:(void(^)(NSString* name))block {
  dispatch_async(dispatch_get_main_queue(), ^{
    block(@"xzh");
  });
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [self asyncFunc:^(NSString* name) {
    /**
     * 想在【异步方法】执行完之后的代码，
     * 必须包裹在异步回调block代码块中获取回传值
     */
    NSLog(@"name = %@", name);
  }];
}

@end
```

如果希望这个异步方法能偶 **同步** 完成了？

### 2.【错误】【同步化】异步方法

```c
#import "ViewController.h"

@implementation ViewController {
  NSString* _name;
}

- (void)asyncFunc:(void(^)(NSString* name))block {
  dispatch_async(dispatch_get_main_queue(), ^{
    block(@"xzh");
  });
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  // 1. 获取异步方法内的传出值
  __weak ViewController* weakSelf = self;
  [self asyncFunc:^(NSString* name) {
    __strong ViewController* strongSelf = weakSelf;
    strongSelf->_name = @"xzh";
  }];
    
  // 2. 
  NSLog(@"name = %@", _name);
}

@end
```

```
2017-09-12 23:02:40.964 Demo[1348:11802] name = (null)
```

- 1）**无法** 获取得到返回值，
- 2）因为 **异步方法** 不会立刻执行

### 3.【正确】【同步化】异步方法

- 信号值初始为 **0**
- 同步获取值的地方：wait
- 异步方法内：signal

```c
#import "ViewController.h"

static dispatch_semaphore_t semaphore;

@implementation ViewController {
  NSString* _name;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  /**
   *  初始化信号量值为0，让主线程先暂时卡住，等待异步方法执行完毕
   */
  semaphore = dispatch_semaphore_create(0);
}

- (void)asyncFunc:(void(^)(NSString* name))block {
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    block(@"xzh");
  });
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  // 1. 调用异步方法
  __weak ViewController* weakSelf = self;
  [self asyncFunc:^(NSString* name) {
    __strong ViewController* strongSelf = weakSelf;
    
    // 1.1 异步完成的任务代码
    strongSelf->_name = @"xzh";

    // 1.2 异步代码完成时，让信号量值 + 1，通知外界解除阻塞
    dispatch_semaphore_signal(semaphore);
  }];

  // 2.【阻塞当前主线程】等待异步函数执行完毕
  // => 只有信号量值 > 0 才会往下走
  // => 并让 信号量值 - 1
  dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
  // 3. 
  NSLog(@"name = %@", _name);
}

@end
```

```
2017-09-12 23:14:43.330 Demo[1693:20471] name = xzh
```



## 4. memory cache 线程安全处理

```c
#import "ViewController.h"

@interface ClassMapper : NSObject
+ (instancetype)classMapperWithClass:(Class)cls;
@end
@implementation ClassMapper {
  Class _class;
}

+ (instancetype)classMapperWithClass:(Class)cls {
  if (NULL == cls) {return nil;}
  
  // 1. dispatch one 执行 init
  static dispatch_semaphore_t _semephore = NULL;
  static NSMutableDictionary *_cache = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _semephore = dispatch_semaphore_create(1);
    _cache = [NSMutableDictionary new];
  });
  
  // 2. 读缓存加锁同步
  dispatch_semaphore_wait(_semephore, DISPATCH_TIME_FOREVER);
  ClassMapper *mapper = [_cache objectForKey:NSStringFromClass(cls)];
  dispatch_semaphore_signal(_semephore);
  
  // 3. 缓存存在
  if (mapper) {return mapper;}
  
  // 4. 缓存不存在
  mapper = [[ClassMapper alloc] initWithClass:cls];
  dispatch_semaphore_wait(_semephore, DISPATCH_TIME_FOREVER);
  [_cache setObject:mapper forKey:NSStringFromClass(cls)];
  dispatch_semaphore_signal(_semephore);
  
  // 5.
  return mapper;
}

- (instancetype)initWithClass:(Class)cls {
  if (self = [super init]) {
    _class = cls;
  }
  return self;
}

@end

@implementation ViewController {
  ClassMapper* _mapper;
}

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  for (int i=0; i<10; i++) {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
      printf("%p\n", [ClassMapper classMapperWithClass:[self class]]);
    });
  }
}

@end
```

```
0x7ffde2411b90
0x7ffde2411b90
0x7ffde2411b90
0x7ffde2411b90
0x7ffde2411b90
0x7ffde2411b90
0x7ffde2411b90
0x7ffde2411b90
0x7ffde2411b90
0x7ffde2411b90
```

注意 **信号量不要嵌套**，容易产生死锁。



## 5. group wait 等待 ==所有任务== 执行完毕

```c
dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
dispatch_group_t group = dispatch_group_create();
dispatch_semaphore_t semaphore = dispatch_semaphore_create(10); // 一次只有10个坑位

// 同时开启100个任务
for (int i = 0; i < 100; i++) {
  // 进入临界区，减少1个坑位
  dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
  
  // group 组合 async queue 任务
  dispatch_group_async(group, queue, ^{
    NSLog(@"%i",i);
    sleep(2);
    
    // 离开临界区，增加一个坑位
    dispatch_semaphore_signal(semaphore);
  });
}

// 等待所有的 group 任务执行完毕
dispatch_group_wait(group, DISPATCH_TIME_FOREVER);

// 所有任务执行完毕后得处理
// ..........................

// 释放内存
dispatch_release(group);
dispatch_release(semaphore);
```