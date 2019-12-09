[TOC]



## 这个库干什么的?

这个是很多水友们一起维护的知识 交流、记录、分享 的仓库。

不局限于 iOS，可以是任何一门编程语言、任何一门技术、任何一本书籍读后感、面试题解析 … 等等, 都可以记录在这里，提供给其他的童鞋。



## C

### 1. 基本类型

- [01 - bit 二进制操作](ansi_c/01/bit.md)
- [02 - union](ansi_c/01/union.md)

### 2. 指针

- [01 - 指针也是一种 ==数据类型==](ansi_c/02/01/README.md)
- [02 - 各种 ==指针== 概念](ansi_c/02/02/README.md)
- [03 - ==const== 修饰 指针变量](ansi_c/02/03/README.md)
- [04 - 指针的 ==步长==](ansi_c/02/04/README.md)
- [05 - ==指针== 与 ==函数==](ansi_c/02/05/README.md)
- [06 - ==指针== 与 ==字符串==](ansi_c/02/06/README.md)
- [07 - ==指针== 与 ==数组==](ansi_c/02/07/README.md)

### 3. 面向对象

- [01 - struct、封装、继承](ansi_c/03/01/README.md)
- [02 - 多态、虚函数表](ansi_c/03/02/README.md)
- [03 - 通用数据结构](ansi_c/03/03/README.md)

### 4. 内存

- [01 - 变量 = 符号 + 存储](ansi_c/04/01/01.md)
- [02 - extern 关键字](ansi_c/04/02.md)
- [03 - 内存分段](ansi_c/04/03/03.md)
- [04 - 全局变量](ansi_c/04/04.md)
- [05 - 变量的存储](ansi_c/04/05.md)
- [06 - 堆与栈](ansi_c/04/06/06.md)
- [07 - stdlib 中提供的内存操作的标准库函数](ansi_c/04/07/07.md)

### 5. 读书笔记





## C++

### 1. C++ 与 C


### 2. 复合类型



### 3. 类型转换



### 4. 函数



### 5. 引用



### 6. 名字空间



### 7. 对象与类 (构造/析构/拷贝构造/赋值)



### 8. 类 - 方法重载



### 9. 类 - 继承



### 10. 类 - 动态内存分配



### 11. 类 - 抽象、多态



### 12. static



### 13. const



### 14. 友元



### 15. 异常



### 16. 函数 - 模板



### 17. 类 - 模板



### 18. 智能指针



### 19. STL (Standard Template Library)

#### 1. 容器



#### 2. 迭代器



#### 3. 算法



### 20. C++ 11

#### 1. 并发编程



#### 2. 模板元



### 21. Boost 开源库



### 22. 读书笔记

- 高级 C/C++ 编译技术

### 23. 面试题

- xxx



## iOS

### thread



### runloop



### runtime



### 组件化



### 包体积



### cocoapods

#### 1. cocoapods 使用

- [01 - cocoapods 工作原理](ios/cocoapods/01/01/01.md)
- [02 - cocoapods 组成结构](ios/cocoapods/01/02/02.md)
- [03 - Podfile](ios/cocoapods/01/02/02.md)
- [04 - xx.podspec](ios/cocoapods/01/02.md)
- [05 - xcodeproj](ios/cocoapods/01/02.md)
- [06 - 替换 cocoapods 一些方法实现](ios/cocoapods/01/02.md)
- [07 - cocoapods plugin](ios/cocoapods/01/02.md)

#### 2. Xcodeproj



### devops

#### 1. 马甲包

- [01 - 马甲包 - 工程配置修改](ios/devops/majiabao/01.md)
- [02 - 马甲包 - 代码同步](ios/devops/majiabao/02.md)

#### 2. 自动化系统

