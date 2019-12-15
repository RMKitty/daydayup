[TOC]



## 1. OSSPinLock : 【占用】CPU 时间片 => 内核态

- [点击我](01/README.md)



## 2. 互斥锁 : 【释放】CPU 时间片 => 用户态

- 获取锁【失败】时 => 主动【挂起】线程，线程进入【休眠】, **释放 CPU** => 等待 **被唤醒**
- 适用于【用户态】线程之间的互斥

### 1. objc lock

- [01 - NSLock](02/01/README.md)
- [02 - NSRecursiveLock](02/02/README.md)
- [03 - NSCondition](02/03/README.md)
- [04- NSConditionLock](02/04/README.md)
- [05 - @syncronized(obj){ … }](02/05/README.md)

### 2. Low level lock

- [06 - dispatch_semephore_t](02/06/README.md)

- [07 - os_unfair_locok](02/07/README.md)

### 3. Linux/Unix

- [08 - pthread_mutex_t](02/08/README.md)
- [09 - pthread_rwlock]()



## 3. Atomic

- [01 - objc property atomic](03/01/README.md)
- [02 - OSAtomic 库函数](03/02/README.md)



## 4. GCD

- [01 - dispatch sync 顺序 读、写](04/01/README.md)
- [02 - dispatch async 顺序 读、写](04/02/README.md)
- [03 - dispatch barrier async 并发读、顺序写](04/03/README.md)



