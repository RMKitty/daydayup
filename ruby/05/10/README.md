[TOC]



https://bundler.io/v2.0/guides/bundler_plugins.html



## 1. Gemfile 指定, 要安装的 plugin

```ruby
plugin 'my_plugin' # Installs from Rubygems
plugin 'my_plugin', path: '/path/to/plugin' # Installs from a path
plugin 'my_plugin', git: 'https://github.com:repo/my_plugin.git' # Installs from Git
```



## 2. 创建一个自己的 plugin

https://bundler.io/v2.0/guides/bundler_plugins.html#getting-started-with-development

比如实现 **拦截 bundle install** 的过程:

```ruby
Bundler::Plugin.add_hook('before-install-all') do |dependencies|
  # Do something with the dependencies
end
```
