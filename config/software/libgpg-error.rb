name 'libgpg-error'
default_version '1.24'

source url: "ftp://ftp.gnupg.org/gcrypt/libgpg-error/libgpg-error-#{version}.tar.bz2"

version '1.17' do
  source md5: 'b4f8d8b9ff14aed41f279aa844563539'
end

version '1.18' do
  source md5: '12312802d2065774b787cbfc22cc04e9'
end

version '1.24' do
  source md5: 'feb42198c0aaf3b28eabe8f41a34b983'
end

relative_path "libgpg-error-#{version}"

license 'LGPL-2.1'
license_file 'COPYING.LIB'


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "./configure --prefix=#{install_dir}/embedded", env: env
  make "-j #{workers}", env: env
  make "-j #{workers} check", env: env
  make "-j #{workers} install", env: env
end
