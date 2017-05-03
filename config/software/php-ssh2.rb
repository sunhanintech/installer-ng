name 'php-ssh2'
default_version '1.0'

source url: "http://pecl.php.net/get/ssh2-#{version}.tgz",
  md5: '1f84d2d0621933dce06eedeffe54ebd0'

relative_path "ssh2-#{version}"

dependency 'libssh2'
dependency 'php'

license path: 'LICENSE'

build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "#{install_dir}/embedded/bin/phpize"
  command './configure' \
          " --with-php-config=#{install_dir}/embedded/bin/php-config" \
          " --with-ssh2=#{install_dir}/embedded", env: env

  make "-j #{workers}", env: env
  make 'install', env: env

  #Add extension to php.ini
  command "mkdir -p #{install_dir}/etc/php"
  command "echo 'extension=ssh2.so' >> #{install_dir}/etc/php/php.ini"

end
