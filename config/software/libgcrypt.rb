name 'libgcrypt'
default_version '1.6.2'

source url: "ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-#{version}.tar.bz2",
       md5: 'b54395a93cb1e57619943c082da09d5f'

relative_path "libgcrypt-#{version}"

dependency 'libgpg-error'

build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "./configure --prefix=#{install_dir}/embedded", env: env
  make "-j #{workers}", env: env
  make "-j #{workers} check", env: env
  make "-j #{workers} install", env: env
end
