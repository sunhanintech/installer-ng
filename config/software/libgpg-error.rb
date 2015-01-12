name 'libgpg-error'
default_version '1.17'

source url: "ftp://ftp.gnupg.org/gcrypt/libgpg-error/libgpg-error-#{version}.tar.bz2",
       md5: 'b4f8d8b9ff14aed41f279aa844563539'

relative_path "libgpg-error-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "./configure --prefix=#{install_dir}/embedded", env: env
  make "-j #{workers}", env: env
  make "-j #{workers} check", env: env
  make "-j #{workers} install", env: env
end
