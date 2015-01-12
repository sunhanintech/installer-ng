name 'apr'
default_version '1.5.1'

source url: "http://www.us.apache.org/dist/apr/apr-#{version}.tar.bz2",
       md5: '5486180ec5a23efb5cae6d4292b300ab'

relative_path "apr-#{version}"


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "./configure --prefix=#{install_dir}/embedded", env: env
  make env: env
  make 'install', env: env
end
