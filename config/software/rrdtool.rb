name 'rrdtool'
default_version '1.6.0'

source url: "http://oss.oetiker.ch/rrdtool/pub/rrdtool-#{version}.tar.gz"

version '1.4.9' do
  source md5: '1cea5a9efd6a48ac4035b0f9c7e336cf'
end

version '1.6.0' do
  source md5: '4ff52cc44b935b02d2742e6875094da5'
end

dependency 'zlib'
dependency 'libpng'
dependency 'libxml2'
dependency 'freetype'
dependency 'fontconfig'
dependency 'pixman'
dependency 'cairo'
dependency 'glib'
dependency 'pango'

relative_path "rrdtool-#{version}"

# TODO There is another one for the libs
license path: 'COPYING'


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "./configure --prefix=#{install_dir}/embedded" \
          ' --disable-ruby --disable-python', env: env
  make "-j #{workers}", env: env
  make 'install', env: env
end
