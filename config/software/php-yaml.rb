name 'php-yaml'
default_version '1.3.0'

version '1.1.1' do
  source url: "http://pecl.php.net/get/yaml-#{version}.tgz"
  source md5: '5ea624ec23fe9ad20e4f24ee43da72b1'
end

version '1.3.0' do
  source url: 'http://pecl.php.net/get/yaml-1.3.0.tgz'
  source md5: '4370b78dae20b74102c4f2b541b9dd0b'
end

relative_path "yaml-#{version}"

dependency 'libyaml'
dependency 'php'

license path: 'LICENSE'


build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "#{install_dir}/embedded/bin/phpize"
  command './configure' \
          " --with-php-config=#{install_dir}/embedded/bin/php-config" \
          " --with-yaml=#{install_dir}/embedded", env: env

  make "-j #{workers}", env: env
  make 'install', env: env

  #Add extension to php.ini
  command "mkdir -p #{install_dir}/etc/php"
  command "echo 'extension=yaml.so' >> #{install_dir}/etc/php/php.ini"

end
