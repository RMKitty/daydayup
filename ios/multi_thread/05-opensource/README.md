[TOC]



## 1. 线程安全处理的总体思路

- 清楚的认识对于 **线程** 哪一些类型的数据是 **共享** 的，而哪一些类型的数据又是 **私有** 的
- **共享** 的数据，一定要做互斥处理
- **私有** 的数据，天生就是安全的，不需要做任何的处理



## 2. YYCache

### 1. YYDiskCache

#### 1. global semaphore

```objective-c
/// weak reference for all instances
static NSMapTable *_globalInstances;
static dispatch_semaphore_t _globalInstancesLock;

static void _YYDiskCacheInitGlobal() {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _globalInstancesLock = dispatch_semaphore_create(1);
    _globalInstances = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory
                                                 valueOptions:NSPointerFunctionsWeakMemory
                                                     capacity:0];
  });
}

static YYDiskCache *_YYDiskCacheGetGlobal(NSString *path) {
  if (path.length == 0) return nil;

  // 1. 初始化 semaphore
  _YYDiskCacheInitGlobal();

  // 2. lock - read/write - unlock
  dispatch_semaphore_wait(_globalInstancesLock, DISPATCH_TIME_FOREVER);
  id cache = [_globalInstances objectForKey:path];
  dispatch_semaphore_signal(_globalInstancesLock);
  return cache;
}

static void _YYDiskCacheSetGlobal(YYDiskCache *cache) {
  if (cache.path.length == 0) return;

  // 1.
  _YYDiskCacheInitGlobal();

  // 2.
  dispatch_semaphore_wait(_globalInstancesLock, DISPATCH_TIME_FOREVER);
  [_globalInstances setObject:cache forKey:cache.path];
  dispatch_semaphore_signal(_globalInstancesLock);
}
```

#### 2. instance semaphore

```objective-c
@implementation YYDiskCache {
  YYKVStorage *_kv;
  dispatch_semaphore_t _lock; // lock
  dispatch_queue_t _queue; // queue
}

- (instancetype)initWithPath:(NSString *)path
             inlineThreshold:(NSUInteger)threshold {
  self = [super init];
  if (!self) return nil;

  YYDiskCache *globalCache = _YYDiskCacheGetGlobal(path);
  if (globalCache) return globalCache;
	
	/**
   * 省略代码 ....
   */
    
	// init lock
  _lock = dispatch_semaphore_create(1);
	// init queue
  _queue = dispatch_queue_create("com.ibireme.cache.disk", DISPATCH_QUEUE_CONCURRENT);
               
	/**
   * 省略代码 ....
   */
    
  return self;
}

- (id<NSCoding>)objectForKey:(NSString *)key {
  if (!key) return nil;

  /**
   *	线程安全处理部分
   */
  Lock();
  YYKVStorageItem *item = [_kv getItemForKey:key];
  Unlock();

  /**
   * 省略代码 ....
   */

  if (!item.value) return nil;

  /**
   * 省略代码 ....
   */

  return object;
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key {
  /**
   * 省略代码 ....
   */
  
  value = ......;
  
  /**
   *	线程安全处理部分
   */
  Lock();
  [_kv saveItemWithKey:key value:value filename:filename extendedData:extendedData];
  Unlock();
}

// 异步的 get
- (void)objectForKey:(NSString *)key withBlock:(void(^)(NSString *key, id<NSCoding> object))block {
  if (!block) return;
  __weak typeof(self) _self = self;
  dispatch_async(_queue, ^{
    __strong typeof(_self) self = _self;
    id<NSCoding> object = [self objectForKey:key]; // 调用 同步的 get 加锁
    block(key, object);
  });
}
```

### 2. YYMemoryCache

#### 1. 单次 read/write

