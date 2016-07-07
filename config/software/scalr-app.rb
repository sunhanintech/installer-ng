name 'scalr-app'
default_version '__SCALR_APP_REVISION__'

source :git => '__SCALR_APP_PATH__'

[
  ['adodb5', '18', 'license.txt']
].each do |dep_name, dep_version, dep_license|
  license path: "app/src/externals/#{dep_name}-#{dep_version}/#{dep_license}", name: dep_name, version: dep_version
end

# Manually composer licenses
license path: "vendor/google/apiclient/LICENSE"
license path: "vendor/onelogin/php-saml/LICENSE"

dependency 'php-composer'

build do
  # Install dependencies using composer
  command "#{install_dir}/embedded/bin/php #{install_dir}/embedded/bin/composer.phar install --no-dev"

  # Copy the code to the ./scalr dir.
  command "mkdir -p #{install_dir}/embedded/scalr"
  command "rsync -a --delete --exclude=.git --exclude=.gitignore --exclude=.drone.yml --exclude=installer-ng --exclude=pybuild ./ #{install_dir}/embedded/scalr"

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
