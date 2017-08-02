name 'php-ssh2'
default_version '0.12'

source url: "http://pecl.php.net/get/ssh2-#{version}.tgz",
  md5: '409b91678a842bb0ff56f2cf018b9160'

relative_path "ssh2-#{version}"

dependency 'libssh2'
dependency 'php'

license 'PHP-3.0'
license_file 'LICENSE'
skip_transitive_dependency_licensing true


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
