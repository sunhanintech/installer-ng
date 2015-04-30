name 'yolk'
default_version '0.8.6'

dependency 'python'
dependency 'pip'


build do
  env = with_standard_compiler_flags(with_embedded_path)
  command "#{install_dir}/embedded/bin/pip install yolk3k==#{version}", env: env
end
