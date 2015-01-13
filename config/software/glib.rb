name 'glib'
default_version '2.42.1'

source url: "http://ftp.gnome.org/pub/gnome/sources/glib/2.42/glib-#{version}.tar.xz",
       md5: '89c4119e50e767d3532158605ee9121a'

relative_path "glib-#{version}"

# See: https://developer.gnome.org/glib/2.42/glib-building.html
dependency 'libiconv'
dependency 'gettext'
dependency 'libffi'


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
  make env: env
  make 'install', env: env
end
