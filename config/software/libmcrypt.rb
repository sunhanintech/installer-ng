name 'libmcrypt'
default_version '2.5.8'

# Note: we are getting this from Debian, because we trust Debian as a source, but the package has nothing
# Debian-specific about it.
source url: "http://ftp.debian.org/debian/pool/main/libm/libmcrypt/libmcrypt_#{version}.orig.tar.gz",
       md5: '0821830d930a86a5c69110837c55b7da'

relative_path "libmcrypt-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "./configure --disable-posix-threads --prefix=#{install_dir}/embedded", env: env
  make "-j #{workers}", env: env
  make "-j #{workers} install", env: env
end
