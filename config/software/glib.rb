name 'glib'
default_version '2.52.2'

version '2.42.1' do
  source url: "http://ftp.gnome.org/pub/gnome/sources/glib/2.42/glib-#{version}.tar.xz"
  source md5: '89c4119e50e767d3532158605ee9121a'
end

version '2.52.2' do
  source url: "http://ftp.gnome.org/pub/gnome/sources/glib/2.52/glib-2.52.2.tar.xz"
  source md5: 'ec099bce26ce6a85104ed1d89bb45856'
end

# See: https://developer.gnome.org/glib/2.42/glib-building.html
dependency 'libiconv'
dependency 'gettext'
dependency 'libffi'

relative_path "glib-#{version}"

license path: 'COPYING'


build do
  env = with_standard_compiler_flags(with_embedded_path)

  # TODO - disable-python??
  # Note: --with-pcre=system fails because pcre lacks unicode support
  command './configure' \
          " --prefix=#{install_dir}/embedded" \
          ' --with-libiconv=gnu' \
          ' --disable-selinux' \
          ' --disable-dtrace' \
          ' --disable-systemtap', env: env
  make "-j #{workers}", env: env
  make 'install', env: env
end
