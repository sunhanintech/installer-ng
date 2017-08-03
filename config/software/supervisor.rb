name 'supervisor'
description 'Process manager'
default_version '3.3.1'

dependency 'python'
dependency 'pip'

license 'BSD-derived'
license_file "https://raw.githubusercontent.com/Supervisor/supervisor/#{version}/LICENSES.txt"
skip_transitive_dependency_licensing true


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "#{install_dir}/embedded/bin/pip install supervisor==#{version}", env: env
end
