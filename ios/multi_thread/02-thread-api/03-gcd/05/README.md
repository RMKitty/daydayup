[TOC]



## 1. 传统方式测量一段代码的执行时间

```c
double startTime = CFAbsoluteTimeGetCurrent();{ // NSDate, CFAbsoluteTimeGetCurrent, CACurrentMediaTime 

/**
  * 被测试执行时间的代码
for (size_t i = 0; i < iterations; i++) {
  @autoreleasepool {
      NSMutableArray *mutableArray = [NSMutableArray array];
      for (size_t j = 0; j < count; j++) {
          [mutableArray addObject:object];
      }
  }
}}

double endTime = CFAbsoluteTimeGetCurrent();
NSLog(@"Total Runtime: %g s", endTime - startTime);
```



## 2. 使用 dispatch_benchmark

```c
uint64_t t = dispatch_benchmark(iterations, ^{
  @autoreleasepool {
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (size_t i = 0; i < count; i++) {
      [mutableArray addObject:object];
    }
  }
});
NSLog(@"[[NSMutableArray array] addObject:] Avg. Runtime: %llu ns", t);
```

