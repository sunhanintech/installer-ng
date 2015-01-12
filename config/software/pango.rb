name 'pango'
default_version '1.36.8'

source url: "http://ftp.gnome.org/pub/GNOME/sources/pango/1.36/pango-#{version}.tar.xz",
       md5: '217a9a753006275215fa9fa127760ece'

relative_path "pango-#{version}"


dependency 'pkg-config'
dependency 'glib'
dependency 'freetype'
dependency 'fontconfig'
dependency 'harfbuzz'


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "./configure --prefix=#{install_dir}/embedded", env: env
  make env: env
  make 'install', env: env
end
