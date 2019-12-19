[TOC]


- 1) To use Bundler in a single-file script, add require **'bundler/inline'** at the **top** of your **Ruby file**.
- 2) use the **gemfile method** to **declare any gem** sources and gems that you need

```ruby
# bundler_inline_example.rb

require 'bundler/inline'
gemfile do
  source 'https://rubygems.org'
  gem 'json', require: false
  gem 'nap', require: 'rest'
  gem 'cocoapods', '~> 0.34.1'
end

puts 'Gems installed and loaded!'
puts "The nap gem is at version #{REST::VERSION}"
```

- 假设上面的代码位于 bundler_inline_example.rb 文件中
- 当执行 ruby bundler_inline_example.rb 文件时
  - will **automatically install any missing gems**, require the gems you listed
  - and then run your code

