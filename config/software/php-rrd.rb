name 'php-rrd'
default_version '1.1.3'

source url: "http://pecl.php.net/get/rrd-#{version}.tgz"

version '1.1.3' do
  source md5: 'bde6c50fa2aa39090ed22e574ac71c5a'
end

dependency 'rrdtool'
dependency 'php'

relative_path "rrd-#{version}"

license path: 'LICENSE'


build do
       env = with_standard_compiler_flags(with_embedded_path)

       command "#{install_dir}/embedded/bin/phpize"
       command './configure' \
               " --with-php-config=#{install_dir}/embedded/bin/php-config" \
               " --with-rrd=#{install_dir}/embedded", env: env
       make "-j #{workers}", env: env
       make 'install', env: env
end
