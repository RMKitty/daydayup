lane :add_tag do |options|
  git    = options[:git]
  branch = options[:branch]
  path   = options[:path]
  tag    = options[:tag]
  message = options[:message]

  git_clone(
    git: git,
    path: path,
    branch: branch,
    depth: 1,
    single_branch: true
  )

  cmds = [
    "cd #{path}",
    "git tag -a #{tag} -m \"#{message}\""
  ]
  sh(cmds.join(';'), error_callback: lambda { |result|
    UI.user_error!("❌ git add tag 失败")
  })

  cmds = [
    "cd #{path}",
    "git push origin #{tag}"
  ]
  sh(cmds.join(';'), error_callback: lambda { |result|
    UI.user_error!("❌ push #{tag} 失败")
  })
end
