name 'php-yaml'
default_version '2.0.0'

source url: "http://pecl.php.net/get/yaml-#{version}.tgz",
  md5: '5bdb54d5cd62d41354434f4d2a1c11ee'

relative_path "yaml-#{version}"

dependency 'libyaml'
dependency 'php'

license path: 'LICENSE'


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "#{install_dir}/embedded/bin/phpize"
  command './configure' \
          " --with-php-config=#{install_dir}/embedded/bin/php-config" \
          " --with-yaml=#{install_dir}/embedded", env: env

  make "-j #{workers}", env: env
  make 'install', env: env

  #Add extension to php.ini
  command "mkdir -p #{install_dir}/etc/php"
  command "echo 'extension=yaml.so' >> #{install_dir}/etc/php/php.ini"

end
