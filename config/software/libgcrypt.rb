name 'libgcrypt'
default_version '1.6.3'

source url: "ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-#{version}.tar.bz2"

version '1.6.2' do
  source md5: 'b54395a93cb1e57619943c082da09d5f'
end

version '1.6.3' do
  source md5: '4262c3aadf837500756c2051a5c4ae5e'
end

dependency 'libgpg-error'

relative_path "libgcrypt-#{version}"

# TODO - There is a secondary license in 'LICENSES'
license 'LGPL-2.1'
license_file 'COPYING.LIB'


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "./configure --prefix=#{install_dir}/embedded", env: env
  make "-j #{workers}", env: env
  make "-j #{workers} check", env: env
  make "-j #{workers} install", env: env
end
