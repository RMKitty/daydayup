[TOC]



## 1. @property `Dog* dog`

- 1) 线程是否安全：默认使用 **nonatomic** 不做任何线程安全处理
- 2) 对象内存管理策略：默认使用 `__strong` 持有对象内存



## 2. @property(copy) 使用 ==浅拷贝== 方式赋值

- 1）先使用浅拷贝方式拷贝生成一个新的拷贝对象
- 2）对已经持有的对象release
- 3）持有新的拷贝对象

```c
#import "ViewController.h"
#import <libkern/OSAtomic.h>

@interface XZHUser : NSObject <NSCopying>
@property (nonatomic, copy) NSString *name;
@end
@implementation XZHUser
- (NSString *)description {
  return [NSString stringWithFormat:@"<%@ - %p> name = %@", [self class], self, _name];
}
-(NSString *)debugDescription {
  return [self description];
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone {
  XZHUser* obj = [XZHUser new];
  obj.name = _name;
  return obj;
}
@end

@interface ViewController()
@property (nonatomic, copy) NSArray* arr;
@end

@implementation ViewController

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  XZHUser *user1 = [XZHUser new];
  user1.name = @"user1";
  XZHUser *user2 = [XZHUser new];
  user2.name = @"user2";
  XZHUser *user3 = [XZHUser new];
  user3.name = @"user3";
  
  // 原始对象
  id tmp_arr = [@[user1, user2, user3] mutableCopy];
  NSLog(@"[tmp_arr: %p] = %@", tmp_arr, tmp_arr);
  
  // 直接使用ivar赋值，不会触发 setter 的 copy拷贝修饰赋值
  _arr = tmp_arr;
  NSLog(@"[_arr: %p] = %@", _arr, _arr);
  
  // 必须使用 self.ivar 赋值
  self.arr = tmp_arr;
  NSLog(@"[self.arr: %p] = %@", self.arr, self.arr);
}

@end
```

```
2018-04-14 12:28:46.471 iOS[9548:231928] [tmp_arr: 0x7fd4a8608890] = (
    "<XZHUser - 0x7fd4a8606e10> name = user1",
    "<XZHUser - 0x7fd4a8604790> name = user2",
    "<XZHUser - 0x7fd4a861d470> name = user3"
)
2018-04-14 12:28:46.472 iOS[9548:231928] [_arr: 0x7fd4a8608890] = (
    "<XZHUser - 0x7fd4a8606e10> name = user1",
    "<XZHUser - 0x7fd4a8604790> name = user2",
    "<XZHUser - 0x7fd4a861d470> name = user3"
)
2018-04-14 12:28:46.472 iOS[9548:231928] [self.arr: 0x7fd4a8517e00] = (
    "<XZHUser - 0x7fd4a8606e10> name = user1",
    "<XZHUser - 0x7fd4a8604790> name = user2",
    "<XZHUser - 0x7fd4a861d470> name = user3"
)
```

- 使用`_arr`赋值时，直接就是**tmp_arr**指向的对象
- 使用`self.arr`赋值时，拷贝出了一个**新的对象**
- 但最终三个数组内部的元素，都是相同的



## 3. @property(strong) 赋值 ==指向==, retain 新值, release 旧值

```c
#import "ViewController.h"
#import <libkern/OSAtomic.h>

@interface XZHUser : NSObject <NSCopying>
@property (nonatomic, copy) NSString *name;
@end
@implementation XZHUser
- (NSString *)description {
  return [NSString stringWithFormat:@"<%@ - %p> name = %@", [self class], self, _name];
}
-(NSString *)debugDescription {
  return [self description];
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone {
  XZHUser* obj = [XZHUser new];
  obj.name = _name;
  return obj;
}
@end

@interface ViewController()
@property (nonatomic, strong) NSArray* arr;
@end

@implementation ViewController

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  XZHUser *user1 = [XZHUser new];
  user1.name = @"user1";
  XZHUser *user2 = [XZHUser new];
  user2.name = @"user2";
  XZHUser *user3 = [XZHUser new];
  user3.name = @"user3";
  
  // 原始对象
  id tmp_arr = [@[user1, user2, user3] mutableCopy];
  NSLog(@"[tmp_arr: %p] = %@", tmp_arr, tmp_arr);
  
  // 直接使用ivar赋值，不会触发 setter 的 copy拷贝修饰赋值
  _arr = tmp_arr;
  NSLog(@"[_arr: %p] = %@", _arr, _arr);
  
  // 必须使用 self.ivar 赋值
  self.arr = tmp_arr;
  NSLog(@"[self.arr: %p] = %@", self.arr, self.arr);
  
}

@end
```

