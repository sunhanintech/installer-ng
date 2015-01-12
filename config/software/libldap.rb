name 'libldap'
default_version '2.4.40'

source url: "http://ftp.debian.org/debian/pool/main/o/openldap/openldap_#{version}.orig.tar.gz",
       md5: '03a8658e62131c0cdbf85dd604e498db'

relative_path "openldap_#{version}.orig"

dependency 'openssl'
dependency 'libsasl'

build do
  env = with_standard_compiler_flags(with_embedded_path)

  # libldap uses the preprocessor to check for compatibility with openssl and sasl, but by default,
  # omnibus does include preprocessor flags (CPPFLAGS). We add them here to avoid the following error:
  # "accepted by the compiler, rejected by the preprocessor!"
  env['CPPFLAGS'] = "-I#{install_dir}/embedded/include"

  command './configure' \
          ' --disable-slapd' \
          ' --with-tls=openssl' \
          ' --with-cyrus-sasl' \
          " --prefix=#{install_dir}/embedded", env: env
  make "-j #{workers} depend", env: env
  make "-j #{workers}", env: env
  make "-j #{workers} install", env: env
end
