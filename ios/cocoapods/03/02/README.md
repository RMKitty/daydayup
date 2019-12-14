[TOC]



## 1. cocoapods-binary : 提供 ==pre-compile== set of pod

### 1. 修改 App 项目的 Podfile

```
diff --git a/Podfile b/Podfile
index 95cd2b1..f5a6aae 100644
--- a/Podfile
+++ b/Podfile
@@ -1,10 +1,12 @@
 # Uncomment the next line to define a global platform for your project
 # platform :ios, '9.0'

+plugin 'cocoapods-binary'
+
 target 'XZHApp' do
   use_frameworks!

-  pod 'AFNetworking'
+  pod 'AFNetworking', :binary => true
   pod 'YYCache'
   pod 'SDWebImage'
 end
```

### 2. Gemfile 添加 cocoapods-binary 插件依赖

```
diff --git a/Gemfile b/Gemfile
index d98dd99..a3de599 100644
--- a/Gemfile
+++ b/Gemfile
@@ -1,3 +1,4 @@
 source 'https://rubygems.org'

-gem 'cocoapods', '>=1.7.5', '<1.8'
\ No newline at end of file
+gem 'cocoapods', '>=1.7.5', '<1.8'
+gem 'cocoapods-binary'
\ No newline at end of file
```

### 3. bundle install 安装依赖

```
╰─➤  bundle install
Fetching gem metadata from https://rubygems.org/..........
Resolving dependencies...
................


Fetching cocoapods-binary 0.4.4
Installing cocoapods-binary 0.4.4
Bundle complete! 2 Gemfile dependencies, 33 gems now installed.
Use `bundle info [gemname]` to see where a bundled gem is installed.
```

### 4. bundle exec pod install

```
╭─xiongzenghui@xiongzenghuideMacBook-Pro.local ~/Desktop/XZHApp ‹ruby-2.4.1› ‹master›
╰─➤  bundle exec pod install
🚀  Prebuild frameworks
Analyzing dependencies
Downloading dependencies
Installing AFNetworking (3.2.1)
Generating Pods project
Sending stats
Prebuild frameworks (total 1)
Prebuilding AFNetworking...

🤖  Pod Install
Analyzing dependencies
Downloading dependencies
Installing AFNetworking (3.2.1)
Using SDWebImage (5.1.0)
Using YYCache (1.0.4)
Generating Pods project
Integrating client project
Sending stats
Pod installation complete! There are 3 dependencies from the Podfile and 3 total pods installed.

[!] Automatically assigning platform `ios` with version `12.2` on target `XZHApp` because no platform was specified. Please specify a platform for this target in your Podfile. See `https://guides.cocoapods.org/syntax/podfile.html#platform`.

[!] Automatically assigning platform `ios` with version `12.2` on target `XZHApp` because no platform was specified. Please specify a platform for this target in your Podfile. See `https://guides.cocoapods.org/syntax/podfile.html#platform`.
```

出现的日志信息

```
Prebuild frameworks (total 1)
Prebuilding AFNetworking...
```

### 5. 打开 workspace , 可以看到已经 ==提前构建== 好的 ==AFNetworking.framework==

![](Snip20190918_20.png)

AFNetworking.framework 所在路径:

```
╭─xiongzenghui@xiongzenghuideMacBook-Pro.local ~/Desktop/XZHApp/Pods/_Prebuild/GeneratedFrameworks/AFNetworking ‹ruby-2.4.1› ‹master*›
╰─➤  ll
total 0
drwxr-xr-x  6 xiongzenghui  staff   192B  9 18 22:56 AFNetworking.framework
drwxr-xr-x  3 xiongzenghui  staff    96B  9 18 22:56 AFNetworking.framework.dSYM
```

### 6. 总结

- 需要修改 **Podfile** , 但也可以在运行时修改 pod 设置
- 是在 pod install 的时候, 提前对 AFNetworking 源码进行构建, 生成 framework
- 但是感觉很鸡肋, 还是要占用整个 App 工程构建时间, 并不能起到 **缩短构建** 时间的作用
- 但是可以学习下, 如何通过 **cocoapods plugin** 做到 **hook pod install**  过程的



## 2. cocoapods-binary 项目结构

```
─xiongzenghui@xiongzenghuideMacBook-Pro.local ~/collect_cocoapods_plugins/cocoapods-binary ‹ruby-2.4.1› ‹master›
╰─➤  tree
.
├── Gemfile
├── LICENSE.txt
├── README.md
├── Rakefile
├── cocoapods-binary.gemspec
├── demo
│   ├── Gemfile
│   ├── Gemfile.lock
│   ├── Podfile
│   ├── Podfile.lock
│   ├── demo
│   │   ├── AppDelegate.swift
│   │   ├── Base.lproj
│   │   │   └── LaunchScreen.storyboard
│   │   ├── Info.plist
│   │   ├── ViewController.swift
│   │   └── demos
│   │       └── BDWebImage_demo.m
│   ├── demo.xcodeproj
│   │   └── project.pbxproj
│   └── demo.xcworkspace
│       ├── contents.xcworkspacedata
│       └── xcshareddata
│           └── IDEWorkspaceChecks.plist
├── lib
│   ├── cocoapods-binary
│   │   ├── Integration.rb
│   │   ├── Main.rb
│   │   ├── Prebuild.rb
│   │   ├── gem_version.rb
│   │   ├── helper
│   │   │   ├── feature_switches.rb
│   │   │   ├── names.rb
│   │   │   ├── passer.rb
│   │   │   ├── podfile_options.rb
│   │   │   ├── prebuild_sandbox.rb
│   │   │   └── target_checker.rb
│   │   ├── rome
│   │   │   └── build_framework.rb
│   │   └── tool
│   │       └── tool.rb
│   ├── cocoapods-binary.rb
│   └── cocoapods_plugin.rb
├── spec
│   └── spec_helper.rb
└── test
    ├── Binary
    │   ├── AppDelegate.swift
    │   ├── Info.plist
    │   ├── ViewController.swift
    │   └── import.swift
    ├── Binary.xcodeproj
    │   ├── project.pbxproj
    │   ├── project.xcworkspace
    │   │   ├── contents.xcworkspacedata
    │   │   └── xcshareddata
    │   │       └── IDEWorkspaceChecks.plist
    │   └── xcshareddata
    │       └── xcschemes
    │           └── Binary.xcscheme
    ├── BinaryWatch
    │   ├── Assets.xcassets
    │   │   ├── AppIcon.appiconset
    │   │   │   └── Contents.json
    │   │   └── Contents.json
    │   ├── Base.lproj
    │   │   └── Interface.storyboard
    │   └── Info.plist
    ├── BinaryWatch\ Extension
    │   ├── Assets.xcassets
    │   │   ├── Complication.complicationset
    │   │   │   ├── Circular.imageset
    │   │   │   │   └── Contents.json
    │   │   │   ├── Contents.json
    │   │   │   ├── Extra\ Large.imageset
    │   │   │   │   └── Contents.json
    │   │   │   ├── Modular.imageset
    │   │   │   │   └── Contents.json
    │   │   │   └── Utilitarian.imageset
    │   │   │       └── Contents.json
    │   │   └── Contents.json
    │   ├── ExtensionDelegate.swift
    │   ├── Info.plist
    │   ├── InterfaceController.swift
    │   └── import.swift
    ├── Gemfile
    ├── change_podfile.py
    ├── logo.png
    ├── release_version.rb
    └── test.sh

