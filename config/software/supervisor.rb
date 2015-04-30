name 'supervisor'
description 'Process manager'
default_version '3.1.3'

dependency 'python'
dependency 'pip'

license url: "https://raw.githubusercontent.com/Supervisor/supervisor/#{version}/LICENSES.txt"


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "#{install_dir}/embedded/bin/pip install supervisor==#{version}", env: env
end
