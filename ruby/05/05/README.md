[TOC]



## 1. bundle install 之后会有一句提示

```
╰─± bundle install
Using rake 13.0.1
Using CFPropertyList 3.0.2
Using concurrent-ruby 1.1.5
Using i18n 0.9.5
Using minitest 5.13.0

...................

Bundle complete! 38 Gemfile dependencies, 149 gems now installed.
Use `bundle info [gemname]` to see where a bundled gem is installed.
```

最后一句, 告诉你可以使用 **bundle info** 查看某一个 **ruby gem 安装在哪里**.



## 2. 查看 cocoapods 安装在哪里

```
╰─± bundle info cocoapods
  * cocoapods (1.6.0)
	Summary: The Cocoa library package manager.
	Homepage: https://github.com/CocoaPods/CocoaPods
	Path: /Users/xiongzenghui/.rvm/gems/ruby-2.6.0/gems/cocoapods-1.6.0
```

**path** 的值, 就是 cocoapods 这个 ruby gem 的安装位置。