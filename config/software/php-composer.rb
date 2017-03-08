name 'php-composer'
default_version '1.3.1'

source url: "https://getcomposer.org/download/#{version}/composer.phar"

version '1.3.1' do
  source md5: '6b1bd542ae9fcf88948c4088cd883e78'
end

version '1.0.0-alpha10' do
  source md5: 'dea8681b6f54dca9bb3a5b7deb179cca'
end

dependency 'php'

build do
  env = with_standard_compiler_flags(with_embedded_path)

  # Move file to bin folder
  command "mv ./composer.phar #{install_dir}/embedded/bin/", env: env
end