- 只修改 @property (nonatomic, **copy**) => @property (nonatomic, **strong**)
- 其他的代码不都不变

```
2018-04-14 12:31:39.167 iOS[9643:236007] [tmp_arr: 0x7fc8c340cfe0] = (
    "<XZHUser - 0x7fc8c3410510> name = user1",
    "<XZHUser - 0x7fc8c34a2d60> name = user2",
    "<XZHUser - 0x7fc8c349f790> name = user3"
)
2018-04-14 12:31:39.168 iOS[9643:236007] [_arr: 0x7fc8c340cfe0] = (
    "<XZHUser - 0x7fc8c3410510> name = user1",
    "<XZHUser - 0x7fc8c34a2d60> name = user2",
    "<XZHUser - 0x7fc8c349f790> name = user3"
)
2018-04-14 12:31:39.168 iOS[9643:236007] [self.arr: 0x7fc8c340cfe0] = (
    "<XZHUser - 0x7fc8c3410510> name = user1",
    "<XZHUser - 0x7fc8c34a2d60> name = user2",
    "<XZHUser - 0x7fc8c349f790> name = user3"
)
```

- 三个**数组对象**都是**同一个**
- 数组内部元素就不用说了，绝对也是一样的



## 4. strong/retain setter 实现模板

```c
-(void)setName:(NSString*)str
{
  [str retain]; // retain新值
  [name release]; // release旧值
  name = str; // 赋值新值
}
```



## 5. @property(assgin) 直接赋值 ==指向==, 不添加 retain/release 内存管理

> 类似 unsafe unretained 的效果

```c
..........

@interface ViewController()
@property (nonatomic, assign) NSArray* arr; // 赋值方式改为 assign ，其他都不变
// @property (nonatomic, copy) NSDictionary* dic;
// @property (nonatomic, copy) NSSet* set;
@end

.........
```

```
2018-04-14 12:39:28.230 iOS[10067:244854] [tmp_arr: 0x7fadd140a9f0] = (
    "<XZHUser - 0x7fadd1420fc0> name = user1",
    "<XZHUser - 0x7fadd1429470> name = user2",
    "<XZHUser - 0x7fadd1404900> name = user3"
)
2018-04-14 12:39:28.230 iOS[10067:244854] [_arr: 0x7fadd140a9f0] = (
    "<XZHUser - 0x7fadd1420fc0> name = user1",
    "<XZHUser - 0x7fadd1429470> name = user2",
    "<XZHUser - 0x7fadd1404900> name = user3"
)
2018-04-14 12:39:28.230 iOS[10067:244854] [self.arr: 0x7fadd140a9f0] = (
    "<XZHUser - 0x7fadd1420fc0> name = user1",
    "<XZHUser - 0x7fadd1429470> name = user2",
    "<XZHUser - 0x7fadd1404900> name = user3"
)
```




## 6. 总结

- 1、copy
  - 1）使用**浅拷贝**出一个**新的对象**
  - 2）然后再赋值给ivar => **不同**的对象

- 2、strong
  - 1）附带 retain/release 等内存管理处理
  - 2）release 旧值
  - 3）retain 新值

- 3、weak
  - 1）弱引用的方式持有对象（无法持有对象）
  - 2）当对象被废弃时，自动赋值为nil

- 4、assign
  - 1）直接赋值给ivar的是对象的【内存地址】
  - 2）不做任何的内存管理处理