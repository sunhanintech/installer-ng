name 'scalr-app'
default_version '__SCALR_APP_REVISION__'

source :path => '__SCALR_APP_PATH__'

license :project_license
# Manually add composer licenses
dependency_licenses [
  {
    dependency_name: 'onelogin/php-saml',
    dependency_manager: 'Composer',
    license: 'MIT',
    license_file: 'vendor/onelogin/php-saml/LICENSE'
  },
    {
    dependency_name: 'justinrainbow/json-schema',
    dependency_manager: 'Composer',
    license: 'MIT',
    license_file: 'vendor/justinrainbow/json-schema/LICENSE'
  },
    {
    dependency_name: 'php-amqplib',
    dependency_manager: 'Composer',
    license: 'LGPL-2.1',
    license_file: 'vendor/php-amqplib/php-amqplib/LICENSE'
  },
  {
    dependency_name: 'adodb/adodp-php',
    dependency_manager: 'Composer',
    license: 'BSD-3-Clause',
    license_file: 'vendor/adodb/adodb-php/LICENCE.md'
  },
  {
    dependency_name: 'google/apiclient',
    dependency_manager: 'Composer',
    license: 'Apache-2.0',
    license_file: 'vendor/google/apiclient/LICENSE'
  },
  {
    dependency_name: 'psr/cache',
    dependency_manager: 'Composer',
    license: 'MIT',
    license_file: 'vendor/psr/cache/LICENSE.txt'
  }
]

dependency 'php-composer'


build do
  # Install dependencies using composer
  command "#{install_dir}/embedded/bin/php #{install_dir}/embedded/bin/composer.phar install --no-dev"

  # Update code version
  command "#{install_dir}/embedded/bin/php ./app/bin/update-code-version.php"

  # Copy the code to the ./scalr dir.
  command "mkdir -p #{install_dir}/embedded/scalr"
  command "rsync -a --delete --exclude=.git --exclude=.gitignore --exclude=.drone.yml --exclude=installer-ng --exclude=.releaseignore --exclude=pybuild ./ #{install_dir}/embedded/scalr"

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
