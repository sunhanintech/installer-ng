name 'pixman'
default_version '0.32.6'

source url: "http://cairographics.org/releases/pixman-#{version}.tar.gz"

version '0.32.6' do
  source md5: '3a30859719a41bd0f5cccffbfefdd4c2'
end

relative_path "pixman-#{version}"

license 'MIT'
license_file 'COPYING'


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "./configure  --prefix=#{install_dir}/embedded" , env: env
  make "-j #{workers}", env: env
  make 'install', env: env
end
