name 'sqlite'
default_version '3080704'  # 3.8.7.4

source url: "http://www.sqlite.org/2014/sqlite-autoconf-#{version}.tar.gz"

version '3080704' do
  source md5: '33bb8db0038317ce1b0480ca1185c7ba'
end

relative_path "sqlite-autoconf-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "./configure --prefix=#{install_dir}/embedded --disable-readline", env: env
  make "-j #{workers}", env: env
  make "-j #{workers} install", env: env
end
