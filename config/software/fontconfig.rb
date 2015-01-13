name 'fontconfig'
default_version '2.11.1'

source url: "http://www.freedesktop.org/software/fontconfig/release/fontconfig-#{version}.tar.bz2",
       md5: '824d000eb737af6e16c826dd3b2d6c90'

relative_path "fontconfig-#{version}"


dependency 'libiconv'
dependency 'expat'


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command './configure' \
          " --prefix=#{install_dir}/embedded" \
          ' --enable-iconv' \
          " --with-libiconv=#{install_dir}/embedded" \
          " --with-expat=#{install_dir}/embedded", env: env
  make env: env
  make 'install', env: env
end
