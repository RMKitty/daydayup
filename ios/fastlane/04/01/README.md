[TOC]




## 1. fastlane action 是什么？干什么？

- 之前我们一直是通过编写 **Fastfile** 实现一个功能的自动化

- 但是如果所有的代码都 **堆积在一个 Fastfile** 文件中，会造成代码臃肿难以维护

- 所以 fastlane 提供 action 这样的东西，来让你把一些可重用的代码隔离封装起来



## 2. 查看某个 action 的用法

比如查看 **cocoapods** 这个 action 怎么用:

```
fastlane action cocoapods
```



## 3. fastlane actions 文档

```
https://docs.fastlane.tools/actions/pod_push/#pod_push
```


## 4. `Fastfile#lane` 与 action 工作目录 ==不一样==

### 1. Fastfile#lane 执行所在的目录: `$WORKSPACE/fastlane/`

```ruby
sh "pwd" # => "$WORKSPACE/fastlane"
puts Dir.pwd # => "$WORKSPACE/fastlane"

lane :something do
  sh "pwd" # => "$WORKSPACE/fastlane"
  puts Dir.pwd # => "$WORKSPACE/fastlane"

  my_action
end
```

注意: while all user code **from the Fastfile** runs **inside** the  `./fastlane directory`.

### 2. action#run 执行所在的目录: `$WORKSPACE/`

```ruby
def run(params)
  puts Dir.pwd # => "$WORKSPACE"
end
```

注意: Notice how every **action** and every **plugin**'s code runs **in the root of the project**, 

### 3. 所以如果需要在 `$WORKSPACE/` 下执行的代码, 最好使用 ==action== 封装

比如 nicolas buil 代码，使用一个 action 封装起来 run 方法中执行

```ruby
module Fastlane
  module Actions
    module SharedValues
      JENKINS_MR_BUILD_CUSTOM_VALUE = :JENKINS_MR_BUILD_CUSTOM_VALUE
    end

    class JenkinsMrBuildAction < Action
      def self.run(params)
        puts "[JenkinsMrBuildAction] pwd = #{Dir.pwd}"

        mrtitle = ENV['gitlabMergeRequestTitle'].to_s
        mrdesc = ENV['gitlabMergeRequestDescription'].to_s

        system("工程构建代码")
      end

      def self.description
        "A short description with <= 80 characters of what this action does"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "You can use this action to do cool things..."
      end

      def self.available_options
        nil
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['JENKINS_MR_BUILD_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.return_value
        nil
      end

      def self.authors
        ["XionZenghui"]
      end

      def self.example_code
        [
          'jenkins_mr_build'
        ]
      end

      def self.category
        # AVAILABLE_CATEGORIES = [
        #   :testing,
        #   :building,
        #   :screenshots,
        #   :project,
        #   :code_signing,
        #   :documentation,
        #   :beta,
        #   :push,
        #   :production,
        #   :source_control,
        #   :notifications,
        #   :app_store_connect,
        #   :misc,
        #   :deprecated # This should be the last item
        # ]
        :building
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
```

- 那么当这个 action 执行的时候，自动就会在 `$WORKSPACE/` 根目录下执行了
- 就不用在 Fastfile#lane 中各种 **Dir.chdir(xxx)** 操作

### 4. 综合示例

#### 1. Fastfile`

```ruby
lane :test do
  # 1.
  UI.message("lane :test 1: #{Dir.pwd}")

  # 2.
  my_action

  # 3.
  Dir.chdir('../')

  # 4.
  UI.message("lane :test 4: #{Dir.pwd}")

  # 5.
  my_action

  # 6.
  UI.message("lane :test 6: #{Dir.pwd}")
end
```

#### 2. action

```ruby
module Fastlane
  module Actions
    class MyActionAction < Action
      def self.run(params)
        UI.message("my_action: #{Dir.pwd}")
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "A short description with <= 80 characters of what this action does"
      end

      def self.details
        "You can use this action to do cool things..."
      end
      
      def self.return_type
        :stirng
      end

      def self.return_value
        'return a name for you ~'
      end
    end
  end
end
```

#### 3. WORKSPACE 根目录

目录内都是一个个的 **目录**

