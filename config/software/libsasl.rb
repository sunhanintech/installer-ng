name 'libsasl'
default_version '2.1.26'

source url: "http://ftp.debian.org/debian/pool/main/c/cyrus-sasl2/cyrus-sasl2_#{version}.dfsg1.orig.tar.gz"

version '2.1.26' do
  source md5: '45fc09469ca059df56d64acfe06a940d'
end

relative_path "cyrus-sasl-#{version}"

dependency 'gdbm'
dependency 'openssl'


build do
  env = with_standard_compiler_flags(with_embedded_path)

  patch source: 'fix-stddef-include.patch'

  command './configure ' \
          ' --prefix=/opt/scalr-server/embedded' \
          ' --disable-sample' \
          ' --disable-gssapi' \
          " --with-configdir=#{install_dir}/embedded/lib/sasl2 " \
          " --with-plugindir=#{install_dir}/embedded/lib/sasl2 " \
          ' --without-saslauthd' \
          ' --enable-auth-sasldb' \
          " --with-dbpath=#{install_dir}/embedded/etc/sasldb2" \
          ' --with-dblib=gdbm' \
          " --with-gdbm=#{install_dir}/embedded" \
          " --with-openssl=#{install_dir}/embedded", env: env

  make "-j #{workers}", env: env
  make "-j #{workers} check", env: env
  make "-j #{workers} install", env: env
end
