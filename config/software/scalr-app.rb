name 'scalr-app'
default_version = 'cee9a5dfc950daa018c685968a1b88bbb4dfb772'  # 5.1

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

# Note: rsync is only used during build, so we don't include it as a dependency. Same for swig.


build do
  env = with_standard_compiler_flags(with_embedded_path)

  # Install Python dependencies (we have to install those here because this is where we get the requirements.txt
  # file)
  command "#{install_dir}/embedded/bin/pip install" \
          ' -I' \
          " --build #{project_dir}" \
          ' --requirement ./app/python/requirements.txt', env: env

  # Copy the code to the ./app dir.
  command "mkdir -p #{install_dir}/app"
  command "rsync -a --delete --exclude=.git/*** --exclude=.gitignore --exclude=./pybuild ./ #{install_dir}/app/"

end
