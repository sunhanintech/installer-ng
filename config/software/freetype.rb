# Actual freetype installation.
name 'freetype'
default_version '2.5.5'

source url: "http://download.savannah.gnu.org/releases/freetype/freetype-#{version}.tar.bz2",
       md5: '2a7a314927011d5030903179cf183be0'

relative_path "freetype-#{version}"


dependency 'pkg-config'
dependency 'libpng'
dependency 'bzip2'
dependency 'zlib'
dependency 'harfbuzz'

build do
  env = with_standard_compiler_flags(with_embedded_path)
  env['BZIP2_LIBS'] = "-L#{install_dir}/lib -lbz2"

  command './configure' \
          " --prefix=#{install_dir}/embedded" \
          ' --with-zlib=yes' \
          ' --with-bzip2=yes' \
          ' --with-png=yes' \
          ' --with-harfbuzz=yes', env: env
  make "-j #{workers}", env: env
  make "-j #{workers} check", env: env
  make "-j #{workers} install", env: env
end
# TODO - Rebuild cairo after I build this?
