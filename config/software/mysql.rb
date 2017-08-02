# I need perl for the scripts here

name 'mysql'
default_version '5.6.33'

source :url => "http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-#{version}.tar.gz"

version '5.6.22' do
  source :md5 => '3985b634294482363f3d87e0d67f2262'
end

version '5.6.24' do
  source :md5 => '68e1911f70eb1b02170d4f96bf0f0f88'
end

version '5.6.33' do
  source :md5 => '7fbf37928ef651e005b80e820a055385'
end

dependency 'zlib'
dependency 'ncurses'
dependency 'libedit'
dependency 'openssl'
dependency 'libaio'
dependency 'perl'

relative_path "mysql-#{version}"

license 'GPL-2.0'
license_file 'COPYING'
skip_transitive_dependency_licensing true


# View: http://dev.mysql.com/doc/refman/5.5/en/source-configuration-options.html

# TODO - Check --enable-languages (mysqlbug)
build do
  env = with_standard_compiler_flags(with_embedded_path)

  command [
              'cmake',
              # General flags
              '-DCMAKE_SKIP_RPATH=YES',
              "-DCMAKE_INSTALL_PREFIX=#{install_dir}/embedded",
              # Additional Paths flag. We kindly ask MySQL not to drop everything in ./embedded
              "-DINSTALL_DOCREADMEDIR=#{install_dir}/embedded/mysql-doc",
              "-DINSTALL_INFODIR=#{install_dir}/embedded/mysql-doc",
              # Build type
              '-DBUILD_CONFIG=mysql_release',
              # Don't build embedded server libraries (we don't use those, and they are *huge*)
              '-DWITH_EMBEDDED_SERVER=0',
              '-DWITH_EMBEDDED_SHARED_LIBRARY=0',
              # Lib flags
              '-DWITH_ZLIB=system',
              '-DWITH_SSL=system',
              '-DWITH_EDITLINE=system',
              # Feature flags
              '-DDEFAULT_CHARSET=utf8',
              '-DDEFAULT_COLLATION=utf8_unicode_ci',
              # MySQL runtime options. We set those to reasonable defaults that are used in the cookbook
              "-DMYSQL_UNIX_ADDR=#{install_dir}/var/run/mysql/mysql.sock",
              "-DSYSCONFDIR=#{install_dir}/etc/mysql",
              '.',
          ].join(' '), :env => env

  make "-j #{workers}", env: env
  make "-j #{workers} install", env: env

  #Use embedded Perl binary
  command "sed -i '1 s|^.*$|#!#{install_dir}/embedded/bin/perl|g' #{install_dir}/embedded/scripts/mysql_install_db", env: env
end
