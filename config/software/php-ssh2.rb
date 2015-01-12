name 'php-ssh2'
default_version '0.12'

source url: "http://pecl.php.net/get/ssh2-#{version}.tgz",
       md5: '409b91678a842bb0ff56f2cf018b9160'

relative_path "ssh2-#{version}"

dependency 'libssh2'
dependency 'php'


build do
       env = with_standard_compiler_flags(with_embedded_path)

       command "#{install_dir}/embedded/bin/phpize"
       command './configure' \
               " --with-php-config=#{install_dir}/embedded/bin/php-config" \
               " --with-ssh2=#{install_dir}/embedded", env: env
       make env: env
       make 'install', env: env
end