```
 ~/collect_workspace  ll
total 0
drwxr-xr-x   5 xiongzenghui  staff   160B  7  9 22:16 FAQ
drwxr-xr-x  26 xiongzenghui  staff   832B  6 11 16:47 arsenal
drwxr-xr-x  14 xiongzenghui  staff   448B  3 15 13:39 ios-ci
drwxr-xr-x  15 xiongzenghui  staff   480B  6 11 16:27 ios_build_env_setup
drwxr-xr-x  31 xiongzenghui  staff   992B  6 12 01:09 ios_projects
drwxr-xr-x  23 xiongzenghui  staff   736B  6 20 20:22 kanshan
drwxr-xr-x  14 xiongzenghui  staff   448B  6 27 15:55 metis
drwxr-xr-x  21 xiongzenghui  staff   672B  6 27 13:17 nicolas
drwxr-xr-x  27 xiongzenghui  staff   864B  6 25 10:00 nicolas-server
drwxr-xr-x  21 xiongzenghui  staff   672B  7  9 11:15 nicolas_self
drwxr-xr-x  14 xiongzenghui  staff   448B  7 10 13:47 toolbox
drwxr-xr-x  18 xiongzenghui  staff   576B  7  3 14:50 venom
```

定义环境变量表示 **WORKSPACE** 假设是我们的 **工作目录** 最顶层 目录

```
export WORKSPACE=/Users/xiongzenghui/collect_workspace
```
#### 4. 执行 fastlane

进入到 WORKSPACE 下的 **fastlane app 项目** 的根目录:

```
# cd $WORKSPACE/toolbox
# ll
total 56
-rw-r--r--   1 xiongzenghui  staff   1.2K  7 10 12:48 Gemfile
-rw-r--r--   1 xiongzenghui  staff   7.5K  7 10 12:14 Gemfile.lock
-rw-r--r--   1 xiongzenghui  staff   328B  7 10 13:47 Makefile
-rw-r--r--@  1 xiongzenghui  staff   1.0K  7 10 19:33 README.md
drwxr-xr-x  12 xiongzenghui  staff   384B  7 10 16:31 fastlane
-rw-r--r--   1 xiongzenghui  staff   195B  7 10 13:23 jenkins_module.rb
-rw-r--r--   1 xiongzenghui  staff   191B  7 10 13:02 jenkins_mr.rb
```

执行 Fastfile 中的 test lane

```
# bundle exec fastlane test
[✔] 🚀
+---------------------------+---------+-----------+
|                  Used plugins                   |
+---------------------------+---------+-----------+
| Plugin                    | Version | Action    |
+---------------------------+---------+-----------+
| fastlane-plugin-git_clone | 0.1.1   | git_clone |
+---------------------------+---------+-----------+

[23:48:42]: Driving the lane 'test' 🚀
[23:48:42]: lane :test 1: /Users/xiongzenghui/collect_workspace/toolbox/fastlane
[23:48:42]: ----------------
[23:48:42]: --- Step: my ---
[23:48:42]: ----------------
[23:48:42]: my_action: /Users/xiongzenghui/collect_workspace/toolbox
Fastfile:14: warning: conflicting chdir during another chdir block
[23:48:42]: lane :test 4: /Users/xiongzenghui/collect_workspace/toolbox
[23:48:42]: ----------------
[23:48:42]: --- Step: my ---
[23:48:42]: ----------------
[23:48:42]: my_action: /Users/xiongzenghui/collect_workspace
[23:48:42]: lane :test 6: /Users/xiongzenghui/collect_workspace/toolbox

+------+--------+-------------+
|      fastlane summary       |
+------+--------+-------------+
| Step | Action | Time (in s) |
+------+--------+-------------+
| 1    | my     | 0           |
| 2    | my     | 0           |
+------+--------+-------------+

[23:48:42]: fastlane.tools finished successfully 🎉
```

输出的 dir 目录依次:

- 1.1) lane :test 1: /Users/xiongzenghui/collect_workspace/toolbox/fastlane
- 1.2) my_action: /Users/xiongzenghui/collect_workspace/toolbox

- 2.1) lane :test 4: /Users/xiongzenghui/collect_workspace/toolbox
- 2.2) my_action: /Users/xiongzenghui/collect_workspace
- 2.3) lane :test 6: /Users/xiongzenghui/collect_workspace/toolbox

#### 5. 结论

