name 'apr-util'
default_version '1.5.4'

source url: "http://www.us.apache.org/dist/apr/apr-util-#{version}.tar.bz2",
       md5: '2202b18f269ad606d70e1864857ed93c'

dependency 'apr'
dependency 'gdbm'
dependency 'openssl'
dependency 'sqlite'

relative_path "apr-util-#{version}"

license 'Apache-2.0'
license_file 'LICENSE'
skip_transitive_dependency_licensing true


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command './configure' \
          " --prefix=#{install_dir}/embedded" \
          ' --with-dbm=gdbm' \
          " --with-gdbm=#{install_dir}/embedded" \
          " --with-sqlite3=#{install_dir}/embedded" \
          " --with-apr=#{install_dir}/embedded" \
          " --with-crypto --with-openssl=#{install_dir}/embedded", env: env
  make "-j #{workers}", env: env
  make 'install', env: env
end