31 directories, 59 files
```



## 3. cocoapods-binary.gemspec

```ruby
# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods-binary/gem_version.rb'

Gem::Specification.new do |spec|
  spec.name          = 'cocoapods-binary'
  spec.version       = CocoapodsBinary::VERSION
  spec.authors       = ['leavez']
  spec.email         = ['gaojiji@gmail.com']
  spec.description   = %q{integrate pods in form of prebuilt frameworks conveniently, reducing compile time}
  spec.summary       = %q{A CocoaPods plugin to integrate pods in form of prebuilt frameworks, not source code, by adding just one flag in podfile. Speed up compiling dramatically.}
  spec.homepage      = 'https://github.com/leavez/cocoapods-binary'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/).reject{|f| f.start_with?("test/") || f.start_with?('demo/')}
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency "cocoapods", ">= 1.5.0", "< 2.0"
  spec.add_dependency "fourflusher", "~> 2.0"
  spec.add_dependency "xcpretty", "~> 0.3.0"

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
```

依赖了 cocoapods、fourflusher、xcpretty 这三个 gem



## 4. cocoapods-binary/lib

```
╭─xiongzenghui@xiongzenghuideMacBook-Pro.local ~/collect_cocoapods_plugins/cocoapods-binary/lib ‹ruby-2.4.1› ‹master›
╰─➤  ll
total 16
drwxr-xr-x  9 xiongzenghui  staff   288B  9 17 23:21 cocoapods-binary
-rw-r--r--  1 xiongzenghui  staff    39B  9 17 23:21 cocoapods-binary.rb
-rw-r--r--  1 xiongzenghui  staff    33B  9 17 23:21 cocoapods_plugin.rb
```



## 5. cocoapods-binary/lib/cocoapods-binary.rb

```ruby
require 'cocoapods-binary/gem_version'
```

导入插件的 **版本号**



## 6. cocoapods-binary/lib/cocoapods_plugin.rb

```ruby
require 'cocoapods-binary/Main'
```

导入插件的 **执行入口**



## 7. cocoapods-binary/lib/cocoapods-binary

```
╭─xiongzenghui@xiongzenghuideMacBook-Pro.local ~/collect_cocoapods_plugins/cocoapods-binary/lib/cocoapods-binary ‹ruby-2.4.1› ‹master›
╰─➤  ll
total 72
-rw-r--r--  1 xiongzenghui  staff    11K  9 17 23:21 Integration.rb
-rw-r--r--  1 xiongzenghui  staff   5.9K  9 17 23:21 Main.rb
-rw-r--r--  1 xiongzenghui  staff   9.3K  9 17 23:21 Prebuild.rb
-rw-r--r--  1 xiongzenghui  staff    49B  9 17 23:21 gem_version.rb
drwxr-xr-x  8 xiongzenghui  staff   256B  9 17 23:21 helper
drwxr-xr-x  3 xiongzenghui  staff    96B  9 17 23:21 rome
drwxr-xr-x  3 xiongzenghui  staff    96B  9 17 23:21 tool
```

```
╭─xiongzenghui@xiongzenghuideMacBook-Pro.local ~/collect_cocoapods_plugins/cocoapods-binary/lib/cocoapods-binary ‹ruby-2.4.1› ‹master›
╰─➤  tree
.
├── Integration.rb
├── Main.rb
├── Prebuild.rb
├── gem_version.rb
├── helper
│   ├── feature_switches.rb
│   ├── names.rb
│   ├── passer.rb
│   ├── podfile_options.rb
│   ├── prebuild_sandbox.rb
│   └── target_checker.rb
├── rome
│   └── build_framework.rb
└── tool
    └── tool.rb

3 directories, 12 files
```



## 8. cocoapods-binary/lib/cocoapods-binary/Main.rb

```ruby

```


## 5. cocoapods-binary/lib/cocoapods-binary

```ruby

```