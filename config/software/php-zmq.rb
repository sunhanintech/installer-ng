name 'php-zmq'
default_version '1.1.2'

source url: "http://pecl.php.net/get/zmq-#{version}.tgz",
       md5: '74da2fc1aa83e6fa27acffb9a37596b9'

relative_path "zmq-#{version}"

dependency 'libzmq'
dependency 'php'


build do
       env = with_standard_compiler_flags(with_embedded_path)

       command "#{install_dir}/embedded/bin/phpize"
       command './configure' \
               " --with-php-config=#{install_dir}/embedded/bin/php-config" \
               " --with-zmq=#{install_dir}/embedded", env: env
       make env: env
       make 'install', env: env
end
