name 'scalr-app'

source :git => 'https://github.com/Scalr/scalr.git' # TODO - EE

# Python
dependency 'python'
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

# PHP package dependencies
dependency 'php'
dependency 'php-pecl_http'
dependency 'php-rrd'
dependency 'php-ssh2'
dependency 'php-yaml'
dependency 'php-zmq'

# Other app dependencies
dependency 'putty'

# Note: rsync is only used during build, so we don't include it as a dependency. Same for swig.


build do
  env = with_standard_compiler_flags(with_embedded_path)

  # Install Python dependencies (we have to install those here because this is where we get the requirements.txt
  # file)
  command "#{install_dir}/embedded/bin/pip install" \
          ' -I' \
          " --build #{project_dir}/pybuild" \
          ' --requirement ./app/python/requirements.txt', env: env

  # Copy the code to the ./app dir.
  command "mkdir -p #{install_dir}/app"
  command "rsync -a --delete --exclude=.git/*** --exclude=.gitignore --exclude=./pybuild ./ #{install_dir}/app/"

end
