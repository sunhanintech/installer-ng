name 'libssh2'
default_version '1.4.3'

source url: "http://www.libssh2.org/download/libssh2-#{version}.tar.gz"

version '1.4.3' do
  source md5: '071004c60c5d6f90354ad1b701013a0b'
end

dependency 'zlib'
dependency 'openssl'
dependency 'libgcrypt'

relative_path "libssh2-#{version}"

license 'BSD-3-Clause'
license_file 'COPYING'
skip_transitive_dependency_licensing true


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
