name 'php-propro'
default_version '2.0.1'

source url: "https://pecl.php.net/get/propro-#{version}.tgz"

version '1.0.0' do
  source md5: '9c775035fd17c65f0162b7eb1b4f8564'
end

version '2.0.1' do
  source md5: '19f9517210a87e18cc09faed262e1522'
end

dependency 'php'

relative_path "propro-#{version}"

license path: 'LICENSE'

build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "#{install_dir}/embedded/bin/phpize"
  command './configure' \
          " --with-php-config=#{install_dir}/embedded/bin/php-config" \
          " --enable-propro", env: env
  make "-j #{workers}", env: env
  make 'install', env: env

  #Add extension to php.ini
  command "mkdir -p #{install_dir}/etc/php"
  command "echo 'extension=propro.so' >> #{install_dir}/etc/php/php.ini"
end
