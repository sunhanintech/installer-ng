name 'putty'
default_version '0.69'

source url: "http://the.earth.li/~sgtatham/putty/#{version}/putty-#{version}.tar.gz"

version '0.53' do
  source md5: '567207b590a149656454d6e6ea7af124'
end

version '0.64' do
  source md5: '75ff711e8b7cc9e0073bc511e1c1c14a'
end

version '0.69' do
  source md5: '75fde9a3b3694e669d21a19b60fc9166'
end

relative_path "putty-#{version}"

license 'MIT'
license_file 'LICENCE'


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "./configure --prefix=#{install_dir}/embedded", env: env
  make "-j #{workers}", env: env
  make 'install', env: env
end
