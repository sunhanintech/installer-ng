name 'pixman'
default_version '0.32.6'

source url: "http://cairographics.org/releases/pixman-#{version}.tar.gz",
       md5: '3a30859719a41bd0f5cccffbfefdd4c2'

relative_path "pixman-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "./configure  --prefix=#{install_dir}/embedded" , env: env
  make "-j #{workers}", env: env
  make "-j #{workers} check", env: env
  make "-j #{workers} install", env: env
end
