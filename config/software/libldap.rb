name 'libldap'
default_version '2.4.40'

source url: "http://ftp.debian.org/debian/pool/main/o/openldap/openldap_#{version}.orig.tar.gz",
       md5: '03a8658e62131c0cdbf85dd604e498db'

relative_path "openldap_#{version}.orig"

dependency 'openssl'
dependency 'libsasl'

build do
  env = with_standard_compiler_flags(with_embedded_path)

  command './configure' \
          ' --disable-slapd' \
          ' --with-tls=openssl' \
          ' --with-cyrus-sasl' \
          " --sysconfdir=#{install_dir}/etc" \
          " --prefix=#{install_dir}/embedded", env: env
  make "-j #{workers} depend", env: env
  make "-j #{workers}", env: env
  make "-j #{workers} install", env: env
end