- [01 - 通用构建系统设计 (iOS 与 Android)](ios/devops/ci/01.md)
- [02 - 通用 CI 处理层](ios/devops/ci/01.md)
- [03 - app 版本 更新](ios/devops/ci/01.md)
- [04 - app 版本 发布](ios/devops/ci/01.md)
- [05 - app 构建出包](ios/devops/ci/01.md)
- [06 - app appstore 商店包](ios/devops/ci/01.md)
- [07 - app enterprise 企业包](ios/devops/ci/01.md)
- [08 - module (组件) 列表](ios/devops/ci/01.md)
- [09 - module (组件) 发布](ios/devops/ci/01.md)
- [10 - module (组件) 打包](ios/devops/ci/01.md)
- [11 - module (组件) 集成](ios/devops/ci/01.md)
- [12 - dSYM 上传](ios/devops/ci/01.md)

#### 3. MR (Gitlab Merge Request) Pipeline

- [01 - 基于 `.gitlab-ci.yml` Pipeline 架构设计](ios/devops/pipeline/01/README.md)
- [02 - sonar swift](ios/devops/pipeline/02/README.md)

### fastlane

#### 00. fastlane

- [01 - Configuring fastlane](ios/fastlane/00/README.md)

#### 01. Fastfile 基础

- [01 - lane 定义、调用](ios/fastlane/01/01/01/README.md)
- [02 - lane 详细使用](ios/fastlane/01/01/02/README.md)
- [03 - lane private lane](ios/fastlane/01/01/03/README.md)
- [04 - lane 每一项的耗时统计](ios/fastlane/01/01/04/README.md)
- [05 - lane hooks](ios/fastlane/01/01/05/README.md)
- [06 - lane 中调用 send](ios/fastlane/01/01/06/README.md)
- [07 - ENV 环境变量](ios/fastlane/01/02/README.md)
- [08 - Appfile Configuration](ios/fastlane/01/03/README.md)
- [09 - fastlane_require() 替代 require() 载入 第三方 gem](ios/fastlane/01/04/README.md)
- [10 - shell 代码, 捕获 lane 异常退出](ios/fastlane/01/05/README.md)
- [11 - run command](ios/fastlane/01/06/README.md)

#### 02. action

- [01 - lane 与 action 工作目录 (Directory behavior) ==不一样==](ios/fastlane/02/01/README.md)
- [02 - 自定义 action、运行 action](ios/fastlane/02/02/README.md)
- [03 - action 参数类型](ios/fastlane/02/03/README.md)
- [04 - actionA ==传递== 数据给 actionB](ios/fastlane/02/04/README.md)
- [05 - action 无法在 ==其他 fastlane 项目中复用==](ios/fastlane/02/05/README.md)
- [06 - fastlane ==禁止== actionA 中, 调用 actionB](ios/fastlane/02/06/README.md)
- [07 - 指定本地 action 路径](ios/fastlane/02/07/README.md)
- [08 - Fastlane Helper](ios/fastlane/02/08/README.md)
- [09 - action 编写总结 (适用于 plugin)](ios/fastlane/02/09/README.md)

#### 03. plugin

- [01 - plugin 解决 action 无法复用的问题](ios/fastlane/03/01/README.md)
- [02 - plugin 到底是什么?](ios/fastlane/03/02/README.md)
- [03 - plugin 开发、发布、使用](ios/fastlane/03/03/README.md)
- [04 - plugin 使用记录](ios/fastlane/03/04/README.md)
- [05 - fastlane ==禁止== pluginA 中, 调用 pluginB](ios/fastlane/02/06/README.md)

#### 04. Fastfile 高级

- [01 - import ==local== Fastfile](ios/fastlane/04/01/README.md)
- [02 - import ==remote== Fastfile](ios/fastlane/04/02/README.md)
- [03 - 编写 ==远程重用== Fastfile 注意点](ios/fastlane/04/03/README.md)
- [04 - 封装 ==可重用== 的 ==lane==](ios/fastlane/04/04/README.md)
- [05 - action/plugin/lane 选择](ios/fastlane/04/05.md)

#### 05. fastlane 作为独立的脚本项目

- [fastlane 作为独立的脚本项目](ios/fastlane/05/README.md)



## ruby

### 1. 😀 Ruby 这门语言

- [点击我](ruby/01/01.md)

### 2. 😁 Ruby 学习中即将接触到的各种概念

- [点击我](ruby/02/01.md)

### 3. 😂 使用 RVM 管理 Ruby 开发环境

- [点击我](ruby/03/01.md)

