[TOC]



## 1. NSLock 定义

```c
@protocol NSLocking
- (void)lock;
- (void)unlock;
@end

@interface NSLock : NSObject <NSLocking> {
@private
  void *_priv;
}

- (BOOL)tryLock;
- (BOOL)lockBeforeDate:(NSDate *)limit;

@property (nullable, copy) NSString *name NS_AVAILABLE(10_5, 2_0);

@end
```



## 2. lock && unlock

```c
@implementation ViewController {
  NSLock *_lock;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  _lock = [[NSLock alloc] init];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  NSLog(@"1");
  [_lock lock];
  NSLog(@"2");
  [_lock unlock];
  NSLog(@"3");
}
```

```
2019-02-27 16:23:12.644894+0800 app[10037:250464] 1
2019-02-27 16:23:12.645013+0800 app[10037:250464] 2
2019-02-27 16:23:12.645115+0800 app[10037:250464] 3
```



## 3. NSLock 内部使用 `pthread_mutex_t` 

>  GNUStep NSLock 源码实现

### 1. +[NSLock initialize]

```c
static pthread_mutex_t deadlock;
static pthread_mutexattr_t attr_normal;
static pthread_mutexattr_t attr_reporting;
static pthread_mutexattr_t attr_recursive;

NSString *NSLockException = @"NSLockException";

@implementation NSLock

+ (void) initialize
{
  static BOOL	beenHere = NO;

  if (beenHere == NO)
  {
    beenHere = YES;

    /* Initialise attributes for the different types of mutex.
      * We do it once, since attributes can be shared between multiple
      * mutexes.
      * If we had a pthread_mutexattr_t instance for each mutex, we would
      * either have to store it as an ivar of our NSLock (or similar), or
      * we would potentially leak instances as we couldn't destroy them
      * when destroying the NSLock.  I don't know if any implementation
      * of pthreads actually allocates memory when you call the
      * pthread_mutexattr_init function, but they are allowed to do so
      * (and deallocate the memory in pthread_mutexattr_destroy).
      */
    pthread_mutexattr_init(&attr_normal);
    pthread_mutexattr_settype(&attr_normal, PTHREAD_MUTEX_NORMAL);
    pthread_mutexattr_init(&attr_reporting);
    pthread_mutexattr_settype(&attr_reporting, PTHREAD_MUTEX_ERRORCHECK);
    pthread_mutexattr_init(&attr_recursive);
    pthread_mutexattr_settype(&attr_recursive, PTHREAD_MUTEX_RECURSIVE);

    /* To emulate OSX behavior, we need to be able both to detect deadlocks
      * (so we can log them), and also hang the thread when one occurs.
      * the simple way to do that is to set up a locked mutex we can
      * force a deadlock on.
      */
    pthread_mutex_init(&deadlock, &attr_normal);
    pthread_mutex_lock(&deadlock);
  }
}
```

所以 NSLock 就是 `PTHREAD_MUTEX_NORMAL` 类型的 pthread_mutext_t 实例。

    pthread_mutexattr_init(&attr_normal);
    pthread_mutexattr_settype(&attr_normal, PTHREAD_MUTEX_NORMAL);

### 2. -[NSLock dealloc]

```c
#define	MDEALLOC \
- (void) dealloc\
{\
  [self finalize];\
  [_name release];\
  [super dealloc];\
}

#if defined(HAVE_PTHREAD_MUTEX_OWNER)
```

### 3. -[NSLock finalize]

```c
#define MFINALIZE \
- (void) finalize\
{\
  pthread_mutex_destroy(&_mutex);\
}
```

调用 pthread_mutex_destroy() 销毁锁。

### 4. -[NSLock lock]

```c
#define	MLOCK \
- (void) lock\
{\
  int err = pthread_mutex_lock(&_mutex);\
  if (EINVAL == err)\
  {\
    [NSException raise: NSLockException\
    format: @"failed to lock mutex"];\
  }\
  if (EDEADLK == err)\
  {\
    _NSLockError(self, _cmd, YES);\
  }\
}
```

调用 pthread_mutex_lock() 加锁。

### 5. -[NSLock lockBeforeDate:]

