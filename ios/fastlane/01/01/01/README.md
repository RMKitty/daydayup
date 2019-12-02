[TOC]



## 1. lane()

```ruby
# @param lane_name: 唯一的名字
# @param block: 回调block块代码
def lane(lane_name, block)
	....
end
```



## 2. Fastfile 中定义 lane

```ruby
lane :lan1 do
  # 回调代码块中调用其他的action设置函数
end

lane :lan2 do |options|
  # 回调代s码块中调用其他的action设置函数
end
```



## 3. lane 调用

### 1. bundle exec fastlane `<lane_name>` 参数键值对

命令行中执行定义的 lane 时, **传递** 参数键值对

```
$ fastlane appstore version:2.4.0 build:2.0
```

### 2. Fastfile 调用 lane

```ruby
lane :appstore do |options|
  puts options[:version]
  puts options[:build]
end

lane :job
	appstore(
		version: '1.1.1',
		build: '1656'
	)
end
```

### 3. 代码创建 lane, 并调用 (fastlane 当做一个 ruby 库)

#### 1. 简单示例

```ruby
require 'fastlane'

Fastlane::FastFile.new.parse("lane :test do
  UI.message('hello')
end").runner.execute(:test)
```

```
 ~/Desktop  ruby main.rb
[11:15:16]: Driving the lane 'test' 🚀
[11:15:16]: hello
```

#### 2. 创建 fastlane plugin 时, spec 中调用 lane 代码

```ruby
require 'spec_helper'
require 'webmock/rspec'

describe Fastlane::Actions::CiBuildNumberAction do
  describe "xxx" do
    it "xxx" do
      ENV['TRAVIS'] = '1'
      ENV['TRAVIS_BUILD_NUMBER'] = '42'

      result = Fastlane::FastFile.new.parse("lane :test do
        ci_build_number
      end").runner.execute(:test)

      expect(result).to eq('42')

      ENV.delete('TRAVIS')
      ENV.delete('TRAVIS_BUILD_NUMBER')
    end
  end
end
```

