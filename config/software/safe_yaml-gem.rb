name 'safe_yaml-gem'
default_version '1.0.4'

dependency 'ruby'
dependency 'rubygems'
dependency 'libyaml'

license url: "https://raw.githubusercontent.com/dtao/safe_yaml/#{version}/LICENSE.txt"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  gem 'install safe_yaml' \
      " --version '#{version}'" \
      " --bindir '#{install_dir}/embedded/bin'" \
      ' --no-ri --no-rdoc', env: env
end
