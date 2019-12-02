[TOC]




## 1. ==Private== lane

```ruby
lane :production do
  # ...
  build(release: true)
  appstore # Deploy to the AppStore
  # ...
end

lane :beta do
  # ...
  build(release: false)
  crashlytics # Distribute to testers
  # ...
end

private_lane :build do |options|
  # ...
end
```

- 1) production 可以调用 build
- 2) beta 可以调用 build
- 3) 但是 **bundle exec fastlane build** 就会报错, **build** 不允许被 **外部调用**



## 2. 代码中的 lane, 可以随意调用 ==private== lane

```ruby
lane :hello do |options|
  UI.success("✅ hello")
  world
end

private_lane :world do |options|
  UI.success("✅ world!")
end
```

```
[10:06:44]: Driving the lane 'hello' 🚀
[10:06:44]: ✅ hello
[10:06:44]: ----------------------------------
[10:06:44]: --- Step: Switch to world lane ---
[10:06:44]: ----------------------------------
[10:06:44]: Cruising over to lane 'world' 🚖
[10:06:44]: ✅ world!
[10:06:44]: Cruising back to lane 'hello' 🚘
```



## 3. 但是无法在 ==命令行== 中调用 ==private== lane

```
╰─± bundle exec fastlane world
...............

[10:08:31]: You can't call the private lane 'world' directly
[10:08:31]: fastlane finished with errors

[!] You can't call the private lane 'world' directly
```


