name 'cairo'
default_version '1.14.8'

source url: "http://cairographics.org/releases/cairo-#{version}.tar.xz"

version '1.12.18' do
  source md5: '8e4ff32b82c3b39387eb6f5c59ef848e'
end

version '1.14.8' do
  source md5: '4ef0db2eacb271c74f8a3fd87822aa98'
end

dependency 'pixman'
dependency 'libpng'
dependency 'zlib'
dependency 'freetype_pre'  # We can't use 'freetype' here because 'harfbuzz' depends on 'cairo' and 'freetype' depends on 'harfbuzz'.
dependency 'fontconfig'

relative_path "cairo-#{version}"

license 'MPL-1.1'
license_file 'COPYING-MPL-1.1'
skip_transitive_dependency_licensing true


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command './configure' \
          " --prefix=#{install_dir}/embedded" \
          ' --enable-xlib=no' \
          ' --enable-xlib-render=no ', env: env
  make "-j #{workers}", env: env
  make 'install', env: env
end
