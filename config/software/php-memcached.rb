name 'php-memcached'
default_version '2.2.0'

source url: "http://pecl.php.net/get/memcached-#{version}.tgz"

version '2.2.0' do
  source md5: '28937c6144f734e000c6300242f44ce6'
end

dependency 'zlib'
dependency 'libmemcached'
dependency 'php'


relative_path "memcached-#{version}"

license 'PHP-3.0'
license_file 'LICENSE'


build do
  env = with_standard_compiler_flags(with_embedded_path)

  # https://github.com/Scalr/scalr/issues/61#issuecomment-88185134
  patch source: 'detailed-session-error-logging.patch'

  command "#{install_dir}/embedded/bin/phpize"
  command './configure' \
          " --with-php-config=#{install_dir}/embedded/bin/php-config" \
          " --with-zlib-dir=#{install_dir}/embedded" \
          " --with-libmemcached-dir=#{install_dir}/embedded", env: env
  make "-j #{workers}", env: env
  make 'install', env: env
end