### 4. 😨 令初学者疑惑的 require: cannot load such file -- xxx (LoadError)

- [点击我](ruby/04/01.md)

### 5. 🤣 Bundler : 管理 gem 依赖

- [01 - 一个 Ruby 软件包](ruby/05/01/README.md)
- [02 - Bundler 就是 这些 Ruby 软件的 包管理器](ruby/05/02/README.md)
- [03 - Gemfile 语法](ruby/05/03/README.md)
- [04 - bundle install](ruby/05/04/README.md)
- [05 - bundle update](ruby/05/05/README.md)
- [06 - bundle exec](ruby/05/06/README.md)
- [07 - bundler Shelling Out](ruby/05/07/README.md)
- [08 - 其他](ruby/05/08/README.md)

### 6. 😇 Ruby 基础语法

#### 1. 常用数据类型

- [01 - String](ruby/06/01/01.md)
- [02 - Bool](ruby/06/01/02.md)
- [03 - nil](ruby/06/01/03.md)
- [04 - Symbol](ruby/06/01/04.md)
- [05 - Array - 01 - 基础](ruby/06/01/05/01.md)
- [05 - Array - 02 - 高阶](ruby/06/01/05/02.md)
- [06 - Hash - 01 - 基础](ruby/06/01/06/01.md)
- [06 - Hash - 01 - 高阶](ruby/06/01/06/02.md)
- [07 - Struct](ruby/06/01/07.md)

#### 2. 变量

- [点击我](ruby/06/02/01.md)

#### 3. 常用运算符

- [01 - 单引号 vs 双引号](ruby/06/03/01.md)
- [02 - % 运算符](ruby/06/03/02.md)

#### 4. 流程控制

if/else/switch/times/break/continue ….

#### 5. 方法

- [01 - 全局 (global) 方法](ruby/06/05/01.md)
- [02 - 对象 (instance) 方法](ruby/06/05/02.md)
- [03 - 类 (class) 方法](ruby/06/05/03.md)
- [04 - engin class 方法](ruby/08/01.md)
- [05 - 方法参数](ruby/06/05/05.md)
- [06 - 获取方法](ruby/06/05/06.md)

#### 6. 代码块

- [点击我](ruby/06/06/01.md)

#### 7. 方法 与 代码块

- [点击我](ruby/06/07/01.md)

#### 8. 类与对象

- [01 - 面向对象基础](ruby/06/08/01.md)
- [02 - 对象的拷贝](ruby/06/08/02.md)
- [03 - 对象比较](ruby/06/08/03.md)
- [04 - 继承](ruby/06/08/04.md)
- [05 - 异常](ruby/06/08/05.md)

### 7. 😄 模块 (module)

- [01 - 基础使用](ruby/07/01.md)
- [02- include、extend、prepend](ruby/07/02.md)
- [03 - Gitlab Ruby API 封装](ruby/07/03.md)
- [04 - require、require_relative、load、autoload](ruby/07/04.md)

### 8. 😄 Meta Programming

- [01 - engin (singleton) class](ruby/08/01.md)
- [02 - send](ruby/08/02.md)
- [03 - method_missing](ruby/08/03.md)
- [04 - forwardable::def_delegator()](ruby/08/04.md)
- [05 - 各种钩子 (hook)](ruby/08/05.md)
- [06 - DSL](ruby/08/06.md)
- [07 - patch - 01 - patch 生效的条件](ruby/08/07/01.md)
- [07 - patch - 02 - 打开类, 重写方法实现](ruby/08/07/02.md)
- [07 - patch - 03 - open class + prepend module](ruby/08/07/03.md)
- [07 - patch - 04 - refine class + module + using(限制作用域)](ruby/08/07/04.md)
- [07 - patch - 05 - instance_method + define_method](ruby/08/07/05.md)
- [07 - patch - 06 - define_method + alias_method + send](ruby/08/07/06.md)
- [07 - patch - 07 - forwardable + def_delegator](ruby/08/07/07.md)
- [07 - patch - 08 - 继承 + alias](ruby/08/07/08.md)
- [07 - patch - 09 - undef + define_method](ruby/08/07/09.md)
- [07 - patch - 10 - remove_method/undef_method](ruby/08/07/10.md)
- [07 - patch - 11 - singleton methods](ruby/08/07/11.md)

