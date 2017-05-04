#
# Copyright 2014 Chef Software, Inc.
# Copyright 2015 Scalr, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


name 'php'
default_version '7.1.4'

dependency 'zlib'
dependency 'libedit'
dependency 'pcre'
dependency 'expat'
dependency 'libxslt'
dependency 'libxml2'
dependency 'libiconv'
dependency 'openssl'
dependency 'libmcrypt'
dependency 'mysql'
dependency 'curl'
dependency 'libldap'
dependency 'libsasl'
dependency 'gettext'
dependency 'libssh2'
dependency 'httpd'
dependency 'libtool'

source url: "http://us.php.net/distributions/php-#{version}.tar.gz"

version '5.5.20' do
        source md5: '63185e6efdd4e381c5f2ec1b1e3baf1f'
end

version '5.5.22' do
        source md5: '89caa2614a7e0e7a41796d61869037ca'
end

version '5.5.23' do
        source md5: '756ae8355c0b3085d12498fb0412cae5'
end

version '5.5.24' do
        source md5: 'f5666659d9279f725f4351866bb73bed'
end

version '5.5.26' do
        source md5: '00cdcf41c6432eb82ce5c4b687eef801'
end

version '5.5.29' do
        source md5: '79db29eb718dc35092a5e94b81d13d07'
end

version '5.6.14' do
        source md5: 'ae625e0cfcfdacea3e7a70a075e47155'
end

version '5.6.17' do
        source md5: '9cbf226d0b5d852e66a0b7272368ecea'
end

version '5.6.23' do
        source md5: '5120140b7b3117e50807836a1869e250'
end

version '5.6.28' do
        source md5: 'db41e97006dd9660208c0f3d32ce192e'
end

version '5.6.30' do
        source md5: '8c7ef86c259abad33f213405a35a13c2'
end

version '7.1.4' do
        source md5: '47e7d116553a879ff957ef2684987c23'
end


relative_path "php-#{version}"

license path: 'LICENSE'


build do
  env = with_standard_compiler_flags(with_embedded_path)

command "./configure" \
          ' --enable-debug' \
          " --prefix=#{install_dir}/embedded" \
          " --without-pear" \
          " --with-zlib-dir=#{install_dir}/embedded" \
          " --with-pcre-regex=#{install_dir}/embedded" \
          " --with-xsl=#{install_dir}/embedded" \
          " --with-libxml-dir=#{install_dir}/embedded" \
          " --with-iconv-dir=#{install_dir}/embedded" \
          " --with-openssl=#{install_dir}/embedded" \
          " --with-libedit=#{install_dir}/embedded" \
          ' --enable-sockets' \
          " --with-curl=#{install_dir}/embedded" \
          " --with-gettext=#{install_dir}/embedded" \
          " --with-mysqli=#{install_dir}/embedded/bin/mysql_config" \
          " --with-pdo-mysql=#{install_dir}/embedded" \
          " --with-mcrypt=#{install_dir}/embedded" \
          ' --enable-pcntl' \
          ' --enable-sysvsem --enable-sysvshm --enable-sysvmsg' \
          " --with-xsl=#{install_dir}/embedded" \
          ' --enable-wddx' \
          " --with-libexpat-dir=#{install_dir}/embedded" \
          ' --enable-soap' \
          " --with-ldap=#{install_dir}/embedded" \
          " --with-ldap-sasl=#{install_dir}/embedded" \
          " --with-apxs2=#{install_dir}/embedded/bin/apxs" \
          ' --enable-fpm' \
          " --with-config-file-path=#{install_dir}/etc/php" \
          ' --with-fpm-user=scalr' \
          ' --enable-bcmath' \
          ' --enable-mbstring' \
          ' --with-fpm-group=scalr', env: env

  make "-j #{workers}", env: env
  make 'install', env: env
end
