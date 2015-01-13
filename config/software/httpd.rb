name 'httpd'
default_version '2.4.10'

source url: "http://www.us.apache.org/dist/httpd/httpd-#{version}.tar.bz2",
       md5: '44543dff14a4ebc1e9e2d86780507156'

relative_path "httpd-#{version}"

dependency 'apr'
dependency 'apr-util'
dependency 'openssl'
dependency 'pcre'
dependency 'zlib'
dependency 'libxml2'


# TODO - Consider statically building modules
# TODO - Consider --with-perl? (for apxs)
build do
  env = with_standard_compiler_flags(with_embedded_path)

  command './configure' \
          " --prefix=#{install_dir}/embedded" \
          " --sysconfdir=#{install_dir}/embedded/etc/httpd" \
          " --with-apr=#{install_dir}/embedded" \
          " --with-apr-util=#{install_dir}/embedded" \
          " --with-ssl=#{install_dir}/embedded" \
          " --with-pcre=#{install_dir}/embedded" \
          " --with-z=#{install_dir}/embedded" \
          " --with-libxml2=#{install_dir}/embedded" \
          ' --with-mpm=prefork' \
          ' --enable-so' \
          ' --enable-authz-owner --enable-deflate --enable-rewrite', env: env
  make env: env
  make 'install', env: env
end
