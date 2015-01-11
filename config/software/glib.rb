name 'glib'
default_version '2.42.1'

source url: "http://ftp.gnome.org/pub/gnome/sources/glib/2.42/glib-#{version}.tar.xz",
       md5: '89c4119e50e767d3532158605ee9121a'

relative_path "glib-#{version}"

# See: https://developer.gnome.org/glib/2.42/glib-building.html
dependency 'pkg-config'
dependency 'libiconv'
dependency 'gettext'
dependency 'libffi'

# !! ERROR: fileutils - missing test plan¬
# !! ERROR: fileutils - exited with status 134 (terminated by signal 6?)


build do
  env = with_standard_compiler_flags(with_embedded_path)

  # TODO - disable-python??
  # todo --with-pcre=system? It currently lacks unicode support
  command './configure' \
          " --prefix=#{install_dir}/embedded" \
          ' --with-libiconv=gnu' \
          ' --disable-selinux' \
          ' --disable-dtrace' \
          ' --disable-systemtap', env: env
  make "-j #{workers}", env: env
  #make "-j #{workers} check", env: env
  make "-j #{workers} install", env: env
end