### 9. 😅 Ruby 设计模式

#### 1. SOLID 原则

- [SOLID 原则](ruby/09/01.md)

#### 2. 设计模式

- [01 - 单例](ruby/09/02/01.md)
- [02 - 代理](ruby/09/02/02.md)

### 10. 😉 手把手教你开发并上线一个 Ruby 软件

- 本地的 开发、调试
- 发布到 rubygems.org
- 本地 调试 Ruby 开源库

### 11. 😅 开源项目

#### 1. gitlab ruby api

- [gitlab ruby api](ruby/10/README.md)



## python





## go



## linux 工具

### 1. make





## linux 系统编程

### 1. 系统调用 syscall

- [点击我](linux_02/01/README.md)

### 2. 文件 I/O

- [01 - stdio 与 linux io](linux_02/02/01/README.md)
- [02 - open、read、write](linux_02/02/02/README.md)
- [03 - readv、writev](linux_02/02/03/README.md)
- [04 - lseek](linux_02/02/04/README.md)
- [05 - dir](linux_02/02/05/README.md)
- [06 - lstat](linux_02/02/06/README.md)
- [07 - fcntl](linux_02/02/07/README.md)
- [08 - dup、dup2](linux_02/02/08/README.md)

### 3. 进程

#### 1. 进程

- [01 - 虚拟地址空间](/Users/xiongzenghui/Desktop/daydayup/linux_02/03/01/01/README.md)
- [02 - 环境变量](/Users/xiongzenghui/Desktop/daydayup/linux_02/03/01/02/README.md)
- [03 - 函数调用栈](/Users/xiongzenghui/Desktop/daydayup/linux_02/03/01/03/README.md)
- [04 - 进程在 linux 内核源码描述](/Users/xiongzenghui/Desktop/daydayup/linux_02/03/01/04/README.md)
- [05 - exit() 与 `_exit()`_区别](/Users/xiongzenghui/Desktop/daydayup/linux_02/03/01/05/README.md)

#### 2. fork() 创建 子进程

- [点击我](/Users/xiongzenghui/Desktop/daydayup/linux_02/03/02/README.md)

#### 3. 僵尸进程 vs 孤儿进程

- [点击我](/Users/xiongzenghui/Desktop/daydayup/linux_02/03/03/README.md)

#### 4. wait 回收 子进程

- [点击我](/Users/xiongzenghui/Desktop/daydayup/linux_02/03/04/README.md)

#### 5. 守护进程 (daemon)

- [点击我](/Users/xiongzenghui/Desktop/daydayup/linux_02/03/05/README.md)

#### 6. CPU 进程 亲和力

- [点击我](/Users/xiongzenghui/Desktop/daydayup/linux_02/03/06/README.md)

#### 7. execl 函数簇, 执行 外部的 可执行文件

- [点击我](/Users/xiongzenghui/Desktop/daydayup/linux_02/03/07/README.md)

#### 8. 进程 rlimit

- [点击我](/Users/xiongzenghui/Desktop/daydayup/linux_02/03/08/README.md)

#### 10. 进程间 数据共享 存在的问题



#### 11. 进程间 通信(ipc) - Unix api



#### 12. 进程间 通信(ipc) - SystemV api



#### 13. 进程间 通信(ipc) - Posix api



#### 14. 进程间 通信(ipc) - Socket



#### 15. 进程间 同步与互斥(sync)

### 4. 线程

#### 1. 线程间 通信



#### 2. 线程间 同步与互斥



#### 3. 线程池



### 5. 信号 signal



### 6. socket



### 7. I/O 模型



### 参考资料

- UNIX 环境高级编程
- UNIX 系统编程手册 (上下两册)



## LLVM





## 微信交流与打赏

如果你有想参与或者交流，可以联系我哈 ~

<img src="wexin_01.jpg" width="480" height="480" />



如果你觉得这些内容对你有帮助，手头也比较宽裕，那么可以考虑打赏一下，这样会更新的更快 ~

<img src="wexin_02.jpg" width="380" height="380" />

