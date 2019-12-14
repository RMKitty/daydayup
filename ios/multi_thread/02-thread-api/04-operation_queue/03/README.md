[TOC]



后续只需要根据这个模板进行改进内部的耗时任务代码即可。

## 1. MyOperation.h

```c
@interface MyOperation : NSOperation

@property (nonatomic, strong) NSSet *runLoopModes;

- (void)addCompletionBlock:(void (^)(void))block;

// 暂停
- (void)pause;

// 恢复
- (void)resume;

@end
```



## 2. MyOperation.m

```c
#import "MyOperation.h"

/** 
 *  operation 所有的状态
 */
typedef NS_ENUM(NSInteger, AFOperationState) {
  AFOperationPausedState      = -1,
  AFOperationReadyState       = 1,
  AFOperationExecutingState   = 2,
  AFOperationFinishedState    = 3,
};

/** 
 * operation 所有的状态对应的 NSOperation内部状态变化使用的string
 *
 *  - (1) isReady
 *  - (2) isExecuting
 *  - (3) isFinished
 *  - (4) isPaused
 */
static inline NSString * AFKeyPathFromOperationState(AFOperationState state) {
  switch (state) 
  {
    case AFOperationReadyState:
      return @"isReady";
    case AFOperationExecutingState:
      return @"isExecuting";
    case AFOperationFinishedState:
      return @"isFinished";
    case AFOperationPausedState:
      return @"isPaused";
    default: {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wunreachable-code"
      return @"state";
    #pragma clang diagnostic pop
    }
  }
}

/**
 *  判断 fromState 是否能够变化成 toState
 */
static inline BOOL AFStateTransitionIsValid(AFOperationState fromState, AFOperationState toState, BOOL isCancelled) 
{
    switch (fromState) {
        case AFOperationReadyState:
            switch (toState) {
                case AFOperationPausedState:
                case AFOperationExecutingState:
                    return YES;
                case AFOperationFinishedState:
                    return isCancelled;
                default:
                    return NO;
            }
        case AFOperationExecutingState:
            switch (toState) {
                case AFOperationPausedState:
                case AFOperationFinishedState:
                    return YES;
                default:
                    return NO;
            }
        case AFOperationFinishedState:
            return NO;
        case AFOperationPausedState:
            return toState == AFOperationReadyState;
        default: {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunreachable-code"
            switch (toState) {
                case AFOperationPausedState:
                case AFOperationReadyState:
                case AFOperationExecutingState:
                case AFOperationFinishedState:
                    return YES;
                default:
                    return NO;
            }
        }
#pragma clang diagnostic pop
    }
}

@interface MyOperation ()
@property (readwrite, nonatomic, assign) AFOperationState state;
@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;

- (void)operationDidStart;
- (void)operationDidPause;
- (void)finish;
- (void)cancelConnection;
@end

@implementation MyOperation

// thread入口回调函数
+ (void)networkRequestThreadEntryPoint:(id)__unused object {
    @autoreleasepool {
        [[NSThread currentThread] setName:@"AFNetworking"];
        
        // 开启runloop来保活thread对象
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

// 创建单例thread对象
+ (NSThread *)networkRequestThread {
    static NSThread *_networkRequestThread = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _networkRequestThread = [[NSThread alloc] initWithTarget:self
                                                        selector:@selector(networkRequestThreadEntryPoint:) object:nil];
        [_networkRequestThread start];
    });
    
    return _networkRequestThread;
}

- (instancetype)initWithRequest:(NSURLRequest *)urlRequest {
    NSParameterAssert(urlRequest);
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _state = AFOperationReadyState;
    _runLoopModes = [NSSet setWithObject:NSRunLoopCommonModes];
    
    self.lock = [[NSRecursiveLock alloc] init];
    self.lock.name = @"myoperation_thread";
    
    return self;
}


- (instancetype)init NS_UNAVAILABLE
{
    return nil;
}

- (void)dealloc {
    /**
     * TODO: 清除当前operation占用的内存资源
     */
}

#pragma mark - operation start

- (void)start {
    [self.lock lock];
    
    if ([self isCancelled])
    {
        // 单例thread执行【取消】operation
        [self performSelector:@selector(cancelConnection)
                     onThread:[[self class] networkRequestThread]
                   withObject:nil
                waitUntilDone:NO
                        modes:[self.runLoopModes allObjects]];
        
    }
    else if ([self isReady])
    {
        // 修改operation状态为executing
        self.state = AFOperationExecutingState;

        // 单例thread执行【开始】operation
        [self performSelector:@selector(operationDidStart)
                     onThread:[[self class] networkRequestThread]
                   withObject:nil
                waitUntilDone:NO
                        modes:[self.runLoopModes allObjects]];
    }
    [self.lock unlock];
}

- (void)operationDidStart {
    [self.lock lock];
    
    if (![self isCancelled])
    {
        /*
            单例thread上创建网络连接、文件输入输出流，执行后续耗时代码
         
            self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];

            NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
            for (NSString *runLoopMode in self.runLoopModes) {
                [self.connection scheduleInRunLoop:runLoop forMode:runLoopMode];
                [self.outputStream scheduleInRunLoop:runLoop forMode:runLoopMode];
            }

            [self.outputStream open];
            [self.connection start];
         */
    }
    
    [self.lock unlock];
    
    // 主线程发出通知，告知外界operation已经开始执行了
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AFNetworkingOperationDidStartNotification"
                                                            object:self];
    });
}

#pragma mark - operation pause

- (void)pause 
{
    //1. 已经是如下三种状态时，则不再允许继续暂停
    if ([self isPaused] || [self isFinished] || [self isCancelled]) {
        return;
    }

    //2. 进入到单例thread执行，并且上锁，不在线允许其他的operation对象进来
    [self.lock lock];
    
    //3.
    if ([self isExecuting]) {
        
        //3.1 在单例thread上执行后续耗时代码
        [self performSelector:@selector(operationDidPause)
                     onThread:[[self class] networkRequestThread]
                   withObject:nil
                waitUntilDone:NO
                        modes:[self.runLoopModes allObjects]];
        
        //3.2 主线程发出通知，告诉外界operation已经被puase暂停了
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter postNotificationName:@"AFNetworkingOperationDidFinishNotification"
                                              object:self];
        });
    }
    
    //4. 修改operation的状态，发出kvo通知，通知系统执行状态改变
    self.state = AFOperationPausedState;
    
    //5. 当前operation在单例thread执行完毕，离开时解除锁定，让其他的operation可以进来执行
    [self.lock unlock];
    
    /**
     *  6. TODO: 将当前operation执行的数据进行缓存起来，
     *        等待下次resume时候进行恢复
     */
    //............
}


- (void)operationDidPause {
  [self.lock lock];
  
  /**
   * TODO: 清除当前operation占用的内存资源
   */
  
  [self.lock unlock];
}

#pragma mark - operation resume

- (void)resume 
{
  //1. 只能是pause状态的operation可以resume
  if (![self isPaused]) {
    return;
  }

  //2. 修改operation的state必须多线程同步执行如下代码
  [self.lock lock];

  //3. 修改operation的state
  self.state = AFOperationReadyState;

  //4. 直接让operation执行
  [self start];

  //5. 解锁
  [self.lock unlock];
}

#pragma mark - operation finish

- (void)finish 
{
  // 1. 直接发出 isFinished 的kvo通知，通知系统当前operation对象执行完毕了
  [self.lock lock];
  self.state = AFOperationFinishedState; // setState: 触发KVO通知
  [self.lock unlock];

  // 2. 主线程发出通知，告知外界operation已经执行完毕了
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AFNetworkingOperationDidFinishNotification"
                                                        object:self];
  });
}

#pragma mark - operation cancel

/**
 * 取消operation的执行
 * 
 * - 1、调用【NSOperation】父类的 cancel 取消
 * - 2、清除【当前operation对象】分配的各种内存资源
 * - 3、修改【当前operation对象】状态值为【Finish】，并手动发出【KVO通知】通知系统已经执行完毕
 * - 4、回调执行用户设置给【当前operation对象】的【completionBlock】
 */
- (void)cancel 
{
  [self.lock lock];

  if (![self isFinished] && ![self isCancelled]) 
  {
    // 1、调用父类的取消operation方法
    [super cancel];
    
    // 2、单例thread上执行清除operation对象创建的内存资源
    if ([self isExecuting]) 
    {
      [self performSelector:@selector(cancelConnection)
                    onThread:[[self class] networkRequestThread]
                  withObject:nil
              waitUntilDone:NO
                      modes:[self.runLoopModes allObjects]];
    }
  }

  [self.lock unlock];
}

- (void)cancelConnection 
{
  if (![self isFinished]) 
  {
    /**
      
      判断当前operation是否分配了内存资源（网络连接、文件输入流输出流）
      - (1) 如果有，需要先进行取消，然后才能结束执行operation
      - (2) 如果没有，则可以直接结束执行operation
    
    if (self.connection) 
    {
      //情况(1)
    
      //关闭网络连接，在系统回调中，再执行结束执行oepration的[self finish];操作
      [self.connection cancel];
    
      // 回调通知外界operation取消执行
      [self performSelector:@selector(connection:didFailWithError:) 
          withObject:self.connection withObject:error];
    } else {
      //情况(2)
      [self finish];
    }
    */
  }
}

#pragma mark - opertioan state 改变

/**
 *  更改operation的状态时，手动发出kvo通知，
 *  通知系统更新operation对象的方法
 */
- (void)setState:(AFOperationState)state 
{
  if (!AFStateTransitionIsValid(self.state, state, [self isCancelled])) {
    return;
  }

  [self.lock lock];
  NSString *oldStateKey = AFKeyPathFromOperationState(self.state);
  NSString *newStateKey = AFKeyPathFromOperationState(state);

  [self willChangeValueForKey:newStateKey];
  [self willChangeValueForKey:oldStateKey];
  _state = state;
  [self didChangeValueForKey:oldStateKey];
  [self didChangeValueForKey:newStateKey];
  [self.lock unlock];
}

#pragma mark - 获取当前operation状态bool值

- (BOOL)isReady {
  return self.state == AFOperationReadyState && [super isReady];
}

- (BOOL)isExecuting {
  return self.state == AFOperationExecutingState;
}

- (BOOL)isPaused {
  return self.state == AFOperationPausedState;
}

- (BOOL)isFinished {
  return self.state == AFOperationFinishedState;
}

- (BOOL)isConcurrent {
  return YES;
}

#pragma mark - set completionBlock

- (void)addCompletionBlock:(void (^)(void))block
{
  //1.
  [self.lock lock];

  //2.
  self.completionBlock = ^()
  {
    // 主线程执行block，防止操作UI崩溃
    dispatch_async(dispatch_get_main_queue(), ^{
      block();
    });
  };

  //3.
  [self.lock unlock];
}

@end
```