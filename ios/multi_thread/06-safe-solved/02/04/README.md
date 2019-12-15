[TOC]



## 1. GNUStep NSConditionLock 源码

```c
@implementation NSConditionLock

- (id) initWithCondition: (NSInteger)value
{
  if (nil != (self = [super init]))
  {
    if (nil == (_condition = [NSCondition new])) // 内部调用 NSCondition
    {
      DESTROY(self);
    }
    else
    {
      _condition_value = value;
    }
  }
  return self;
}

- (void) lock
{
  [_condition lock];
}

- (BOOL) lockBeforeDate: (NSDate*)limit
{
  return [_condition lockBeforeDate: limit];
}

- (void) lockWhenCondition: (NSInteger)value
{
  [_condition lock];
  while (value != _condition_value)
  {
    [_condition wait];
  }
}

- (BOOL) lockWhenCondition: (NSInteger)condition_to_meet
                beforeDate: (NSDate*)limitDate
{
  if (NO == [_condition lockBeforeDate: limitDate])
    {
      return NO;
    }
  if (condition_to_meet == _condition_value)
    {
      return YES;
    }
  while ([_condition waitUntilDate: limitDate])
    {
      if (condition_to_meet == _condition_value)
      {
        return YES; // KEEP THE LOCK
      }
    }
  [_condition unlock];
  return NO;
}

MNAME

- (BOOL) tryLock
{
  return [_condition tryLock];
}

- (BOOL) tryLockWhenCondition: (NSInteger)condition_to_meet
{
  if ([_condition tryLock])
  {
    if (condition_to_meet == _condition_value)
    {
      return YES; // KEEP THE LOCK
    }
    else
    {
      [_condition unlock];
    }
  }
  return NO;
}

- (void) unlock
{
  [_condition unlock];
}

- (void) unlockWithCondition: (NSInteger)value
{
  _condition_value = value;
  [_condition broadcast];
  [_condition unlock];
}

@end
```

- 内部调用 NSCondition 完成 signal、wait、lock、unlock
- 在 NSCondition 基础上，增加了 **条件值** 逻辑



## 2. NSConditionLock 基本使用

```c
@interface ViewController()
@property (strong, nonatomic) NSConditionLock *conditionLock;
@end

@implementation ViewController

- (instancetype)init
{
  if (self = [super init])
  {
    /**
     * 初始化condition内部条件值 = 1
     */
    self.conditionLock = [[NSConditionLock alloc] initWithCondition:1];
  }
  return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  // 二个子线程
  [[[NSThread alloc] initWithTarget:self selector:@selector(one) object:nil] start];
  [[[NSThread alloc] initWithTarget:self selector:@selector(two) object:nil] start];
}

- (void)one
{
  // 按照【条件值 = 1】进行加锁
  [self.conditionLock lockWhenCondition:1];
  
  NSLog(@"one");
  sleep(1);
  
  // 按照【条件值 = 2】进行解锁
  [self.conditionLock unlockWithCondition:2];
}

- (void)two
{
  // 按照【条件值 = 2】进行加锁
  [self.conditionLock lockWhenCondition:2];
  
  NSLog(@"two");
  sleep(1);
  
  // 按照【条件值 = 2】进行解锁
  [self.conditionLock unlockWithCondition:3];
}

@end
```

```
2018-06-16 13:39:07.213 Test[10563:159052] one
2018-06-16 13:39:07.213 Test[10563:159055] two
```

先执行 one，再执行 two。



## 3. 控制 3个线程 ==顺序== 执行

```c
@interface NSConditionLockDemo()
@property (strong, nonatomic) NSConditionLock *conditionLock;
@end

@implementation NSConditionLockDemo

- (instancetype)init
{
  if (self = [super init]) {
    self.conditionLock = [[NSConditionLock alloc] initWithCondition:1];
  }
  return self;
}

- (void)otherTest
{
  [[[NSThread alloc] initWithTarget:self selector:@selector(one) object:nil] start];
  [[[NSThread alloc] initWithTarget:self selector:@selector(two) object:nil] start];
  [[[NSThread alloc] initWithTarget:self selector:@selector(three) object:nil] start];
}

- (void)one
{
  [self.conditionLock lockWhenCondition:1];
  
  NSLog(@"one");
  sleep(1);
  
  [self.conditionLock unlockWithCondition:2];
}

- (void)two
{
  [self.conditionLock lockWhenCondition:2];
  
  NSLog(@"two");
  sleep(1);
  
  [self.conditionLock unlockWithCondition:3];
}

- (void)three
{
  [self.conditionLock lockWhenCondition:3];
  
  NSLog(@"three");
  
  [self.conditionLock unlockWithCondition:1];
  [self.conditionLock unlock];
}

@end
```



## 4. 加锁的区别

### 1. 不管条件，直接加锁或解锁

```c
[self.conditionLock lock];
[self.conditionLock unlock];
```

### 2. 按照条件，加锁或解锁

```c
[self.conditionLock lockWhenCondition:1];
[self.conditionLock unlockWithCondition:2];
```