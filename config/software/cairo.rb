name 'cairo'
default_version '1.12.18'

source url: "http://cairographics.org/releases/cairo-#{version}.tar.xz",
       md5: '8e4ff32b82c3b39387eb6f5c59ef848e'

relative_path "cairo-#{version}"


dependency 'pixman'
dependency 'libpng'
dependency 'zlib'
dependency 'freetype_pre'  # We can't use 'freetype' here because 'harfbuzz' depends on 'cairo' and 'freetype' depends on 'harfbuzz'.
dependency 'fontconfig'


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command './configure' \
          " --prefix=#{install_dir}/embedded" \
          ' --enable-xlib=no' \
          ' --enable-xlib-render=no ', env: env
  make "-j #{workers}", env: env
  # We don't run check here becaue cairo just has plenty of tests that fail even when it's functional
  # (as per Cairo's own test/README document)
  make "-j #{workers} install", env: env
end
