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
default_version '5.5.20'

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
dependency 'gettext'

source url: "http://us.php.net/distributions/php-#{version}.tar.gz",
       md5: '63185e6efdd4e381c5f2ec1b1e3baf1f'

relative_path "php-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "./configure" \
          " --prefix=#{install_dir}/embedded" \
          " --without-pear" \
          " --with-zlib-dir=#{install_dir}/embedded" \
          " --with-pcre-dir=#{install_dir}/embedded" \
          " --with-xsl=#{install_dir}/embedded" \
          " --with-libxml-dir=#{install_dir}/embedded" \
          " --with-iconv=#{install_dir}/embedded" \
          " --with-openssl=#{install_dir}/embedded" \
          " --with-libedit-dir=#{install_dir}/embedded" \
          " --with-gettext=#{install_dir}/embedded" \
          " --with-mysql=#{install_dir}/embedded" \
          " --with-mysqli=#{install_dir}/embedded/bin/mysql_config" \
          " --with-pdo-mysql=#{install_dir}/embedded" \
          " --with-mcrypt=#{install_dir}/embedded" \
          ' --enable-pcntl' \
          ' --enable-sysvsem --enable-sysvshm --enable-sysvmsg' \
          " --with-xsl=#{install_dir}/embedded" \
          ' --enable-wddx' \
          " --with-libexpat-dir=#{install_dir}/embedded" \
          ' --enable-soap' \
          ' --enable-opcache' \
          ' --enable-fpm' \
          " --with-config-file-path=#{install_dir}/embedded/etc/php" \
          ' --with-fpm-user=scalr' \
          ' --with-fpm-group=scalr', env: env

  make "-j #{workers}", env: env
  make 'install', env: env
end

#'./configure --enable-opcache --prefix=/opt/php
#--with-apxs2=/usr/bin/apxs2 --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pgsql=/usr
#--with-tidy=/usr --with-curl=/usr/bin --with-openssl-dir=/usr --with-zlib-dir=/usr
#--with-xpm-dir=/usr --with-pdo-pgsql=/usr --with-pdo-mysql=mysqlnd --with-xsl=/usr
#--with-ldap --with-xmlrpc --with-iconv-dir=/usr --with-snmp=/usr --enable-exif --enable-calendar
#--with-bz2=/usr --with-mcrypt=/usr --with-gd --with-jpeg-dir=/usr --with-png-dir=/usr
#--with-freetype-dir=/usr --enable-mbstring --enable-zip --with-pear --with-libdir=/lib/x86_64-linux-gnu
#--with-config-file-path=/opt'