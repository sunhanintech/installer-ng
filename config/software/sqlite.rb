name 'sqlite'
default_version '3080900'  # 3.8.9.0

year = nil

version '3080704' do
  year = 2014
  source md5: '33bb8db0038317ce1b0480ca1185c7ba'
end

version '3080900' do
  year = 2015
  source md5: '6a18d4609852f4b63f812a1059df468f'
end

source url: "http://www.sqlite.org/#{year}/sqlite-autoconf-#{version}.tar.gz"


relative_path "sqlite-autoconf-#{version}"

license url: 'https://www.sqlite.org/copyright.html'

build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "./configure --prefix=#{install_dir}/embedded --disable-readline", env: env
  make "-j #{workers}", env: env
  make "-j #{workers} install", env: env
end
