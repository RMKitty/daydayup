[TOC]




## 1. Fastfile

- 只要不设置 `FASTLANE_HIDE_TIMESTAMP=true` 情况下
- fastlane 会默认打印统计到的每一个动作消耗的时间

```
.................


+------+-----------------------------------------------------------+-------------+
|                                [32mfastlane summary[0m                                |
+------+-----------------------------------------------------------+-------------+
| Step | Action                                                    | Time (in s) |
+------+-----------------------------------------------------------+-------------+
| 1    | default_platform                                          | 0           |
| 2    | unlock_keychain                                           | 0           |
| 3    | make                                                      | 97          |
| 4    | Switch to private_get_product_name_in_project lane        | 0           |
| 5    | Switch to private_get_display_name_in_project lane        | 0           |
| 6    | get_info_plist_value                                      | 0           |
| 7    | get_info_plist_value                                      | 0           |
| 8    | Switch to private_app_package_build_project lane          | 0           |
| 9    | build_ios_app                                             | 291         |
| 10   | set_env_from_file                                         | 0           |
| 11   | Switch to private_app_package_upload_ipa_to_updown lane   | 0           |
| 12   | upload_file                                               | 20          |
| 13   | write_athena_result                                       | 0           |
| 14   | set_env_from_file                                         | 0           |
| 15   | Switch to private_app_package_upload_dsym_to_updown lane  | 0           |
| 16   | upload_dsym                                               | 6           |
| 17   | write_athena_result                                       | 0           |
| 18   | set_env_from_file                                         | 0           |
| 19   | Switch to private_app_package_upload_ipa_to_appstore lane | 0           |
| 20   | Switch to private_app_package_notify_appcloud lane        | 0           |
| 21   | upload_symbols_to_crashlytics                             | 488         |
| 22   | Switch to private_app_package_upload_dsym_to_bugly lane   | 0           |
| 23   | wget_buglysh                                              | 0           |
| 24   | unzip                                                     | 2           |
| 25   | get_info_plist_value                                      | 0           |
| 26   | get_info_plist_value                                      | 0           |
| 27   | upload_dsym                                               | 194         |
| 28   | dsym_uuid                                                 | 0           |
| 29   | write_athena_result                                       | 0           |
| 30   | write_athena_result                                       | 0           |
+------+-----------------------------------------------------------+-------------+

[19:54:16]: [32mfastlane.tools just saved you 23 minutes! 🎉[0m

.................
```

大概是长这样的。



## 2. 如果要在代码中, 拿到这些时间戳

```ruby
after_all do |lane, options|
  UI.message("[after_all] #{lane} (#{lane.class})")
  actions = Fastlane::Actions.executed_actions
  pp actions #=> [{:name=>"default_platform", :error=>nil, :time=>0.001643}]
end

lane :hello do |options|
  sleep(10)
  UI.success("✅ hello")
  world
end

private_lane :world do |options|
  sleep(10)
  UI.success("✅ world!")
end
```