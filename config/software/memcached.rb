name 'memcached'
default_version '1.4.22'

source :url => "http://memcached.org/files/memcached-#{version}.tar.gz"

version '1.4.22' do
  source :md5 => '2b7eefa17c811998f4cd55bfabc12b8e'
end

dependency 'libsasl'
dependency 'libevent'

relative_path "memcached-#{version}"

license path: 'COPYING'


build do
  env = with_standard_compiler_flags(with_embedded_path)

  # View:
  # - https://code.google.com/p/memcached/issues/detail?id=374
  # - https://sourceware.org/bugzilla/show_bug.cgi?id=11959
  patch source: 'fix-glibc-11959.patch'

  # We add a patch to use a constant realm in memcached. The goal of that patch
  # is to ensure that the sasldb stays even if the hostname changes.
  # Also, it's helpful in the sense that sometimes, saslpasswd2 and memcached disagree on what the realm should be
  # (saslpasswd2 lowercases it, memcached doesn't), which results in a hostname that isn't valid.
  patch source: 'constant-realm.patch'

  cmd = [
      './configure',
      "--prefix=#{install_dir}/embedded",
      "--with-libevent=#{install_dir}/embedded",
      '--enable-sasl'
  ]

  command cmd.join(' '), env: env
  make "-j #{workers}", env: env
  make 'install', env: env
end
