name 'php-raphf'
default_version '1.1.0'

source url: "https://pecl.php.net/get/raphf-#{version}.tgz"

version '1.1.0' do
  source md5: '4d95c44dc28be089ce59bceb647b8db2'
end

dependency 'php'

relative_path "raphf-#{version}"

license path: 'LICENSE'

build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "#{install_dir}/embedded/bin/phpize"
  command './configure' \
          " --with-php-config=#{install_dir}/embedded/bin/php-config" \
          " --with-libdir=#{install_dir}/embedded" \
          " --enable-raphf", env: env
  make "-j #{workers}", env: env
  make 'install', env: env

  #Add extension to php.ini
  command "mkdir -p #{install_dir}/etc/php"
  command "echo 'extension=raphf.so' >> #{install_dir}/etc/php/php.ini"
end