```objective-c
@implementation YYMemoryCache {
  pthread_mutex_t _lock;		// lock
  _YYLinkedMap *_lru;				// memory cache
  dispatch_queue_t _queue; 	// queue
}

- (instancetype)init {
  self = super.init;
  
  // init lock
  pthread_mutex_init(&_lock, NULL);
  
  // init cache
  _lru = [_YYLinkedMap new];
  
  // init queue
  _queue = dispatch_queue_create("com.ibireme.cache.memory", DISPATCH_QUEUE_SERIAL);

	/**
   * 省略代码 ....
   */

  return self;
}

- (void)dealloc {
  /**
   * 省略代码 ....
   */
  
  // destroy lock
  pthread_mutex_destroy(&_lock);
}

- (id)objectForKey:(id)key {
  if (!key) return nil;
  
  // 1. lock
  pthread_mutex_lock(&_lock);
  
  // 2. read memory cache
  _YYLinkedMapNode *node = CFDictionaryGetValue(_lru->_dic, (__bridge const void *)(key));
  if (node) {
    node->_time = CACurrentMediaTime();
    [_lru bringNodeToHead:node];
  }
  
  // 3. unlock
  pthread_mutex_unlock(&_lock);
  
  return node ? node->_value : nil;
}

- (void)setObject:(id)object forKey:(id)key {
    [self setObject:object forKey:key withCost:0];
}

- (void)setObject:(id)object forKey:(id)key withCost:(NSUInteger)cost {
  if (!key) return;
  if (!object) {
    [self removeObjectForKey:key];
    return;
  }
  
  pthread_mutex_lock(&_lock);
  
  /**
   * 省略代码 ....
   */
  // write memory cache
  
  pthread_mutex_unlock(&_lock);
}
```

#### 2. for/while 循环

```objective-c
- (void)_trimToAge:(NSTimeInterval)ageLimit {
  /**
   * 省略代码 ....
   */
  
  NSMutableArray *holder = [NSMutableArray new];
  
  /**
   * for/while 循环中, 处理 lock && unlock
   */
  while (!finish) 
  {
    if (pthread_mutex_trylock(&_lock) == 0) // 1.1) tryLock
    {
      // 2. write memeory cache
      if (_lru->_tail && (now - _lru->_tail->_time) > ageLimit)
      {
        _YYLinkedMapNode *node = [_lru removeTailNode];
        if (node) [holder addObject:node];
      } else {
        finish = YES;
      }
      
      // 3. unlock
      pthread_mutex_unlock(&_lock);
    } else {
      usleep(10 * 1000); // 1.2) 如果 tryLock 失败, 则 sleep 当前线程 10 ms
    }
  }
  
  if (holder.count) {
    dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : YYMemoryCacheGetReleaseQueue();
    dispatch_async(queue, ^{
        [holder count]; // release in queue
    });
  }
}
  
```



## 3. YYModel

```objective-c
@implementation YYClassInfo {
  BOOL _needUpdate;
}

+ (instancetype)classInfoWithClass:(Class)cls {
  if (!cls) return nil;
  
  // 1. 局部的 static 变量
  static CFMutableDictionaryRef classCache;	// cache 1
  static CFMutableDictionaryRef metaCache;	// cache 2
  static dispatch_once_t onceToken;					// once token
  static dispatch_semaphore_t lock;					// lock
  
  // 2. dispatch once 方式, init cache、init lock 
  dispatch_once(&onceToken, ^{
		// init cache 1
    classCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    // init cache 2
    metaCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    // init lock
    lock = dispatch_semaphore_create(1);
  });
  
  // 3. lock
  dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
  
  // 4. write/read cache
  YYClassInfo *info = CFDictionaryGetValue(class_isMetaClass(cls) ? metaCache : classCache, (__bridge const void *)(cls));
  if (info && info->_needUpdate) {
    [info _update];
  }
  
  // 5. unLock
  dispatch_semaphore_signal(lock);
  
  // 6. 
  if (!info) {
    info = [[YYClassInfo alloc] initWithClass:cls];
    if (info) {
      // lock	
      dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
      // write/read cache
      CFDictionarySetValue(info.isMeta ? metaCache : classCache, (__bridge const void *)(cls), (__bridge const void *)(info));
      // unLock
      dispatch_semaphore_signal(lock);
    }
  }
    return info;
}

/**
 * 省略其他代码 ...
 */

@end
```

### 其他的不安全的 Cache 开源库

- PINCache : 公司项目有用，经常发生崩溃，线程死锁
- TMCache : 比较古老了，大部分是由 GCD sync，同样大量的线程死锁
- MMKV : 之前几个版本我看大部分是由 OSSpinLock，感觉不靠谱，不知道改了没

