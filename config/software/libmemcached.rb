name 'libmemcached'
default_version '1.0.18'

source url: "https://launchpad.net/libmemcached/1.0/#{version}/+download/libmemcached-#{version}.tar.gz"

version '1.0.18' do
  source md5: 'b3958716b4e53ddc5992e6c49d97e819'
end

dependency 'memcached'

relative_path "libmemcached-#{version}"

license 'BSD-3-Clause'
license_file 'COPYING'
skip_transitive_dependency_licensing true


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "./configure --prefix=#{install_dir}/embedded" \
          ' --without-mysql' \
          ' --without-gearmand' \
          ' --without-lcov' \
          ' --without-genhtml' \
          ' --without-sphinx-build' \
          " --with-memcached=#{install_dir}/embedded/bin/memcached", env: env
  make "-j #{workers}", env: env
  make 'install', env: env
end
