name 'httpd'
default_version '2.4.25'

source url: "http://www.us.apache.org/dist/httpd/httpd-#{version}.tar.bz2"


version '2.4.10' do
  source md5: '44543dff14a4ebc1e9e2d86780507156'
end

version '2.4.12' do
  source md5: 'b8dc8367a57a8d548a9b4ce16d264a13'
end

version '2.4.23' do
  source md5: '04f19c60e810c028f5240a062668a688'
end

version '2.4.25' do
  source md5: '2826f49619112ad5813c0be5afcc7ddb'
end

dependency 'apr'
dependency 'apr-util'
dependency 'openssl'
dependency 'pcre'
dependency 'zlib'
dependency 'libxml2'

relative_path "httpd-#{version}"

license 'Apache-2.0'
license_file 'LICENSE'
skip_transitive_dependency_licensing true


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
  make "-j #{workers}", env: env
  make 'install', env: env
end
