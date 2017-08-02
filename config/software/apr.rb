name 'apr'
default_version '1.5.2'

source url: "http://www.us.apache.org/dist/apr/apr-#{version}.tar.bz2"

version '1.5.1' do
  source md5: '5486180ec5a23efb5cae6d4292b300ab'
end

version '1.5.2' do
  source md5: '4e9769f3349fe11fc0a5e1b224c236aa'
end

relative_path "apr-#{version}"

license 'Apache-2.0'
license_file 'LICENSE'


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "./configure --prefix=#{install_dir}/embedded", env: env
  make "-j #{workers}", env: env
  make 'install', env: env
end
