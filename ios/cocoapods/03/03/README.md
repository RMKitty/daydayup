[TOC]




## 1. pod plugins create <插件名> : 创建插件工程

```
╭─xiongzenghui@xiongzenghuideMacBook-Pro.local ~/collect_cocoapods_plugins ‹ruby-2.4.1›
╰─➤  pod plugins create xzh                                                                                                                                      1 ↵
-> Creating `cocoapods-xzh` plugin

[!] using template 'https://github.com/CocoaPods/cocoapods-plugin-template.git'
-> Configuring template
Configuring cocoapods-xzh
user name:xiongzenghui
user email:zxcvb1234001@163.com
year:2019

[!] Don't forget to create a Pull Request on https://github.com/CocoaPods/cocoapods-plugins
 to add your plugin to the plugins.json file once it is released!
```

查看创建的插件工程

```
╭─xiongzenghui@xiongzenghuideMacBook-Pro.local ~/collect_cocoapods_plugins ‹ruby-2.4.1›
╰─➤  cd cocoapods-xzh
```

```
╭─xiongzenghui@xiongzenghuideMacBook-Pro.local ~/collect_cocoapods_plugins/cocoapods-xzh ‹ruby-2.4.1› ‹master›
╰─➤  tree
.
├── Gemfile
├── LICENSE.txt
├── README.md
├── Rakefile
├── cocoapods-xzh.gemspec
├── lib
│   ├── cocoapods-xzh
│   │   ├── command
│   │   │   └── xzh.rb
│   │   ├── command.rb
│   │   └── gem_version.rb
│   ├── cocoapods-xzh.rb
│   └── cocoapods_plugin.rb
└── spec
    ├── command
    │   └── xzh_spec.rb
    └── spec_helper.rb

5 directories, 12 files
```



## 2. 运行 plugin 插件工程

### 1. bundle install 安装依赖

```
╭─xiongzenghui@xiongzenghuideMacBook-Pro.local ~/collect_cocoapods_plugins/cocoapods-xzh ‹ruby-2.4.1› ‹master›
╰─➤  bundle install
Using rake 12.3.3
Using CFPropertyList 3.0.1
Using concurrent-ruby 1.1.5
................................


Using prettybacon 0.0.2
Bundle complete! 8 Gemfile dependencies, 37 gems now installed.
Use `bundle info [gemname]` to see where a bundled gem is installed.
```

### 2. 直接 pod

```
╭─xiongzenghui@xiongzenghuideMacBook-Pro.local ~/collect_cocoapods_plugins/cocoapods-xzh ‹ruby-2.4.1› ‹master›
╰─➤  pod
Usage:

    $ pod COMMAND

      CocoaPods, the Cocoa library package manager.

Commands:

    + cache         Manipulate the CocoaPods cache
    + deintegrate   Deintegrate CocoaPods from your project
    + env           Display pod environment
    + init          Generate a Podfile for the current directory
    + install       Install project dependencies according to versions from a
                    Podfile.lock
    + ipc           Inter-process communication
    + lib           Develop pods
    + list          List pods
    + outdated      Show outdated project dependencies
    + package       Package a podspec into a static library.
    + plugins       Show available CocoaPods plugins
    + repo          Manage spec-repositories
    + search        Search for pods
    + setup         Setup the CocoaPods environment
    + spec          Manage pod specs
    + trunk         Interact with the CocoaPods API (e.g. publishing new specs)
    + try           Try a Pod!
    + update        Update outdated project dependencies and create new Podfile.lock

Options:

    --silent        Show nothing
    --version       Show the version of the tool
    --verbose       Show more debugging information
    --no-ansi       Show output without ANSI codes
    --help          Show help banner of specified command
```

- 发现是没有我们自己的 插件工程的 sub command **xzh** 的
- 因为这样直接运行 pod , 实际上并不是运行我们的 **插件工程/Gemfile** 依赖安装的 cocoapods, 也就是不在 **我们的 bundle** 内部

### 3. 一定要 ==bundle exec== pod

```
╭─xiongzenghui@xiongzenghuideMacBook-Pro.local ~/collect_cocoapods_plugins/cocoapods-xzh ‹ruby-2.4.1› ‹master›
╰─➤  bundle exec pod
[!] The specification of arguments as a string has been deprecated Pod::Command::Xzh: `NAME`
Usage:

    $ pod COMMAND

      CocoaPods, the Cocoa library package manager.

Commands:

    + cache         Manipulate the CocoaPods cache
    + deintegrate   Deintegrate CocoaPods from your project
    + env           Display pod environment
    + init          Generate a Podfile for the current directory
    + install       Install project dependencies according to versions from a
                    Podfile.lock
    + ipc           Inter-process communication
    + lib           Develop pods
    + list          List pods
    + outdated      Show outdated project dependencies
    + plugins       Show available CocoaPods plugins
    + repo          Manage spec-repositories
    + search        Search for pods
    + setup         Setup the CocoaPods environment
    + spec          Manage pod specs
    + trunk         Interact with the CocoaPods API (e.g. publishing new specs)
    + try           Try a Pod!
    + update        Update outdated project dependencies and create new Podfile.lock
    + xzh           Short description of cocoapods-xzh.

Options:

    --silent        Show nothing
    --version       Show the version of the tool
    --verbose       Show more debugging information
    --no-ansi       Show output without ANSI codes
    --help          Show help banner of specified command
```

这个时候已经有我们自己的 plugin 工程的 sub command **xzh** 了.

```
+ xzh           Short description of cocoapods-xzh.
```



## 3. App 工程, 接入使用 plugin

[惦记我](../01/README.md)







## 4. 插件工程 替换 cocoapods 方法的实现




