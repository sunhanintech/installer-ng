name 'php-zmq'
default_version '1.1.3'

source url: "http://pecl.php.net/get/zmq-#{version}.tgz",
  md5: '9c638df5a6347a0fefb0d43d780e6480'

relative_path "zmq-#{version}"

dependency 'libzmq'
dependency 'php'

license path: 'LICENSE'


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "#{install_dir}/embedded/bin/phpize"
  command './configure' \
          " --with-php-config=#{install_dir}/embedded/bin/php-config" \
          " --with-zmq=#{install_dir}/embedded", env: env

  make "-j #{workers}", env: env
  make 'install', env: env

  #Add extension to php.ini
  command "mkdir -p #{install_dir}/etc/php"
  command "echo 'extension=zmq.so' >> #{install_dir}/etc/php/php.ini"

end
