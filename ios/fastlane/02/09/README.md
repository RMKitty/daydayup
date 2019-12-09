[TOC]



- 1) 应该使用 **action (本地)** 或者 **plugin (远程)** 封装可重用的代码

- 2) action 和 plugin **路径** 问题
  - **不应该** 依赖外部 **lane** 调用时的 **相对路径**
  - 而 **应该** 由外部 **lane** 传入 **绝对路径**


- 3) 如果比较通用的 ==工具性(不可分割)== 代码
	- 优先考虑 **plugin**
	- 再次考虑 **action** (一旦使用 action 实现, 就无法再 **其他项目** 中使用)

- 4) 使用一个独立的 ==Fastfile== 组装 ==n个 action== 重用
  - 1) 使用 **plugin** , 那么 **依赖方** 也需要安装 **remote Fastfile** 依赖的 **plugin** (安装 gem)
  - 2) 使用 **action** , 那么 **依赖方** 不需要安装


- 5) [Action 类型](https://docs.fastlane.tools/actions/)