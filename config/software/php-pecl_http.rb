name 'php-pecl_http'
default_version '1.7.6'

source url: "http://pecl.php.net/get/pecl_http-#{version}.tgz"

version '1.7.6' do
  source md5: '4926c17a24a11a9b1cf3ec613fad97cb'
end

version '2.5.2' do
  source md5: '2651800f42e4640a04bd83ffc198cf72'
end

version '2.5.3' do
  source md5: 'faeaefd4c7800bcd9ced0883ebb3b733'
end

version '2.5.6' do
  source md5: '40fff0e5536c5e80b44e68dd475f8c0a'
end

dependency 'zlib'
dependency 'curl'
dependency 'file'  # libmagic
dependency 'php'
dependency 'php-raphf'
dependency 'php-propro'

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

  #Add extension to php.ini
  command "mkdir -p #{install_dir}/etc/php"
  command "echo 'extension=http.so' >> #{install_dir}/etc/php/php.ini"

end
