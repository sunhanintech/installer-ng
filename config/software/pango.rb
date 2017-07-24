name 'pango'
default_version '1.40.5'

version '1.36.8' do
  source url: "http://ftp.gnome.org/pub/GNOME/sources/pango/1.36/pango-#{version}.tar.xz"
  source md5: '217a9a753006275215fa9fa127760ece'
end

version '1.40.5' do
  source url: "http://ftp.gnome.org/pub/GNOME/sources/pango/1.40/pango-1.40.5.tar.xz"
  source md5: '11fb1e94c486507a94c4a905d86e70ce'
end

dependency 'glib'
dependency 'freetype'
dependency 'fontconfig'
dependency 'harfbuzz'

relative_path "pango-#{version}"

license path: 'COPYING'


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "./configure --prefix=#{install_dir}/embedded", env: env
  make "-j #{workers}", env: env
  make 'install', env: env
end