```c
#define	MLOCKBEFOREDATE \
- (BOOL) lockBeforeDate: (NSDate*)limit\
{\
  do\
  {\
    int err = pthread_mutex_trylock(&_mutex);\
    if (0 == err)\
    {\
      return YES;\
    }\
    sched_yield();\
  } while ([limit timeIntervalSinceNow] > 0);\
  return NO;\
}
```

- 1）开启 **do{}while()** ，条件为 [limit timeIntervalSinceNow] > 0
- 2）循环内调用 pthread_mutex_trylock() 尝试加锁

### 6. -[NSLock tryLock]

```c
#define	MTRYLOCK \
- (BOOL) tryLock\
{\
  int err = pthread_mutex_trylock(&_mutex);\
  return (0 == err) ? YES : NO;\
}
```

调用 pthread_mutex_trylock() 尝试加锁。

### 7. -[NSLock unlock]

```c
#define	MUNLOCK \
- (void) unlock\
{\
  if (0 != pthread_mutex_unlock(&_mutex))\
  {\
    [NSException raise: NSLockException\
    format: @"failed to unlock mutex"];\
  }\
}
```

调用 pthread_mutex_trylock() 解锁加锁。



## 4. NSLock 【重复加锁】导致【线程死锁】

### 1. 非循环内

```objective-c
@implementation ViewController {
    NSLock *_lock;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _lock = [[NSLock alloc] init];
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

````
2019-02-27 16:24:35.465252+0800 app[10067:252124] 1
2019-02-27 16:24:40.465122+0800 app[10067:252169] XPC connection interrupted
````

- 不会看到输出 **2、3**
- 线程已经被 **死锁**

### 2. 循环内

```objective-c
for ( ; ; ) {
  [_lock lock]; // 一旦此行代码被【重复】执行，也会导致【死锁】，所以必须使用【tryLock】
  
  .....
    
  [_lock unlock];
}
```



## 5. ==for/while 循环内== 必须使用 ==tryLock==

```objective-c
#import "ViewController.h"

@interface Dog : NSObject
@end
@implementation Dog
@end

@implementation ViewController {
  NSMutableDictionary *_dic;
  NSLock *_lock;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  _dic = [NSMutableDictionary new];
  _lock = [[NSLock alloc] init];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  NSLog(@"--- begin ---");
  for (int i=0; i<30; i++) {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
      Dog *dog = [Dog new];
      NSLog(@"--- lock ---");
      if ([_lock tryLock]) {
        // try lock success
        [_dic setObject:dog forKey:@"001"];
        [_lock unlock]; // un lock
        NSLog(@"--- unlock ---");
      } else {
        // try lock failed
        usleep(1000);
        NSLog(@"--- sleep ---");
      }
    });
  }
  NSLog(@"--- end ---");
}

