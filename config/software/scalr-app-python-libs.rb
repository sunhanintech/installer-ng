name 'scalr-app-python-libs'

source :path => '__SCALR_REQUIREMENTS_PATH__'

# Python
dependency 'pip'

# Python package dependencies
dependency 'libffi'
dependency 'openssl'
dependency 'cairo'
dependency 'pango'
dependency 'glib'
dependency 'libxml2'
dependency 'rrdtool'
dependency 'libyaml'

# Separately installed dep
dependency 'python-m2crypto'

build do
  env = with_standard_compiler_flags(with_embedded_path)

  # Install Python dependencies (we have to install those here because this is where we get the requirements.txt
  # file)
  # Note that m2crypto is installed separately in python-m2crypto.
  # Then, install the rest
  command "#{install_dir}/embedded/bin/pip install" \
          " --build #{project_dir}/pybuild" \
          ' --requirement ./requirements.txt', env: env

end
