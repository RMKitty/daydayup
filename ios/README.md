[TOC]



## 1. multi thread

- [01 - 进程、线程、并行、并发](multi_thread/01-init/README.md)
- [02 - 你能接触到的主流 多线程 API](multi_thread/02-thread-api/README.md)
- [03- 线程安全 (Thread Safety) 出现的场景](multi_thread/03-safe-generate/README.md)
- [04 - 脱离 iOS 了解更多的 多线程](multi_thread/04-thread/README.md)
- [05 - 参考开源库如何解决 线程安全](multi_thread/05-opensource/README.md)
- [06 - 线程安全 (Thread Safety) 解决](multi_thread/06-safe-solved/README.md)



## 2. memeory

- [01 - 引用计数器](memory/01/README.md)
- [02 - zombie 对象](memory/02/README.md)
- [03 - object ownership](memory/03/README.md)
- [04 - @property](memory/04/README.md)
- [05 - ](memory/05/README.md)
- [06 - ](memory/06/README.md)
- [07 - ](memory/07/README.md)
- [08 - ](memory/08/README.md)
- [09 - ](memory/09/README.md)
- [10 - ](memory/10/README.md)
- [11 - ](memory/11/README.md)
- [11 - ](memory/11/README.md)
- [11 - ](memory/11/README.md)
- [11 - ](memory/11/README.md)
- [11 - ](memory/11/README.md)
- [11 - ](memory/11/README.md)



## 2. runloop





## 3. runtime





## 4. 组件化





## 5. 包体积





## 6. CocoaPods

### 1. cocoapods 使用

- [01 - cocoapods 工作原理](cocoapods/01/01/01.md)
- [02 - cocoapods 组成结构](cocoapods/01/02/02.md)
- [03 - Podfile](cocoapods/01/03.md)
- [04 - xx.podspec](cocoapods/01/04.md)

### 2. 替换 cocoapods 方法实现

- [01](cocoapods/02/01.md)

### 3. Plugin

- [01 - cocoapods plugin](cocoapods/03/01/README.md)
- [02 - cocoapods-binary 源码](cocoapods/03/02/README.md)
- [03 - 开发一个 plugin](cocoapods/03/03/README.md)
- [04 - plugin `pod process hook`](cocoapods/03/04/README.md)
- [05 - plugin `替换 CocoaPods 方法实现`](cocoapods/03/05/README.md)
- [99 - 二进制化](cocoapods/03/04/README.md)

### 2. Xcodeproj





## 7. fastlane

### 00. fastlane

- [01 - Configuring fastlane](fastlane/00/README.md)

### 01. Fastfile 基础

- [01 - lane 定义、调用](fastlane/01/01/01/README.md)
- [02 - lane 详细使用](fastlane/01/01/02/README.md)
- [03 - lane private lane](fastlane/01/01/03/README.md)
- [04 - lane 每一项的耗时统计](fastlane/01/01/04/README.md)
- [05 - lane hooks](fastlane/01/01/05/README.md)
- [06 - lane 中调用 send](fastlane/01/01/06/README.md)
- [07 - ENV 环境变量](fastlane/01/02/README.md)
- [08 - Appfile Configuration](fastlane/01/03/README.md)
- [09 - fastlane_require() 替代 require() 载入 第三方 gem](fastlane/01/04/README.md)
- [10 - shell 代码, 捕获 lane 异常退出](fastlane/01/05/README.md)
- [11 - run command](fastlane/01/06/README.md)

### 02. action

- [01 - lane 与 action 工作目录 (Directory behavior) ==不一样==](fastlane/02/01/README.md)
- [02 - 自定义 action、运行 action](fastlane/02/02/README.md)
- [03 - action 参数类型](fastlane/02/03/README.md)
- [04 - actionA ==传递== 数据给 actionB](fastlane/02/04/README.md)
- [05 - action 无法在 ==其他 fastlane 项目中复用==](fastlane/02/05/README.md)
- [06 - fastlane ==禁止== actionA 中, 调用 actionB](fastlane/02/06/README.md)
- [07 - 指定本地 action 路径](fastlane/02/07/README.md)
- [08 - Fastlane Helper](fastlane/02/08/README.md)
- [09 - action 编写总结 (适用于 plugin)](fastlane/02/09/README.md)

### 03. plugin

- [01 - plugin 解决 action 无法复用的问题](fastlane/03/01/README.md)
- [02 - plugin 到底是什么?](fastlane/03/02/README.md)
- [03 - plugin 开发、发布、使用](fastlane/03/03/README.md)
- [04 - plugin 使用记录](fastlane/03/04/README.md)
- [05 - fastlane ==禁止== pluginA 中, 调用 pluginB](fastlane/02/06/README.md)

### 04. Fastfile 高级

- [01 - import ==local== Fastfile](fastlane/04/01/README.md)
- [02 - import ==remote== Fastfile](fastlane/04/02/README.md)
- [03 - 编写 ==远程重用== Fastfile 注意点](fastlane/04/03/README.md)
- [04 - 封装 ==可重用== 的 ==lane==](fastlane/04/04/README.md)
- [05 - action/plugin/lane 选择](fastlane/04/05.md)

### 05. fastlane 作为独立的脚本项目

- [fastlane 作为独立的脚本项目](fastlane/05/README.md)



## 8. devops

### 1. 马甲包

- [01 - 马甲包 - 工程配置修改](devops/majiabao/01.md)
- [02 - 马甲包 - 代码同步](devops/majiabao/02.md)

### 2. 自动化系统

- [01 - 通用构建系统设计 (iOS 与 Android)](devops/ci/01.md)
- [02 - 通用 CI 处理层](devops/ci/01.md)
- [03 - app 版本 更新](devops/ci/01.md)
- [04 - app 版本 发布](devops/ci/01.md)
- [05 - app 构建出包](devops/ci/01.md)
- [06 - app appstore 商店包](devops/ci/01.md)
- [07 - app enterprise 企业包](devops/ci/01.md)
- [08 - module (组件) 列表](devops/ci/01.md)
- [09 - module (组件) 发布](devops/ci/01.md)
- [10 - module (组件) 打包](devops/ci/01.md)
- [11 - module (组件) 集成](devops/ci/01.md)
- [12 - dSYM 上传](devops/ci/01.md)

### 3. MR (Gitlab Merge Request) Pipeline

- [01 - 基于 `.gitlab-ci.yml` Pipeline 架构设计](devops/pipeline/01/README.md)
- [02 - sonar swift](devops/pipeline/02/README.md)

