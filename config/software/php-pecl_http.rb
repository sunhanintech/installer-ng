name 'php-pecl_hhtp'
default_version '1.7.6'

source url: "http://pecl.php.net/get/pecl_http-#{version}.tgz"

version '1.7.6' do
  source md5: '4926c17a24a11a9b1cf3ec613fad97cb'
end

dependency 'zlib'
dependency 'curl'
dependency 'file'  # libmagic
dependency 'php'

relative_path "pecl_http-#{version}"

license path: 'LICENSE'


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "#{install_dir}/embedded/bin/phpize"
  command './configure' \
          " --with-php-config=#{install_dir}/embedded/bin/php-config" \
          ' --enable-http' \
          " --with-http-curl-requests=#{install_dir}/embedded" \
          " --with-http-zlib-compression=#{install_dir}/embedded" \
          " --with-http-magic-mime=#{install_dir}/embedded"\
          ' --without-http-curl-libevent', env: env  # TODO - Do we want libevent?
  make env: env
  make 'install', env: env
end