- 1) **lane** 默认执行目录是 **WORKSPACE/fastlane app 项目/fastlane/**

- 2) **action** 默认执行目录是 **WORKSPACE/fastlane app 项目/**

- 3) 而不管 **lane** 如何变幻目录，**action** 总是比 **lane** 要 **少一层** 目录路径

### 5. ==改变== 工作目录

- 1) This is important to consider when migrating **existing** code from **your Fastfile** into your own action or plugin

- 2) To **change the directory** manually you can use standard **Ruby blocks**:

```ruby
Dir.chdir("..") do
  # code here runs in the parent directory
end
```

- 1) This behavior **isn't great**
  - 这种方式不是特别好

- 2) and has been like this since the very early days of fastlane
  - FastLane的早期就一直如此

- 3) As much as we'd like to change it, there is no good way to do so,
  - 尽管我们很想改变它，但没有好的方法可以做到这一点

- 4) without breaking thousands of production setups, so we decided to keep it as is for now.
  - 如果不打破成千上万的生产设置，所以我们决定保持现状。

### 6. action 内部 ==路径== 管理总结  

- 1) 在 **action 内部** 不要随便 **更改** 路径

- 2) 如果一定要更改，则一定要 **先备份路径** ，在完成时再 **恢复路径**

- 3) 推荐 **Fastfile#lane** 调用 **action** 时候，传入的就是 **最终操作文件** 的 **绝对路径**



## 5. fastlane main repo 中的 git_commit action

### 1. github 地址

https://docs.fastlane.tools/actions/git_commit/

### 2. fastlane/fastlane/lib/fastlane/actions/git_commit.rb

```ruby
module Fastlane
  module Actions
    class GitCommitAction < Action
      def self.run(params)
        if params[:path].kind_of?(String)
          paths = params[:path].shellescape
        else
          paths = params[:path].map(&:shellescape).join(' ')
        end

        skip_git_hooks = params[:skip_git_hooks] ? '--no-verify' : ''

        if params[:allow_nothing_to_commit]
          repo_clean = Actions.sh("git status --porcelain").empty?
          UI.success("Nothing to commit, working tree clean ✅.") if repo_clean
          return if repo_clean
        end

        command = "git commit -m #{params[:message].shellescape} #{paths} #{skip_git_hooks}".strip
        result = Actions.sh(command)
        UI.success("Successfully committed \"#{params[:path]}\" 💾.")
        return result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Directly commit the given file with the given message"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       description: "The file you want to commit",
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :message,
                                       description: "The commit message that should be used"),
          FastlaneCore::ConfigItem.new(key: :skip_git_hooks,
                                       description: "Set to true to pass --no-verify to git",
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :allow_nothing_to_commit,
                                       description: "Set to true to allow commit without any git changes",
                                       type: Boolean,
                                       optional: true)
        ]
      end

      def self.output
      end

      def self.return_value
        nil
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'git_commit(path: "./version.txt", message: "Version Bump")',
          'git_commit(path: ["./version.txt", "./changelog.txt"], message: "Version Bump")',
          'git_commit(path: ["./*.txt", "./*.md"], message: "Update documentation")',
          'git_commit(path: ["./*.txt", "./*.md"], message: "Update documentation", skip_git_hooks: true)'
        ]
      end

      def self.category
        :source_control
      end
    end
  end
end
```

### 3. action 主要做的事情

#### 1. 接收 参数

```ruby
def self.available_options
  [
    FastlaneCore::ConfigItem.new(key: :path,
                                 description: "The file you want to commit",
                                 is_string: false),
    FastlaneCore::ConfigItem.new(key: :message,
                                 description: "The commit message that should be used"),
    FastlaneCore::ConfigItem.new(key: :skip_git_hooks,
                                 description: "Set to true to pass --no-verify to git",
                                 type: Boolean,
                                 optional: true),
    FastlaneCore::ConfigItem.new(key: :allow_nothing_to_commit,
                                 description: "Set to true to allow commit without any git changes",
                                 type: Boolean,
                                 optional: true)
  ]
end
```

#### 2. 拼接 git command 命令行参数

```ruby
command = "git commit -m #{params[:message].shellescape} #{paths} #{skip_git_hooks}".strip
```

#### 3. 执行 shell command

```ruby
result = Actions.sh(command)
```

#### 4. 打印 执行完毕的消息

```ruby
UI.success("Successfully committed \"#{params[:path]}\" 💾.")
```

### 4. Fastfile 使用 action 示例

```
git_commit(path: "./version.txt", message: "Version Bump")
git_commit(path: ["./version.txt", "./changelog.txt"], message: "Version Bump")
git_commit(path: ["./*.txt", "./*.md"], message: "Update documentation")
git_commit(path: ["./*.txt", "./*.md"], message: "Update documentation", skip_git_hooks: true)
```
