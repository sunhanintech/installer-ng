name 'php-yaml'
default_version '1.1.1'

source url: "http://pecl.php.net/get/yaml-#{version}.tgz",
       md5: '5ea624ec23fe9ad20e4f24ee43da72b1'

relative_path "yaml-#{version}"

dependency 'libyaml'
dependency 'php'


build do
       env = with_standard_compiler_flags(with_embedded_path)

       command "#{install_dir}/embedded/bin/phpize"
       command './configure' \
               " --with-php-config=#{install_dir}/embedded/bin/php-config" \
               " --with-yaml=#{install_dir}/embedded", env: env
       make env: env
       make 'install', env: env
end
