[TOC]



## 1、Prerequisites

a Mac with Xcode 7 or +
SonarQube and SonarQube Scanner
xcpretty (see instructions below)
SwiftLint (HomeBrew installed and brew install swiftlint). Version 0.3.0 or above.
Tailor (HomeBrew installed and brew install tailor). Version 0.11.1 or above.
slather (gem install slather). Version 2.1.0 or above (2.4 since Xcode 8.3).
lizard (PIP installed and sudo pip install lizard)
OCLint installed. Version 0.11.0 recommended (0.13.0 since Xcode 9).
Faux Pas command line tools installed (optional)


## `.swiftlint.yml` 配置文件

- 项目根目录下创建或修改 `.swiftlint.yml`，内容如下：
- 详细配置可参考 swiftlint 官方文档
- **重要** `reporter: "xcode"` 一定要配置在 `.swiftlint.yml` 文件中, 否则结果 **无法被 sonar 识别**

```yml
# swiftlint 的配置文件
excluded: # paths to ignore during linting. Takes precedence over `included`.
  - Example/Pods
  - Example/build_outputs

whitelist_rules:
  - array_init
  - attributes
  - block_based_kvo
  - class_delegate_protocol
  - closing_brace
  - closure_end_indentation
  - closure_spacing
  - ........ 其他各种规则

# 如果要将结果上报给 sonar , 则此处只能传 "xcode"
reporter: "xcode" # reporter type (xcode, json, csv, checkstyle, junit, html, emoji)
```


## 参考资料

- https://juejin.im/post/5a72f63a6fb9a063606ea76b
- https://www.jianshu.com/p/f5973084bee1
- https://juejin.im/post/5c7fef015188251b63200cfc
- https://github.com/up1/demo-sonar-swift
- https://github.com/lucasmirsoa/sonar-swift-sample/blob/master/sonar-project.properties