name 'sentry-raven-gem'
default_version '0.9.4'  # https://github.com/coderanger/chef-sentry-handler/blob/master/recipes/default.rb#L13

dependency 'ruby'
dependency 'rubygems'

build do
  env = with_standard_compiler_flags(with_embedded_path)

  gem 'install sentry-raven' \
      " --version '#{version}'" \
      " --bindir '#{install_dir}/embedded/bin'" \
      ' --no-ri --no-rdoc', env: env
end
