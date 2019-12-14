[TOC]



## 1. create

```objective-c
NSThread  *newThread=[[NSThread alloc]init];
```

```objective-c
NSThread *newThread = [[NSThread alloc]initWithTarget:self selector:@selector(demo:) object:@"Thread"];
```

```objective-c
NSThread  *newThread= [[NSThread alloc]initWithBlock:^{
   NSLog(@"initWithBlock");
}];
```

## 2. dictionary

```objective-c
/**
  每个线程都维护了一个键-值的字典,它可以在线程里面的任何地方被访问。
  你可以使用该字典来保存一些信息,这些信息在整个线程的执行过程中都保持不变。
  比如,你可以使用它来存储在你的整个线程过程中 Run loop 里面多次迭代的状态信息。
  NSThread实例可以使用一下方法
*/
@property (readonly, retain) NSMutableDictionary *threadDictionary; 
```

每一个线程，都可以这样，获取得到自己 **专属** 的 dict 对象

```objective-c
NSMutableDictionary *dict = [thread threadDictionary];
```

## 3. priority

```objective-c
@property double threadPriority;
```

## 4. qos(quality of service)

```objective-c
/** 
  NSQualityOfServiceUserInteractive：最高优先级,主要用于提供交互UI的操作,比如处理点击事件,绘制图像到屏幕上
  NSQualityOfServiceUserInitiated：次高优先级，主要用于执行需要立即返回的任务
  NSQualityOfServiceDefault：默认优先级，当没有设置优先级的时候，线程默认优先级
  NSQualityOfServiceUtility：普通优先级，主要用于不需要立即返回的任务
  NSQualityOfServiceBackground：后台优先级，用于完全不紧急的任务
*/
@property NSQualityOfService qualityOfService; 
```

这是 iOS 8 之后，代替 priority 的一种策略。

## 5. name

```objective-c
@property (nullable, copy) NSString *name;
```

## 6. stack

```objective-c
@property NSUInteger stackSize;
```

默认值是 **512 KB**

## 7. state

### 1. executing

```objective-c
@property (readonly, getter=isExecuting) BOOL executing;
```

### 2. finished

```objective-c
@property (readonly, getter=isFinished) BOOL finished;
```

### 3. cancelled

```objective-c
@property (readonly, getter=isCancelled) BOOL cancelled;
```

## 8. start

```objective-c
[thread start];
```

启动一个线程，开始执行。

## 9. is main thread

```objective-c
isMain = [thread isMainThread];
```

## 10. set thread name

```objective-c
[thread setName: @"The Second Thread"];
```

## 11. entry main

```objective-c
-(void)main;
```

线程的入口方法。

## 12. cancel

```objective-c
[thread cancel];
```

这个方法执行后，线程并不会立马就会取消执行。

一定要结合 `id)isCancelled;` 判断线程是否被取消。

