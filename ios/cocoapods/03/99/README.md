[TOC]




## 1. 生产 static framework (都是基于 cocoapods)

### 1. 方案1: 借助一个 ==Example App== 工程

- 1) 根据 组件的 **xx.podspec** 动态生成 **Podfile**
- 2) 生成一个新的 **Example App 工程**, 可参考 [cocoapods-generate](https://github.com/zhzhy/cocoapods-generator) 插件实现
- 3) 按照 Podfile 进行 pod install 组装 pod 组件 的源码
- 4) 对 **Example App 工程** 使用 xcodebuild 构建得到 **pod 组件** 的 二进制

### 2. 方案2: 借助一个 ==主项目 App== 工程

- 1) 需要将 **真实 App 项目**, 改造为一个 通用的 **壳工程** (shell project)
- 2) 然后以 **源码** 形式, 引入 需要生成 二进制 的 **pod 组件**
- 3) 对 **真实 App 项目** 使用 xcodebuild 构建得到 **pod 组件** 的 二进制

### 3. 两者对比

#### 1. 第一种 好处

- **第一种** 较为 **通用** , 因为 **第二种** 会将 **组件生成二进制** 慢慢限死在 **自己的 App 项目** 环境中
- **第一种** 也比 第二种 **节省时间** , 因为不需要额外编译 **其他不相关** 的 pod 组件源码

#### 2. 第二种 好处

- 但是 **第一种** 在打 **动态库** 和 **podspec 中存在多级 subspec 依赖** 情况时, 处理较为复杂
- 在 **xcode 版本升级** 时, 需要一次性对 **所有的 pod 组件源码** 重新生成 二进制
- 因为 **强关联 主 app 项目/branch** 环境, 所以肯定不会出现最终 **app 发版** 时候 **编译失败**、**链接失败** 等情况
  
### 4. 需要 ==强关联 主项目 App 工程== 的情况

- 需要保证 pod 组件 将来, 发布到 **主 app 项目 git 仓库** 中的 **那一个分支** 能 **编译通过**
  - release_6.10.0
  - release_6.10.1
  - ....
  - release_6.13.0

- 无法像 AFNetworking 这样特别 **通用、独立** 进行构建的 pod 组件

- **内部业务代码耦合度较高** 的 pod 组件, 比如 **业务组件** 这种就很难 **通用、独立**, 多少会对 **主 App 工程** 有一定的 **依赖**




## 2. 打包 static framework




## 3. 存储 static framework




## 4. 预处理、宏定义、条件编译





## 参考文章

https://dmanager.github.io/ios/2019/01/21/%E5%9F%BA%E4%BA%8ECocoaPods%E7%9A%84%E7%BB%84%E4%BB%B6%E4%BA%8C%E8%BF%9B%E5%88%B6%E5%8C%96%E5%AE%9E%E8%B7%B5/

