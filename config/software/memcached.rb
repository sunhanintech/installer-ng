name 'memcached'
default_version '1.4.22'

source :url => "http://memcached.org/files/memcached-#{version}.tar.gz"

version '1.4.22' do
  source :md5 => '2b7eefa17c811998f4cd55bfabc12b8e'
end

dependency 'libsasl'
dependency 'libevent'

relative_path "memcached-#{version}"


build do
  env = with_standard_compiler_flags(with_embedded_path)

  # Somehow this detection fails (causing compilation to then fail with a redefinition)
  patch source: 'fix-sasl_callback_ft-detection.patch'

  # View:
  # - https://code.google.com/p/memcached/issues/detail?id=374
  # - https://sourceware.org/bugzilla/show_bug.cgi?id=11959
  patch source: 'fix-glibc-11959.patch'

  # We patched configure.ac, so we should re-run autoconf.
  command 'aclocal', env: env
  command 'autoheader', env: env
  command 'touch  README', env: env  # Crazyness
  command 'automake  --gnu --add-missing', env: env
  command 'autoconf', env: env

  cmd = [
      './configure',
      "--prefix=#{install_dir}/embedded",
      "--with-libevent=#{install_dir}/embedded",
      '--enable-sasl',
      '--enable-sasl-pwdb',
  ]

  command cmd.join(' '), env: env
  make env: env
  make 'install', env: env
end
