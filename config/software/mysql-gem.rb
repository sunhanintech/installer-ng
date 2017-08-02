name 'mysql-gem'
default_version '2.9.1'

dependency 'ruby'
dependency 'rubygems'

license 'Ruby'
license_file "https://raw.githubusercontent.com/luislavena/mysql-gem/v#{version.gsub('.', '_')}/COPYING"
skip_transitive_dependency_licensing true


build do
  env = with_standard_compiler_flags(with_embedded_path)

  gem 'install mysql' \
      " --version '#{version}'" \
      " --bindir '#{install_dir}/embedded/bin'" \
      ' --no-ri --no-rdoc', env: env
end