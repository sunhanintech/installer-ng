name 'gettext'
default_version '0.18.3.1'

source url: "http://archive.ubuntu.com/ubuntu/pool/main/g/gettext/gettext_#{version}.orig.tar.gz",
       md5: '3fc808f7d25487fc72b5759df7419e02'

relative_path "gettext-#{version}"

dependency 'libiconv'
dependency 'ncurses'
dependency 'expat'
dependency 'libxml2'

# TODO - Can we somehow guarantee openmp presence?

build do
  env = with_standard_compiler_flags(with_embedded_path)

  command './configure' \
          " --prefix=#{install_dir}/embedded" \
          ' --disable-openmp' \
          ' --disable-java' \
          ' --disable-native-java' \
          ' --without-emacs' \
          ' --without-git' \
          ' --without-bzip2' \
          ' --without-xz' \
          " --with-libiconv-prefix=#{install_dir}/embedded" \
          " --with-ncurses-prefix=#{install_dir}/embedded" \
          " --with-libexpat-prefix=#{install_dir}/embedded" \
          " --with-libxml2-prefix=#{install_dir}/embedded" \
          ' --with-included-glib' \
          ' --with-included-libcroco' \
          ' --with-included-libunistring', env: env
  make "-j #{workers}", env: env
  make "-j #{workers} check", env: env
  make "-j #{workers} install", env: env
end
