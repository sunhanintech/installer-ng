name 'supervisor'
description 'Process manager'
default_version '3.1.13'


dependency 'python'
dependency 'pip'


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "#{install_dir}/embedded/bin/pip install supervisor==#{version}", env: env
end
