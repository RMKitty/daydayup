[TOC]



注意: 必须使用 **串行** 队列

```objective-c
#import "ViewController.h"

@implementation ViewController {
  dispatch_queue_t queue;
  NSMutableDictionary *dic;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  queue = dispatch_queue_create(
    "com.test.queue", 
    DISPATCH_QUEUE_SERIAL // 只能【串行】队列
  );
}

- (void)func {
  // 线程安全处理
  dispatch_async(queue, ^{
    self->dic = [NSMutableDictionary new];
  });
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  for (int i=0; i<100; i++) {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
      [self func];
    });
  }
}

@end
```

正常运行，没有崩溃。