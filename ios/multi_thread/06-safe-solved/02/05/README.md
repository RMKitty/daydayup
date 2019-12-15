[TOC]



## 1. @synchronized(object) { ..} 基本使用

```c
@implementation SynchronizedDemo

- (void)drawMoney
{
  // 针对【self class】互斥多线程
  @synchronized([self class]) {
  // @synchronized(self) { 也可以
    [super drawMoney];
  }
}

- (void)saveMoney
{
  // 针对【self class】互斥多线程
  @synchronized([self class]) { // 调用 objc_sync_enter()
  // @synchronized(self) { 也可以
    [super saveMoney];
  } // 调用 objc_sync_exit()
}

- (void)saleTicket
{
  static NSObject *lock;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    lock = [[NSObject alloc] init];
  });
  
  // 针对【lock对象】互斥多线程
  @synchronized(lock) {
    [super saleTicket];
  }
}

- (void)otherTest
{
  // 针对【self class】互斥多线程
  @synchronized([self class]) {
  // @synchronized(self) { 也可以
    NSLog(@"123");
    [self otherTest];
  }
}
@end
```

```objective-c
@implementation ThreadSafeQueue
{
    NSMutableArray *_elements;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _elements = [NSMutableArray array];
    }
    return self;
}
- (void)increment
{
    @synchronized (self) {
        [_elements addObject:element];
    }
}
@end
```

缺点：所有的方法，都 **共享同一把锁**，造成性能低下。



## 2. @synchronized(obejct){} 原理

```objective-c
@synchronized(obejct){ // 1. 进入同步代码块, 调用 objc_sync_enter()
  /**
   * 同步代码块
   */
  ...........
} // 2. 离开同步代码块, 调用 objc_sync_exit()
```

- 1）根据传入的 object（对象的内存地址），生成一个唯一对应的 mutex 互斥锁
- 2）进入 @synchronized(var){} 代码块，调用 **objc_sync_enter()**
- 3）离开 @synchronized(var){} 代码块，调用 **objc_sync_exit()**



## 3. 每一个 object 对应不同的 ==互斥锁==

> objc runtime objc-sync.mm 

### 1. objc_sync_enter()

```c
int objc_sync_enter(id obj) {
  int result = OBJC_SYNC_SUCCESS;

  if (obj) {
    SyncData* data = id2data(obj, ACQUIRE); // 查找传入的obj对应的mutex互斥锁
    assert(data);
    data->mutex.lock(); // 对找到的mutex互斥锁，完成【加锁】
  } else {
    // @synchronized(nil) does nothing
    if (DebugNilSync) {
      _objc_inform("NIL SYNC DEBUG: @synchronized(nil); set a breakpoint on objc_sync_nil to debug");
    }
    objc_sync_nil();
  }

  return result;
}
```

### 2. objc_sync_exit()

```c
int objc_sync_exit(id obj) {
  int result = OBJC_SYNC_SUCCESS;

  if (obj) {
    SyncData* data = id2data(obj, RELEASE); // 查找传入的obj对应的mutex互斥锁
    if (!data) {
      result = OBJC_SYNC_NOT_OWNING_THREAD_ERROR;
    } else {
      bool okay = data->mutex.tryUnlock(); // 对找到的mutex互斥锁，完成【解锁】
      if (!okay) {
        result = OBJC_SYNC_NOT_OWNING_THREAD_ERROR;
      }
    }
  } else {
    // @synchronized(nil) does nothing
  }


  return result;
}
```

### 3. object 与 mutex 对应关系

```c
struct SyncList 
{
  SyncData *data;
  spinlock_t lock;

  SyncList() : data(nil), lock(fork_unsafe_lock) { }
};

// Use multiple parallel lists to decrease contention among unrelated objects.
#define LOCK_FOR_OBJ(obj) sDataLists[obj].lock
#define LIST_FOR_OBJ(obj) sDataLists[obj].data

// map存储<object:mutex>的对应关系
static StripedMap<SyncList> sDataLists;
```

### 4. 结论

- 同步代码块这种方式, 每传入一个 object, 就会在 **全局 map** 中 **增加** 一条记录
- 当 **object 记录越来越多** 的情况下, **查询 map 效率降低**, 就会影响 加锁、解锁 效率
- 少使用这种锁, **效率是最低** 的

