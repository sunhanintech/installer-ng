name 'libssh2'
default_version '1.4.3'

source url: "http://www.libssh2.org/download/libssh2-#{version}.tar.gz",
       md5: '071004c60c5d6f90354ad1b701013a0b'

relative_path "libssh2-#{version}"

dependency 'zlib'
dependency 'openssl'
dependency 'libgcrypt'

build do
  env = with_standard_compiler_flags(with_embedded_path)

  command './configure' \
          " --prefix=#{install_dir}/embedded" \
          " --with-libgcrypt-prefix=#{install_dir}/embedded" \
          " --with-libssl-prefix=#{install_dir}/embedded" \
          " --with-libz-prefix=#{install_dir}/embedded", env:env
  make "-j #{workers}", env: env
  make "-j #{workers} install", env: env
end