@end
```

```
2019-02-27 16:29:20.208116+0800 app[10299:257822] --- begin ---
2019-02-27 16:29:20.208316+0800 app[10299:257868] --- lock ---
2019-02-27 16:29:20.208323+0800 app[10299:257869] --- lock ---
2019-02-27 16:29:20.208341+0800 app[10299:257870] --- lock ---
2019-02-27 16:29:20.208343+0800 app[10299:257822] --- end ---
2019-02-27 16:29:20.208392+0800 app[10299:257903] --- lock ---
2019-02-27 16:29:20.208440+0800 app[10299:257869] --- unlock ---
2019-02-27 16:29:20.208464+0800 app[10299:257870] --- unlock ---
2019-02-27 16:29:20.208469+0800 app[10299:257961] --- lock ---
2019-02-27 16:29:20.208485+0800 app[10299:257962] --- lock ---
2019-02-27 16:29:20.208504+0800 app[10299:257903] --- unlock ---
2019-02-27 16:29:20.208533+0800 app[10299:257963] --- lock ---
2019-02-27 16:29:20.208548+0800 app[10299:257869] --- lock ---
2019-02-27 16:29:20.208564+0800 app[10299:257964] --- lock ---
2019-02-27 16:29:20.208589+0800 app[10299:257965] --- lock ---
2019-02-27 16:29:20.208629+0800 app[10299:257966] --- lock ---
2019-02-27 16:29:20.208666+0800 app[10299:257967] --- lock ---
2019-02-27 16:29:20.208685+0800 app[10299:257870] --- lock ---
2019-02-27 16:29:20.208720+0800 app[10299:257968] --- lock ---
2019-02-27 16:29:20.208767+0800 app[10299:257969] --- lock ---
2019-02-27 16:29:20.208832+0800 app[10299:257970] --- lock ---
2019-02-27 16:29:20.208856+0800 app[10299:257971] --- lock ---
2019-02-27 16:29:20.208908+0800 app[10299:257972] --- lock ---
2019-02-27 16:29:20.208936+0800 app[10299:257973] --- lock ---
2019-02-27 16:29:20.208981+0800 app[10299:257974] --- lock ---
2019-02-27 16:29:20.208996+0800 app[10299:257962] --- unlock ---
2019-02-27 16:29:20.209021+0800 app[10299:257975] --- lock ---
2019-02-27 16:2019-02-27 16:29:20.209544+0800 app[10299:257966] --- unlock ---
2019-02-27 16:29:20.209328+0800 app[10299:257983] --- lock ---
2019-02-27 16:29:20.209778+0800 app[10299:257964] --- unlock ---
2019-02-27 16:29:20.210068+0800 app[10299:257869] --- unlock ---
2019-02-27 16:29:20.210763+0800 app[10299:257973] --- unlock ---
2019-02-27 16:29:20.210908+0800 app[10299:257965] --- unlock ---
2019-02-27 16:29:20.211039+0800 app[10299:257963] --- unlock ---
2019-02-27 16:29:20.211141+0800 app[10299:257974] --- unlock ---
2019-02-27 16:29:20.211345+0800 app[10299:257972] --- unlock ---
2019-02-27 16:29:20.211533+0800 app[10299:257968] --- unlock ---
2019-02-27 16:29:20.211424+0800 app[10299:257969] --- unlock ---
2019-02-27 16:29:20.211624+0800 app[10299:257971] --- unlock ---
2019-02-27 16:29:20.211717+0800 app[10299:257870] --- unlock ---
2019-02-27 16:29:20.211792+0800 app[10299:257970] --- unlock ---
2019-02-27 16:29:20.211878+0800 app[10299:257967] --- unlock ---
29:20.209055+0800 app[10299:257976] --- lock ---
2019-02-27 16:29:20.209101+0800 app[10299:257977] --- lock ---
2019-02-27 16:29:20.209140+0800 app[10299:257978] --- lock ---
2019-02-27 16:29:20.209257+0800 app[10299:257981] --- lock ---
2019-02-27 16:29:20.209185+0800 app[10299:257979] --- lock ---
2019-02-27 16:29:20.209217+0800 app[10299:257980] --- lock ---
2019-02-27 16:29:20.209300+0800 app[10299:257982] --- lock ---
2019-02-27 16:29:20.209369+0800 app[10299:257984] --- lock ---
2019-02-27 16:29:20.209252+0800 app[10299:257961] --- unlock ---
2019-02-27 16:29:20.209516+0800 app[10299:257868] --- sleep ---
2019-02-27 16:29:20.210307+0800 app[10299:257975] --- unlock ---
2019-02-27 16:29:20.212981+0800 app[10299:257983] --- unlock ---
2019-02-27 16:29:20.213918+0800 app[10299:257982] --- unlock ---
2019-02-27 16:29:20.214010+0800 app[10299:257979] --- unlock ---
2019-02-27 16:29:20.214093+0800 app[10299:257984] --- unlock ---
2019-02-27 16:29:20.214850+0800 app[10299:257977] --- unlock ---
2019-02-27 16:29:20.214994+0800 app[10299:257976] --- unlock ---
2019-02-27 16:29:20.215275+0800 app[10299:257978] --- unlock ---
2019-02-27 16:29:20.215355+0800 app[10299:257980] --- unlock ---
2019-02-27 16:29:20.215702+0800 app[10299:257981] --- unlock ---
```

- 继续点击屏幕，仍然会有输出，说明 线程 **没有** 发生 死锁
- 除了输出 lock 和 unlock 之外，还有输出 **sleep** ，说明也有 **获取不到锁** 的 线程 执行 **休眠**

可通过【NSRecursiveLock】递归锁解锁【重复加锁】导致【线程死锁】的问题。