# This is needed as a workaround because there is a circular dependency between freetype and harfbuzz.
name 'freetype_pre'
default_version '2.5.5'

source url: "http://download.savannah.gnu.org/releases/freetype/freetype-#{version}.tar.bz2",
       md5: '2a7a314927011d5030903179cf183be0'

relative_path "freetype-#{version}"


dependency 'pkg-config'
dependency 'zlib'
dependency 'bzip2'
dependency 'libpng'
# Harfbuzz is not depended on here.

build do
  env = with_standard_compiler_flags(with_embedded_path)
  env['BZIP2_LIBS'] = "-L#{install_dir}/lib -lbz2"

  command './configure' \
          " --prefix=#{install_dir}/embedded" \
          ' --with-zlib=yes' \
          ' --with-bzip2=yes' \
          ' --with-png=yes' \
          ' --with-harfbuzz=no', env: env
  make env: env
  make 'install', env: env
end
