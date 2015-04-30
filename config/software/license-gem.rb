name 'license-gem'
default_version '0.1.2'

dependency 'ruby'
dependency 'rubygems'


build do
  env = with_standard_compiler_flags(with_embedded_path)

  gem 'install gem-licenses' \
      " --version '#{version}'" \
      " --bindir '#{install_dir}/embedded/bin'" \
      ' --no-ri --no-rdoc', env: env
end
