name 'scalr-app'
default_version '__SCALR_APP_REVISION__'

source :git => '__SCALR_APP_PATH__'

# Python
dependency 'python'
dependency 'pip'
dependency 'python-m2crypto'

# Python package dependencies
dependency 'libffi'
dependency 'openssl'
dependency 'cairo'
dependency 'pango'
dependency 'glib'
dependency 'libxml2'
dependency 'rrdtool'
dependency 'dejavu-sans-ttf'
dependency 'libyaml'

# PHP package dependencies
dependency 'php'
dependency 'php-pecl_http'
dependency 'php-rrd'
dependency 'php-ssh2'
dependency 'php-yaml'
dependency 'php-zmq'
dependency 'php-memcached'

# Other app dependencies
dependency 'putty'

# Note: rsync is only used during build, so we don't include it as a dependency. Same for swig.


build do
  env = with_standard_compiler_flags(with_embedded_path)

  # Install Python dependencies (we have to install those here because this is where we get the requirements.txt
  # file)
  # Note that m2crypto is installed separately in python-m2crypto.
  # Then, install the rest
  command "#{install_dir}/embedded/bin/pip install" \
          " --build #{project_dir}/pybuild" \
          ' --requirement ./app/python/requirements.txt', env: env

  # Copy the code to the ./scalr dir.
  command "mkdir -p #{install_dir}/embedded/scalr"
  command "rsync -a --delete --exclude=.git --exclude=.gitignore --exclude=installer-ng --exclude=pybuild ./ #{install_dir}/embedded/scalr"

  # Dump configuration information to a JSON file
  block do
    require 'json'

    manifest = {
        :edition          => '__SCALR_APP_EDITION__',
        :revision         => '__SCALR_APP_REVISION__',
        :date             => '__SCALR_APP_DATE__',
        :full_revision    => '__SCALR_APP_FULL_REVISION__',
    }

    File.open("#{install_dir}/embedded/scalr/manifest.json", 'w') do |f|
      f.puts(JSON.pretty_generate(manifest))
    end
  end

end
