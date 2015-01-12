name 'putty'
default_version '0.63'

source url: "http://the.earth.li/~sgtatham/putty/latest/putty-#{version}.tar.gz",
       md5: '567207b590a149656454d6e6ea7af124'

relative_path "putty-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "./configure --prefix=#{install_dir}/embedded", env: env
  make env: env
  make 'install', env: env
end
