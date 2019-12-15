[TOC]



## 1. @property(atomic) 

```c
@property (strong) NSMuatbleDictionary* cache; // 默认不写就是 nonatomic
@property (strong, atomic) NSMuatbleDictionary* cache; // 显示声明 atomic
```



## 2. @property - setter

> objc-accessors.mm

- 判断是否是 atomic 类型变量
- 如果是 **non-atomic** ，直接 **修改值**
- 如果是 **atomic** ， 则使用 **spinlock** 互斥多线程顺序执行

```c
static inline void 
reallySetProperty(
  id self, 
  SEL _cmd, 
  id newValue, 
  ptrdiff_t offset, 
  bool atomic, 
  bool copy, 
  bool mutableCopy
)
{
  if (offset == 0) {
    object_setClass(self, newValue);
    return;
  }

  id oldValue;
  id *slot = (id*) ((char*)self + offset);

  if (copy) {
    newValue = [newValue copyWithZone:nil];
  } else if (mutableCopy) {
    newValue = [newValue mutableCopyWithZone:nil];
  } else {
    if (*slot == newValue) return;
    newValue = objc_retain(newValue);
  }

  /**
   * 判断是否是 atomic 类型变量
   */
  if (!atomic) 
  {
    /**
     * 【non】atomic ，直接修改值
     */
    oldValue = *slot;
    *slot = newValue;
  } 
  else 
  {
    /**
     * atomic ， 则使用 spinlock 互斥多线程顺序执行
     */

    // 1、spinlock lock
    spinlock_t& slotlock = PropertyLocks[slot];
    slotlock.lock();

    // 2、修改值
    oldValue = *slot;
    *slot = newValue;
    
    // 3、spinlock unlock        
    slotlock.unlock();
  }

  objc_release(oldValue);
}
```



## 3. @property - getter

```c
id 
objc_getProperty(
  id self, 
  SEL _cmd, 
  ptrdiff_t offset, 
  BOOL atomic
) 
{
  if (offset == 0) 
  {
    return object_getClass(self);
  }

  // Retain release world
  id *slot = (id*) ((char*)self + offset);
  if (!atomic) return *slot;
    
  /**
   * spinlock
   */
  // Atomic retain release world
  spinlock_t& slotlock = PropertyLocks[slot];
  slotlock.lock();
  id value = objc_retain(*slot);
  slotlock.unlock();

  // for performance, we (safely) issue the autorelease OUTSIDE of the spinlock.
  return objc_autoreleaseReturnValue(value);
}
```



## 4. @property(atomic) 降低效率

- 1、因为会存在 **查表** 获取 **内存地址** 对应的 **lock**
- 2、随着 **表** 中的记录 **越来越多**，效率就会 **越来越低**
- 3、所以一般 objc 类中的属性，很少使用 atomic
- 4、一般都是要 nonatomic 非原子操作
- 5、如果多线程并发修改，则手动完成加锁



## 5. @property(atomic) 只保证 setter 和 getter 内部的线程安全

### 1. Person

```c
@interface Person : NSObject
@property (assign, nonatomic) int age;
@property (copy, atomic) NSString *name;
@property (strong, atomic) NSMutableArray *data;
@end
@implementation Person
@end
```

### 2. main()

```c
int main(int argc, const char * argv[]) 
{
  @autoreleasepool 
  {
    Person *p = [[Person alloc] init];
    
    /**
     * 线程安全
     */
    for (int i = 0; i < 10; i++) 
    {
      dispatch_async(NULL, ^{
        // 加锁
        p.data = [NSMutableArray array];
        // 解锁
      });
    }
    
    /**
     * 线程安全
     */
    // 加锁
    NSMutableArray *array = p.data;
    // 解锁

    /**
     * 线程【不】安全
     * -1、此时已经不再是调用【Person 对象的 setter|getter】方法实现
     * -2、只有【Person 对象的 setter|getter】内部才会做【成员变量】的【互斥读写】
     */
    [array addObject:@"1"];
    [array addObject:@"2"];
    [array addObject:@"3"];
    
  }
  return 0;
}
```

