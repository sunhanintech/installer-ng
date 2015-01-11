name 'php-pecl_hhtp'
default_version '1.7.6'

source url: "http://pecl.php.net/get/pecl_http-#{version}.tgz",
       md5: '4926c17a24a11a9b1cf3ec613fad97cb'

relative_path "pecl_http-#{version}"

dependency 'zlib'
dependency 'curl'
dependency 'file'  # libmagic
dependency 'php'


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "#{install_dir}/embedded/bin/phpize"
  command './configure' \
          ' --enable-http' \
          " --with-http-curl-requests=#{install_dir}/embedded" \
          " --with-http-zlib-compression=#{install_dir}/embedded" \
          " --with-http-magic-mime=#{install_dir}/embedded"\
          ' --without-http-curl-libevent', env: env  # TODO - Do we want libevent?
  make "-j #{workers}", env: env
  make "-j #{workers} install", env: env
end
