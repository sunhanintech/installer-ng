name 'harfbuzz'
default_version '0.9.37'

source url: "http://www.freedesktop.org/software/harfbuzz/release/harfbuzz-#{version}.tar.bz2"

version '0.9.37' do
  source md5: 'bfe733250e34629a188d82e3b971bc1e'
end

dependency 'glib'
dependency 'freetype_pre'
dependency 'cairo'

relative_path "harfbuzz-#{version}"

license path: 'COPYING'


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "./configure --prefix=#{install_dir}/embedded", env: env
  make env: env
  make 'install', env: env
end
