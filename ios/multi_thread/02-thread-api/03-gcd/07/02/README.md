[TOC]



## 1. 提高多线程并发性能原则

- 1、不要随意使用 `dispatch_get_global_queue(0, 0)` 创建子线程执行耗时任务，可能会造成某个时刻的子线程数过多
- 2、尽量保持 `线程并发数 == CPU的激活核心数`，控制同一时刻最大的子线程个数
- 3、子线程个数过多，也会造成CPU频繁切换浪费时间、资源来保存与还原上下文环境



## 2. CPU 任务类型

- 1、CPU 密集型：
  - 1）短时间内任务的量很大
  - 2）但是每一个任务消耗的 CPU 时间片都很短
  - 3）比如：对象创建与释放、布局计算、绘制、渲染 ...

- 2、非 CPU 密集型（IO 型）：
  - 1）短时间内任务数不是特别多
  - 2）但是每一个任务消耗的 CPU 时间片都很长
  - 3）比如：文件读写、数据加解密、数据压缩与解压缩、数据排序 ...

对于移动端 app 应用程序来说，通常是第一种 CPU 密集型。



## 3. 不同类型任务, 对线程并发数的要求不一样

对于 `非CPU密集型` 的业务（加解密、压缩解压缩、搜索排序等业务是CPU密集型的业务），瓶颈都在 `后端数据库`，而对 `客户端 CPU` 计算的时间很少，所以一般都是对 `后端数据服务器主机 cpu` 设置几十或者几百个工作线程也都是可能的。

而对于 `CPU密集型` 的业务来说，`线程等待时间` 和 `线程占用CPU时间` 一般都是很短的，所以将上面的公式如果在密集型CPU类型时。

- 1、CPU 密集型：
  - 1）任务大多都是秒级，并不会太消耗时间
  - 2）因为线程任务消耗时间不是太长，所以并不需要太多的线程。如果线程过多，则反而在线程切换、线程竞争处理时消耗过多的时间
  - 3）总结：线程数尽量的少

- 2、IO 型：
  - 1）任务都相对耗时的多，大多都是十几秒、分钟级别
  - 2）需要大量的线程来执行任务，如果线程数大少，则会出现任务阻塞
  - 3）总结：线程数尽量的多

移动端 app 应用程序处理，属于 CPU 密集型。



## 4. 线程并发数 == CPU 的激活核心数

- 对于 **移动端** 这种情况, 就属于 **CPU 密集型** 模式
- 短时间内的处理的任务会很多
- 但是每一个任务的处理时间, 并不会很长 (你不会看到一个超过半小时的任务)

- 所以控制全局线程的并发数，刚好 **等于** 当前设备 **CPU 激活核心数**
- 这样既满足 CPU 线程最大并发数，又不会因为线程数过多导致性能损失