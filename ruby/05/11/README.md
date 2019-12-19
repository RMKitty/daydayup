[TOC]



## 1. install ruby gem 报错如下

```ruby
Traceback (most recent call last):
	4: from /Users/Fuhanyu/.rvm/gems/ruby-2.5.1/bin/ruby_executable_hooks:24:in `<main>'
	3: from /Users/Fuhanyu/.rvm/gems/ruby-2.5.1/bin/ruby_executable_hooks:24:in `eval'
	2: from /Users/Fuhanyu/.rvm/gems/ruby-2.5.1/bin/bundle:23:in `<main>'
	1: from /Users/Fuhanyu/.rvm/rubies/ruby-2.5.1/lib/ruby/2.5.0/rubygems.rb:308:in `activate_bin_path'
/Users/Fuhanyu/.rvm/rubies/ruby-2.5.1/lib/ruby/2.5.0/rubygems.rb:289:in `find_spec_for_exe': can't find gem bundler (>= 0.a) with executable bundle (Gem::GemNotFoundException)
Traceback (most recent call last):
	4: from /Users/Fuhanyu/.rvm/gems/ruby-2.5.1/bin/ruby_executable_hooks:24:in `<main>'
	3: from /Users/Fuhanyu/.rvm/gems/ruby-2.5.1/bin/ruby_executable_hooks:24:in `eval'
	2: from /Users/Fuhanyu/.rvm/gems/ruby-2.5.1/bin/bundle:23:in `<main>'
	1: from /Users/Fuhanyu/.rvm/rubies/ruby-2.5.1/lib/ruby/2.5.0/rubygems.rb:308:in `activate_bin_path'
/Users/Fuhanyu/.rvm/rubies/ruby-2.5.1/lib/ruby/2.5.0/rubygems.rb:289:in `find_spec_for_exe': can't find gem bundler (>= 0.a) with executable bundle (Gem::GemNotFoundException)
rake aborted!
LoadError: cannot load such file -- bundler/gem_tasks
/private/tmp/kanshan/Rakefile:1:in `<top (required)>'
/Users/Fuhanyu/.rvm/gems/ruby-2.5.1/gems/rake-12.3.1/exe/rake:27:in `<top (required)>'
/Users/Fuhanyu/.rvm/gems/ruby-2.5.1/bin/ruby_executable_hooks:24:in `eval'
/Users/Fuhanyu/.rvm/gems/ruby-2.5.1/bin/ruby_executable_hooks:24:in `<main>'
(See full trace by running task with --trace)
```

关键报错信息:

```ruby
can't find gem bundler (>= 0.a) with executable bundle (Gem::GemNotFoundException)
rake aborted!
```

看起来好像是与 **bundler 版本** 相关的问题.



## 2. 对比多处的 bundler 版本

### 1. 报错机器 使用的 bundler 版本: 2.0.2

```
 ~  bundle -v
Bundler version 2.0.2
```

### 2. 生成 Gemfile.lock 使用的 bundler 版本: 2.0.1

```ruby
# Gemfile.lock

.......

DEPENDENCIES
  bundler (~> 2.0.1)
  kanshan!
  rake (~> 10.0)
  rspec (~> 3.0)
  rubocop (= 0.59.0)
  simplecov
  simplecov-html

BUNDLED WITH
   2.0.1
```

发现这两个是不一致的.



## 3. 尝试让 本机 保持与 ruby-gem 一样的 bundler 版本 2.0.1

```
gem uninstall bundler
gem install bundler -v 2.0.1
```

再次安装 ruby-gem 就 ok 了..
