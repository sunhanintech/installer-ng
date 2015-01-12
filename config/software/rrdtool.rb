name 'rrdtool'
default_version '1.4.9'

source url: "http://oss.oetiker.ch/rrdtool/pub/rrdtool-#{version}.tar.gz",
       md5: '1cea5a9efd6a48ac4035b0f9c7e336cf'

relative_path "rrdtool-#{version}"

dependency 'pkg-config'
dependency 'zlib'
dependency 'libpng'
dependency 'libxml2'
dependency 'freetype'
dependency 'fontconfig'
dependency 'pixman'
dependency 'cairo'
dependency 'glib'
dependency 'pango'


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "./configure --prefix=#{install_dir}/embedded" \
          ' --disable-ruby --disable-python', env: env
  make env: env
  make 'install', env: env
end
